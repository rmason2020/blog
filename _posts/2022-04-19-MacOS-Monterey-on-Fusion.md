---
title: 'Install Virtual MacOS Monterey on VM Fusion'
author: RichMason
layout: post
permalink: /monterey-fusion/
categories:
  - Tech
---
This post is to remind me the steps I took to Install MacOS Monterey in Fusion so I could test installing Carbon Black on my work Mac.

Download the Installer from AppStore but cancel once download finishes.

```bash
hdiutil create -size 15G -fs hfs+ -volname macOSInstaller -type SPARSEBUNDLE /Users/Shared/macOSInstaller
```

```bash
hddiutil attach /Users/Shared/macOSInstaller.sparsebundle
```

```bash
sudo /Applications/Install\ macOS\ Monterey/Contents/Resources/createinstallmedia --volume /Volumes/macOSInstaller —nointeraction
```

```bash
hdiutil makehybrid -o /Users/Shared/macOSInstaller /Users/Shared/macOSInstaller.sparsebundle
```
