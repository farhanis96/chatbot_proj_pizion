<?php

namespace App\Modules\Integrations\Services\Credentials;

class LlmCredentials extends CredentialValueObject
{
    public function apiKey(): ?string
    {
        return $this->get('api_key');
    }

    public function organizationId(): ?string
    {
        return $this->get('organization_id');
    }

    public function defaultModel(): ?string
    {
        return $this->get('default_model');
    }
}
