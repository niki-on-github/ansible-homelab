# public services

Public accessible service via tailscale.

MagicDNS do not support subdomains on tailscale machine for now (see [#3847](https://github.com/tailscale/tailscale/issues/3847)). As long this issue is not addressed we can not use the recommend method to publish our services.

For now we use sub paths to publish multiple services.
