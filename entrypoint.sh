#!/bin/sh
set -e

# Ensure storage/app/public exists (volume mount may overwrite build-time dir)
mkdir -p storage/app/public

# Run storage:link at container startup to ensure the symlink is correct
# for the runtime volume mount
php artisan storage:link || true

# Clear config cache to pick up any environment changes
php artisan config:clear

# Generate APP_KEY if not set
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Run migrations
php artisan migrate --force --no-interaction || true

# Start the server
exec php artisan serve --host=0.0.0.0 --port=8000