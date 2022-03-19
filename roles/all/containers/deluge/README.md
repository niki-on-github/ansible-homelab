# Deluge + VPN

Deluge is a lightweight, cross-platform BitTorrent client with encryption, WebUI and an plugin system.

This Docker includes OpenVPN and WireGuard to ensure a secure and private connection to the Internet, including use of iptables to prevent IP leakage when the tunnel is down. It also includes Privoxy to allow unfiltered access to index sites, to use Privoxy please point your application at `http://<host ip>:8118`.

## Access Deluge

Default password for the webui is "deluge".
