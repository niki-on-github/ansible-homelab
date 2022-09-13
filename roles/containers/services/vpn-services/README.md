# VPN Services

Various download managers in docker tunneled through one OpenVPN Client

**WARNING:** IP leak at start possible!

## Features

- Build in dnsleaktest `/dnsleaktest`
- Low Speed Reconnect configurable via webinterface
- Supports multiple VPN config which are used to change the IP
- Manual Reconnect with `/reconnect`

## Start

Add your OpenVPN config files (`*.ovpn`) to config and adjust the configuration in `.env`. Keep in mind, that only server ips in the OpenVPN configs work. Then start all download managers + vpn with:

```bash
docker compose up --remove-orphans --build -d
```

## NZBGet Setup

The Webui can be found at `SERVER_IP:6789` and the default login details (change ASAP) are:

```
user: nzbget
password: tegbzn6789
```

Change the default login in Settings -> Security -> ControlUsername and ControlPassword.

Then change the umask setting in Settings -> Security -> UMask to `000` and save all changes

The apply all changes Reload the configuration with Settings -> System -> Reload

### NZB Embedded Password Extension Script Setup

1. Change Script path in Settings -> Paths -> ScriptDir to `/scripts` and save + reload nzbget
2. Select Script in Settings -> Extension Scripts -> Extensions -> Choose -> `GetPw.py`

## Check VPN IP

```bash
docker exec nzbget curl ifconfig.co/json
```
