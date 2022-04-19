---
title: 'Install Virtual MacOS Monterey on VM Fusion'
author: RichMason
layout: post
permalink: /monterey-fusion/
dsq_thread_id:
  - 1204965956
categories:
  - Poker
---
Install MacOS Monterey in Fusion

Download the Installer from AppStore but cancel once download finishes.

hdiutil create -size 15G -fs hfs+ -volname macOSInstaller -type SPARSEBUNDLE /Users/Shared/macOSInstaller

hddiutil attach /Users/Shared/macOSInstaller.sparsebundle

sudo /Applications/Install\ macOS\ Monterey/Contents/Resources/createinstallmedia --volume /Volumes/macOSInstaller —nointeraction

hdiutil makehybrid -o /Users/Shared/macOSInstaller /Users/Shared/macOSInstaller.sparsebundle
