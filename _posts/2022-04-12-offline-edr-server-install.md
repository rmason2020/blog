---
title: "Offline Install of Carbon Black EDR Server"
date: "2022-04-12"
author: RichMason
description: "Offline Install of Carbon Black EDR Server"
tags: [
    "edr",
    "carbon black"
]
---

Sometimes a customer wants to install EDR into an airgapped environment and even installing the server becomes a challenge.  Using a redHat Satellite sever is one option (copy the cert and key to Satellite to authenticate our repository) but if this is noit available these steps using a caching server to download thge files is an option.

Upload the provided "carbon-black-release" RPM file to your staging ("caching") server. 
		Example file name: carbon-black-release-1.0.2-1-My_Company.x86_64.rpm

Install that file onto the caching server:

```bash
rpm -ivh <carbon-black-release-file>
```

Edit /etc/yum.conf, and set:

```bash
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=1
```

Run:  

```bash
yum upgrade cb-enterprise
```

Tar up the Yum cache directory:

```bash
tar --selinux -cvzf yumcache.tar.gz -C /var/cache/yum/x86_64/7/ .
```

Take the resulting file (yumcache.tar.gz) and move it to the desired offline server.

Log into the offline CB Response server CLI

If necessary, create the following folder hierarchy:

```bash
mkdir /var/cache/yum/x86_64/7/
```

Untar the file to the local offline server:

```bash
tar -xvzf yumcache.tar.gz -C /var/cache/yum/x86_64/7/
```

Install CB Response as normal, but flag it (with -C) to only use the local cache, which will pull the RPM files from the local yum cache directory that was just created.

```bash
yum install -C cb-enterprise
```

