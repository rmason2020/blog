---
title: 'Getting Started with Photon OS'
author: RichMason
layout: post
permalink: /photon-os/
categories:
  - edr
---

In anticipation of EDR being supported on Photon OS later this summer these are a few steps to get up and running with a new Photon server.

https://github.com/vmware/photon/wiki/Downloading-Photon-OS

https://github.com/vmware/photon/wiki

 - Username: ``root``
 - Password: ``changeme``

Permit ssh if needed

```
vi /etc/ssh/sshd_config

Set PermitRootLogin yes
```

Set static ip

```
networkctl


cat > /etc/systemd/network/10-static-en.network << "EOF"
[Match]
Name=eth0
[Network]
Address=192.168.0.195/24
Gateway=192.168.0.254
DNS=192.168.0.10
EOF

chmod 644 10-static-en.network
systemctl restart systemd-networkd
```

Disable dhcp change yes to no

```
cat /etc/systemd/network/99-dhcp-en.network
[Match]
Name=e*
[Network]
DHCP=yes

systemctl restart systemd-networkd

chage -I -1 -m 0 -M 3650 -E -1 root    (minus capital I, minus one, minus one)
```

