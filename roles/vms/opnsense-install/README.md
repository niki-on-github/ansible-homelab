# OPNsense

OPNsense is open source, FreeBSD-based firewall and routing software developed by Deciso.

## SSH

After deployment we copy the ssh private key to `files/opnsense` in the project root directory.

Usage:

```bash
ssh vagrant@$ROUTER_IP -i "files/opnsense/private_key"
```

## Post Setup

Recommend Plugins:

- `os-qemu-guest-agent`
- `os-wireguard`
