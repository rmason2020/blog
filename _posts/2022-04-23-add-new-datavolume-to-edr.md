---
title: 'New Data Volume on EDR'
author: RichMason
layout: post
tags: [
    "edr",
    "carbon black"
]
---

In order to correctly build and provision an EDR server, at a minimum, the data partition should be on it's own logical volume.  This enables the partition to be placed on fast disks seperate from the underlying oS, allows for easier resizing and prevents issues around partitions filling with other files that weren't anticipated in that location.

The below steps can and should be replicated to include volumes for data (/var/cb/data), events (/var/cb/data/solr/cbevents), logs (/var/log/cb) , binaries (/var/cb/data/modulestore) etc

Beware that if creating /var/cb/data and /var/cb/data/solr/cbevents on sperate volumes the first must be mounted before the second due to teh parent child relationship between the directories.

```bash
# fdisk /dev/sdc

Command (m for help): p
Command (m for help): n
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-209715199, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-209715199, default 209715199):
Using default value 209715199
Partition 1 of type Linux and of size 100 GiB is set

Command (m for help): t
Selected partition 1
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'
Command (m for help): w
The partition table has been altered!

# pvcreate /dev/sdc1
  Physical volume "/dev/sdc1" successfully created.
# vgcreate vgdata2 /dev/sdc1
  Volume group "vgdata2" successfully created
# lvcreate --extent 100%FREE -n lvdata2 vgdata2
  Logical volume "lvdata2" created.
# mkfs.xfs /dev/vgdata2/lvdata2
meta-data=/dev/vgdata2/lvdata2   isize=512    agcount=4, agsize=6488064 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=25952256, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=12672, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

# mkdir /var/cb/data/solr/cbevents
# mount /dev/mapper/vgdata2-lvdata2 /var/cb/data/solr/cbevents/
# vi /etc/fstab
# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Tue Jun  9 16:19:29 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=8c1edfc5-81f9-4a41-a44a-a1ff41df4c3a /boot                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0
m
/dev/mapper/vgdata2-lvdata2 /var/cb/data/solr/cbevents          xfs     defaults        1 2

# mount -a            < test fstab file>

# df -h
Filesystem                   Size  Used Avail Use% Mounted on
devtmpfs                     3.8G     0  3.8G   0% /dev
tmpfs                        3.9G   52K  3.9G   1% /dev/shm
tmpfs                        3.9G   12M  3.8G   1% /run
tmpfs                        3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/mapper/centos-root       44G  2.6G   42G   6% /
/dev/sda1                   1014M  150M  865M  15% /boot
/dev/mapper/vgdata-lvdata     99G  1.1G   98G   2% /var/cb/data
tmpfs                        781M     0  781M   0% /run/user/0
/dev/mapper/vgdata2-lvdata2   99G   33M   99G   1% /var/cb/data/solr/cbevents
```
