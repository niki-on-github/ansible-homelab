# [Teleport](https://github.com/gravitational/teleport)

Teleport is an open-source tool for providing zero trust access to servers and cloud applications using SSH, Kubernetes and HTTPS. It can eliminate the need for VPNs by providing a single gateway to access computing infrastructure via SSH, Kubernetes clusters, and cloud applications via a built-in proxy.

## Usage

### Important Notes

- When yo switch the server certificate you need to run `sudo rm -rf /var/lib/teleport/` on your clients to get working teleport connection again!
- The certificate for teleport must include an Wildcard for the subdomain of teleport. When you use `teleport.example.lan` you have to add `*.teleport.example.lan` to the alt name of the domain certificate. You should also keep in mind that Certificate Signing Request with pattern `*.*.xyz.com` do not work only a single `*` is allowed!

### Create an new User

```bash
cd {{ docker_recipes }}/teleport
docker-compose exec teleport tctl users add $USERNAME --roles=editor,access --logins=root,ubuntu,nix,arch
```

Adjust the logins as needed.

If you have already an admin user you can access the web UI and manage the users form there.

### Add Server (SSH)

```bash
teleport tctl nodes add
```

This will output the command to execute on the client to connect to teleport.

To use an ssh reverse tunnel replace the port of the command output with `443` (when using in conjunction with `traefik`) or `3080`.

You may need to add the flag `--insecure` to the command.

Additional Note: On Arch Linux you can install the teleport client from AUR with `paru -Sy teleport-bin`.

### Add Application (HTTPS)

```bash
tctl tokens add --type=app --app-name=$APPNAME --app-uri=http://localhost:$APP_PORT
```

Adjust `$APPNAME` and `$APP_PORT` as needed.

Use the output command on your client to activate the application binding. You may need to add the flag `--insecure` to the command.

#### Example

On Teleport Server run:

```bash
tctl tokens add --type=app --app-name=grafana --app-uri=http://localhost:3000
```

This will output the command:

```bash
teleport app start \
    --token=340443c2261400533777b4c5607f8123 \
    --ca-pin=sha256:e2836c63812d4c5d2478a3db48330d055f9ffd2cdbfc13f2a2368b867bdc9123 \
    --auth-server teleport.example.lan:443 \
    --name=grafana \
    --uri=http://locahost:3000
```

On Client we start the example application with:

```bash
docker run -d --rm -p 3000:3000 grafana/grafana
```

Then we connect the application to teleport with:

```bash
sudo teleport app start \
    --token=340443c2261400533777b4c5607f8123 \
    --ca-pin=sha256:e2836c63812d4c5d2478a3db48330d055f9ffd2cdbfc13f2a2368b867bdc9123 \
    --auth-server teleport.example.lan:443 \
    --name=grafana \
    --uri=http://locahost:3000 \
    --insecure
```

## Troubleshoot

### Connection with `--insecure` flag not working

Example output:

```
ERRO [PROC:1]    Failed to resolve tunnel address: json: cannot unmarshal number into Go value of type webclient.PingResponse pid:514.1 reversetunnel/transport.go:87
ERRO [PROC:1]    Node failed to establish connection to Teleport Proxy. We have tried the following endpoints: pid:514.1 service/connect.go:1113
ERRO [PROC:1]    - connecting to auth server directly: connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority" pid:514.1 service/connect.go:1114
ERRO [PROC:1]    - connecting to auth server through tunnel: connection error: desc = "transport: Error while dialing failed to dial: json: cannot unmarshal number into Go value of type webclient.PingResponse" pid:514.1 service/connect.go:1118
ERRO [PROC:1]    Was this node already registered to a different cluster? To join this node to a new cluster, remove `/var/lib/teleport` and try again pid:514.1 service/connect.go:268
ERRO [PROC:1]    "Node failed to establish connection to cluster: Failed to connect to Auth Server directly or over tunnel, no methods remaining.\n\tconnection error: desc = \"transport: authentication handshake failed: x509: certificate signed by unknown authority\" pid:514.1 service/connect.go:119
ERRO [PROC:1]    Node failed to establish connection to Teleport Proxy. We have tried the following endpoints: pid:514.1 service/connect.go:1113
ERRO [PROC:1]    - connecting to auth server directly: connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority" pid:514.1 service/connect.go:1114
ERRO [PROC:1]    - connecting to auth server through tunnel: connection error: desc = "transport: Error while dialing failed to dial: json: cannot unmarshal number into Go value of type webclient.PingResponse" pid:514.1 service/connect.go:1118
ERRO [PROC:1]    Was this node already registered to a different cluster? To join this node to a new cluster, remove `/var/lib/teleport` and try again pid:514.1 service/connect.go:268
ERRO [PROC:1]    "Instance failed to establish connection to cluster: Failed to connect to Auth Server directly or over tunnel, no methods remaining.\n\tconnection error: desc = \"transport: authentication handshake failed: x509: certificate signed by unknown authority\" pid:514.1 service/connect.go:119
INFO [PROC:1]    Connecting to the cluster teleport.server02.lan with TLS client certificate. pid:514.1 service/connect.go:258
ERRO [PROC:1]    Failed to resolve tunnel address: json: cannot unmarshal number into Go value of type webclient.PingResponse pid:514.1 reversetunnel/transport.go:87
ERRO [PROC:1]    Node failed to establish connection to Teleport Proxy. We have tried the following endpoints: pid:514.1 service/connect.go:1113
ERRO [PROC:1]    - connecting to auth server directly: connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority" pid:514.1 service/connect.go:1114
ERRO [PROC:1]    - connecting to auth server through tunnel: connection error: desc = "transport: Error while dialing failed to dial: json: cannot unmarshal number into Go value of type webclient.PingResponse" pid:514.1 service/connect.go:1118
ERRO [PROC:1]    Was this node already registered to a different cluster? To join this node to a new cluster, remove `/var/lib/teleport` and try again pid:514.1 service/connect.go:268
ERRO [PROC:1]    "Node failed to establish connection to cluster: Failed to connect to Auth Server directly or over tunnel, no methods remaining.\n\tconnection error: desc = \"transport: authentication handshake failed: x509: certificate signed by unknown authority\" pid:514.1 service/connect.go:119
```

Solution: `sudo rm -rf /var/lib/teleport/` then run the connect command again
