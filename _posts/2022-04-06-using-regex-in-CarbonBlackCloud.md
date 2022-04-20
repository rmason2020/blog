---
title: "Using Regex to Search Carbon Black Cloud Events"
date: "2022-04-06"
author: RichMason
description: "Using Regex to Search Carbon Black Cloud Events"
tags: [
    "regex",
    "carbon black"
]
---

For more detailed information and further examples see [Carbon Black Advanced Search Tips](https://community.carbonblack.com/t5/Carbon-Black-Cloud-Knowledge/Advanced-search-tips-for-Carbon-Black-Cloud-Platform-Search/ta-p/93230?attachment-id=17574)

This documentation is compatible with [Platform Search](https://www.elastic.co/guide/en/elasticsearch/reference/current/regexp-syntax.html)

This [regex validator](https://regex101.com) produces compatible results:

## Examples

Search process only in root of C drive, not in subfolders, ie c:\test.exe not c:\folder\test.exe.  Note the regex is surrounded by / / and this renders all backslashes to forward slashes.
This search is saying seach for c:\ then anything but a slash [^\/] one or moe times.  The path can't have any slash/folders in it

```
process_name:/c\:\/[^\/]{1,}/ OR childproc_name:/c\:\/[^\/]{1,}/  OR crossproc_name:/c\:\/[^\/]{1,}/

process_name:/c\:\/[^\/]{1,}/
```

Similarly a process in root of temp with no subfolders.

```
childproc_name:/c\:\/users\/administrator.richm\/appdata\/local\/temp\/[^\/]{1,}/ OR process_name:/c\:\/users\/administrator.richm\/appdata\/local\/temp\/[^\/]{1,}/
```

Fuzzy search will look for similar domain matches, you might pick up phising mails as they attemp to trick users to visit a site that looks similar to the one they think they are connecting to.

```
netconn_domain:vmware.com~ AND -netconn_domain:vmware.com

netconn_domain:www.vmware.com~ AND -netconn_domain:www.vmware.com
```


Exclude domains, ie any domain except listed.  This helps as a normal search excluding a domain will remove that proces altogether.  Imagine of powershell always makes a connection in the background to microsoft.com whne it is launched.  If you used a normal search and excluded microsoft.com then you would exclude all powershell instances even if they subsequently made a malicious domain connection.
The special characters @&^ denote a regex for anthing but, so @&~(.*microsoft.com|.*office365.com) would only exclude powershell if it had only connected to microsoft or office365 but not if it had made a thoird domain connection.

```
process_name:powershell.exe AND netconn_domain:/[^.]+(\.[^.]+)+&@&~(.*microsoft.com|.*rb.net|.*office365.com|.*windowsupdate.com|.*microsoftonline.com|.*verisign.com|.*service-now.com|.*sfx.ms|.*sharepoint.com|.*mjn.com|.*virtualearth.net|.*windows.net|.*azureedge.net|.*trafficmanager.net|.*okta.com|.*azure-automation.net|.*bing.com|.*msauth.net|.*live.com|.*powershellgallery.com|.*msftauthimages.net|.*symcb.com|.*oktacdn.com|.*digicert.com|.*siemens.com|.*quovadisglobal.com|.*msftauth.net|.*169.254.169.254|.*local|.*zscloud.net|.*powerbi.com)/
```

Like the above this will seach for any executable in a folder except .exe, .ps1 or .dll

```
process_name:C\:\\Windows\\System32\\* AND process_name:/@&~(.*ps1|.*exe|.*msi)/ 

process_name:C\:\\Windows\\SysWOW64\\* AND process_name:/@&~(.*ps1|.*exe|.*dll|.*cpl|.*vbs|.*bat|.*cmd|.*scr|.*vbe|.*msc|.*wsf|.*com|.*dat|.*msi|.*hta|.*tmp|.*bin|.*ocx|.*ē)/
```
