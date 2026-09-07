FROM php:8.2-cli

# System deps + PHP extensions required by WhatsMine (InstallerService::REQUIRED_EXTENSIONS)
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libfreetype6-dev libjpeg62-turbo-dev \
    supervisor cron nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql bcmath mbstring gd zip exif pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy dependency files first for layer caching
COPY composer.json composer.lock package.json package-lock.json ./

# Install PHP deps (ignore scripts that need APP_KEY)
RUN composer install --no-dev --no-interaction --no-scripts --prefer-dist --optimize-autoloader || true

COPY . .

# Install JS deps + build Vite assets (public/build is gitignored)
RUN npm ci && npm run build || npm install && npm run build

# Finish PHP install + perms
RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && mkdir -p storage/framework/{sessions,views,cache} storage/app/public bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && php artisan storage:link || true

EXPOSE 8000

# Hostinger will inject env vars via docker-compose environment; generate APP_KEY if empty
CMD sh -c "php artisan config:clear && \
    if [ -z \"\$APP_KEY\" ]; then php artisan key:generate --force; fi && \
    php artisan migrate --force --no-interaction || true && \
    php artisan serve --host=0.0.0.0 --port=8000"
