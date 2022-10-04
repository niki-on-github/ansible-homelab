# Cluster Secrets

## Encrypt

```bash
sops --age=$AGE_PUBLIC_KEY --encrypt --encrypted-regex '^(data|stringData)$' --in-place ./cluster-secrets.example.yaml
```

with `AGE_PUBLIC_KEY` from `/opt/k3d/.age/sops.agekey`.

## Decrypt

```bash
sops --decrypt --in-place ./cluster-secrets.example.yaml
```

## Edit Secrets on new PC

Add the `AGE-SECRET-KEY` from `/opt/k3d/.age/sops.agekey` to `~/.config/sops/age/keys.txt` (Create the file if does not exists). Now you can use the sops encrypt and decrypt commands on your computer.
