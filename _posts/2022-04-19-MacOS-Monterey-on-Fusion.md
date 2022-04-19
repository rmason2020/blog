---
title: 'Install Virtual MacOS Monterey on VM Fusion'
author: RichMason
layout: post
categories:
  - Tech
---
This post is to remind me the steps I took to Install MacOS Monterey in Fusion so I could test installing Carbon Black on my work Mac.

Download the Installer from AppStore but cancel once download finishes.

```
hdiutil create -size 15G -fs hfs+ -volname macOSInstaller -type SPARSEBUNDLE /Users/Shared/macOSInstaller

hddiutil attach /Users/Shared/macOSInstaller.sparsebundle

sudo /Applications/Install\ macOS\ Monterey/Contents/Resources/createinstallmedia --volume /Volumes/macOSInstaller —nointeraction

hdiutil makehybrid -o /Users/Shared/macOSInstaller /Users/Shared/macOSInstaller.sparsebundle
```
