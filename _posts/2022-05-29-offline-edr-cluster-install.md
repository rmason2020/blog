---
title: 'Offlien EDR Cluster Install'
author: RichMason
layout: post
permalink: /offline-cluster/
categories:
  - edr
---

Sometimes you may need to install an EDR cluster in an offline environment.  The key thing here is to create the yum cache files, transfer to each server and install with yum before adding teh minions using cbcluster.


These steps do not include sizing / partitioning the data storage etc which should be done before cb is installed.


Create the cache files and install each server upto step 6 as per this link, so yum will create folders, install binaries etc but stop there.


https://docs.vmware.com/en/VMware-Carbon-Black-EDR/7.6/cb-edr-scm-guide/GUID-030B9F57-2484-4C80-AE61-930A64672A16.html


On the primary server run cbinit but make this server eventless, it will be responsible for managing the cluster but will not collect or store events.


/usr/share/cb/cbinit --no-solr-events


On the primary server add the minion nodes


/usr/share/cb/cbcluster add-node


https://docs.vmware.com/en/VMware-Carbon-Black-EDR/7.6/cb-edr-scm-guide/GUID-5379FF1B-0209-48F8-8874-5C1407240256.html![image](https://user-images.githubusercontent.com/67588723/175943318-cad66b0a-b998-49d8-a5ef-64ff4dc47aae.png)
