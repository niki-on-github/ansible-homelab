# Apache Guacamole

Apache Guacamole is a clientless remote desktop gateway that allows you to connect to computers/servers from anywhere and any time by only using a web browser. Apache Guacamole supports multiple standard remote access protocols such as SSH, VNC, and RDP.

## Setup

The default username is `guacadmin` with password `guacadmin`

## SSH not working

Guacamole doesn’t support the new key format of the latest OpenSSH. To get a working connection you have to add `HostKeyAlgorithms +ssh-rsa` to `/etc/ssh/sshd_config` for now.
