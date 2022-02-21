# Traefik

Traefik is a modern HTTP reverse proxy and load balancer to manage all your microservices. Traefik integrates with your existing infrastructure components (Docker, Kubernetes, ...) and configures itself automatically.

## OPNsense

Required Settings in OPNsense:

- System : Settings : Administation : Disable DNS Rebinding Checks = Enabled
- System : Settings : Administation : Alternate Hostnames = "opnsense.{{ domain }}"
