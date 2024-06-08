# Ansible Homelab


> [!WARNING]  
> This repository is no longer used by me and has been replaced by my [nixos-k3s](https://github.com/niki-on-github/nixos-k3s) repository.

This repo contains the Ansible playbooks and configuration used to manage and automate my arch based homelab. Feel free to look around. Be aware that I have configured my environment to fit my workflow.

## Setup

### Install Ansible dependencies

```bash
ansible-galaxy install -r requirements.yml
```

### SSH Key login

```bash
ssh-keygen -a 100 -t ed25519 -f ~/.ssh/$KEYNAME -N "" -C ""
ssh-copy-id -i ~/.ssh/$KEYNAME.pub USER@SERVER_IP
```

### Store Passwords

```bash
ansible-vault create ./playbooks/host_vars/$INVENTORY_HOSTNAME/secret.yml
ansible-vault edit ./playbooks/host_vars/$INVENTORY_HOSTNAME/secret.yml
```

## Deploy

### supermicro server

```bash
ansible-playbook -i ./inventory/testserver_01 ./playbooks/filesystem.yml -K --ask-vault-password
ansible-playbook -i ./inventory/testserver_01 ./playbooks/opnsense-install.yml -K --ask-vault-password
ansible-playbook -i ./inventory/testserver_01 ./playbooks/docker.yml -K --ask-vault-password
ansible-playbook -i ./inventory/testserver_01 ./playbooks/backup.yml -K --ask-vault-password
ansible-playbook -i ./inventory/opnsense_01 ./playbooks/opnsense-configure.yml
```
