# WireGuard

WireGuard is an fast and modern VPN that utilizes state-of-the-art cryptography.

## Setup

Open webui at `wireguard.{{ domain }}` and create a new client. Then download the config and import the config file with:

```bash
sudo nmcli connection import type wireguard file [CONFIG_FILE]
```
