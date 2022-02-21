# Ansible Homelab

This repo contains the Ansible playbooks and configuration used to manage and automate my arch based homelab. Feel free to look around. Be aware that I have configured my environment to fit my workflow. Still **WIP**

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

Test connection:

```bash
ansible all -m ping
```

### Store Passwords

```bash
ansible-vault create ./inventory/group_vars/$GROUP_NAME/$HOSTNAME/secret.yml
ansible-vault edit ./inventory/group_vars/$GROUP_NAME/$HOSTNAME/secret.yml
```

## Deploy

Adjust the `domain` variable and create an entry in your DNS server for the new server.

```bash
ansible-playbook -i ./inventory/testserver01 ./playbooks/docker.yml -K --ask-vault-password
```
