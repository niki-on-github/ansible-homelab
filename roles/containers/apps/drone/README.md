# drone

## Requirements

Gitea `app.ini`

```ini
[webhook]
ALLOWED_HOST_LIST = *
SKIP_TLS_VERIFY = true
```

## Setup

## Generate Gitea OAuth2 Client Secret

1. Login to Gitea
2. Navigate to `Settings:Applications:Manage OAuth2 Applications`
3. Create Application `Name = drone` and `Redirect URI = https://drone.{{ domain }}/login`.
4. Store client id and client secret in ansible secret vars `drone_gitea_oauth2_client_id` and `drone_gitea_oauth2_client_secret`
