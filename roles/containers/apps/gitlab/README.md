# Gitlab

Gitlab is an open-source git service with enterprise features.

NOTE: The minimum possible password length in gitlab is 8 characters!

## Initial Login

- user: `root`
- password: see `{{ docker_data }}/gitlab/gitlab/config/initial_root_password` (file will be deleted automatically after 24h!)

Change your `root` password in the gitlab webui ASAP.

## Register Runner

Open `https://git.{{ domain }}/admin/runners` in your webbrowser to get the registration token for the runner. Then run:

```bash
docker compose exec gitlab-runner-01 gitlab-runner register \
    --non-interactive \
    --url "http://gitlab" \
    --registration-token "${RUNNER_TOKEN}" \
    --clone-url "http://gitlab" \
    --executor "docker" \
    --docker-network-mode "docker-bridge" \
    --docker-image "docker:stable" \
    --tls-ca-file /cert/ca.crt \
    --config="/etc/gitlab-runner/config.toml"
```

Replace `${RUNNER_TOKEN}` with token shown in the webui.

Args explained:

- `--docker-network-mode "docker-bridge"`: the name of the docker network to use for the ci process (network names are specified in the `docker-compose.yml`). Then selected network need internet access and access to `gitlab` docker via hostname to work probably!
- `--clone-url "http://gitlab"` override the git clone url to clone direct from `gitlab` docker.

## Registry

Usage

With an self-signed cert you have to add the register as insecure to `/etc/docker/daemon.json`:

```json
{
  "insecure-registries": ["gitlab-registry.{{ domain }}"]
}
```
