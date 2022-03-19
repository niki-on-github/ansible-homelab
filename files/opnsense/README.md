# OPNsense

We download the OPNsense SSH key to this directory after deployment.

## Usage

```bash
ssh vagrant@$ROUTER_IP -i "private_key"
scp -i private_key vagrant@ROUTER_IP:/usr/local/etc/config.xml .
```

## Fix Update Problems

ssh into your opnsense and switch to root user with `su root`. Then run:

```bash
opnsense-bootstrap
```

for an update use:

```bash
opnsense-update
```
