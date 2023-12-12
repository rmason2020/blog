<# Sensor installation using cblauncher #>

<# place holder x64\cblauncher.exe download url #>
$ph_cblauncher_url_x64 = "https://prod.cwp.carbonblack.io/cblauncher/windows/us/1.3.0.451-21839045/x64/cblauncher.exe"

<# place holder  Win32\cblauncher.exe download url #>
$ph_cblauncher_url_Win32 = "https://prod.cwp.carbonblack.io/cblauncher/windows/us/1.3.0.451-21839045/win32/cblauncher.exe"

<# place holder sensor kit(x64) download url #>
$ph_sensorkit_url_x64 = "https://content.carbonblack.io/eap01/windows/installer_vista_win7_win8-64-4.0.0.1292.msi?Expires=1702637156&Signature=X0K98Scop7SA3~itzbsZKRAXRdI-cLoamS25c47EsOATGsqEWrndiWxMf3AGL0wISQmSSKYf10lpjonfZQs5gwjFKIHzGJC89ENJfyKKSv6gtWJuowow7DTDO-Z5FzbxglTbWDqgoAQXdKLqTlHuB8NYH7pIs9Lf5kqcBhHTCFOofIiW1Jw81YxC6pLOA3UoeHY3OmJs0cw5JV48xrKayJwRIcJfZ2E9et46vPIkXuu~uNFUtk0nHMcQI-pSeZgJQZddGLOzZunu~RFAQjPH9LB0lv9FDremblyzWkG-zpoBomDkfMjocVyryBHKbY54cFOWC4oNHRb5eje-yKONrg__&Key-Pair-Id=APKAIPKWLAKHF47JG5QA"

<# place holder sensor kit(Win32) download url #>
$ph_sensorkit_url_Win32 = ""

<# place holder cfg.ini download url #>
$ph_config_url = "https://content.carbonblack.io/prod05-installer-config/5990f1a146ce03ddc537826f59df0eb76f8ac8653af2e07441017039f854282a/config-blob.ini?Expires=1702637156&Signature=bXdc77qNzfbNqfApqmzSt61DHL5c-eaPpPCL0Q9SRUE9wShJdenGOA7lNmJySncWvkrf0FU3Sfr4OwLv8ya66g-wqs3VVAYMAAG4vatoNIuUzBUEZAWPa~ddcgARaA5QggCTIUemruayhXohVEG4S5Kteh0YPW7mde5WE-iO6m1f-NBnjAyfAwGPVBNS12mGpQdVhL1cA298L5h6PnTr7J-zZOavopftqxDSJm7vX8c1Dd3-Z9B7lxiKhWltG906zWy1ZZXNkzs61lIe5VOAsTSTibeRw9ghvVpTM1jMp2Hf-LHIpBQIa3Ig2e-LXwZAMITpGkt9GkasGD280B2nlA__&Key-Pair-Id=APKAIPKWLAKHF47JG5QA"


<# Helper functions #>
<# Function for validating input/placeholder urls #>
function ValidateInputUrls([string]$exeurl, [string]$sensorkiturl, [string]$cfgurl)
{
	if([string]::IsNullOrWhitespace($exeurl))
	{
		Write-Host ("Invalid cblauncher url...") -NoNewline -ForegroundColor red
		return $False
	}
	
	if([string]::IsNullOrWhitespace($sensorkiturl))
	{
		Write-Host ("Invalid sensorkit url...") -NoNewline -ForegroundColor red
		return $False
	}
	
	if([string]::IsNullOrWhitespace($cfgurl))
	{
		Write-Host ("Invalid config url...") -NoNewline -ForegroundColor red
		return $False
	}
	return $True
}

<# Function for cleaning up zip, extracted folder and files#>
function CleanUpTempFileAndFolders([string]$tempfileloc, [string]$tempfolder)
{
    <# Cleanup downloaded file #>
	$RemoveErrCode = $null
	$FolderRemoveErrCode = $null
	Write-Host ("Cleaning file...") -NoNewline
	try{
		Remove-Item -LiteralPath $tempfileloc -Force -ErrorVariable RemoveErrCode -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
		Write-Host ($tempfileloc + " succeeded") -ForegroundColor DarkGreen
	}
	catch{
		Write-Host ("Failed to cleanup downloaded file : " + $RemoveErrCode) -ForegroundColor red
	}
	
	<# Cleanup cblauncher temp folder #>
	Write-Host ("Cleaning folder...") -NoNewline
	try{
		Remove-Item -LiteralPath $tempfolder -Force -Recurse -ErrorVariable FolderRemoveErrCode -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
		Write-Host ($tempfolder + " succeeded") -ForegroundColor DarkGreen
	}
	catch{
		Write-Host ("Failed to cleanup folder (" + $tempfolder + "), Error : " + $FolderRemoveErrCode) -ForegroundColor red
	}
	
	if($RemoveErrCode -ne $null -OR $FolderRemoveErrCode -ne $null)
	{
		return $False
	}
	
	return $True
}

<# Function for downloading cblauncher from specified url #>
function DownloadCbLauncherExe([string]$inputurl, [string]$opfilename)
{
	try{
		$Response = (Invoke-WebRequest -Uri $inputurl -OutFile $opfilename -ErrorAction Stop)
		$global:downloadstatus = $Response.StatusCode
		return $True
	}
	catch{
		$global:downloadstatus = $_.Exception.Response.StatusCode.value__ 
	}
	return $False
}

<# Function for cblauncher signature validation #>
function IsCbLauncherSignatureValid([string]$cblfilepath)
{
	$sigcheckres = (Get-AuthenticodeSignature -FilePath $cblfilepath).Status
	if($sigcheckres -eq 'Valid')
	{
		return $True
	}
	return $False
}

<# Function for launching cblauncher to download sensor kit, cfg.ini and install #>
function StartCbLauncher([string]$cblexepath, [string]$sensorurl, [string]$cfgurl)
{
	$arguments = "--installtype WS1 " + "--installtask SENSOR_INSTALL " + "--pkgurl " + "`"$sensorurl`"" + " --cfgurl " + "`"$cfgurl`""
	$processlaunchres = (Start-Process $cblexepath -ArgumentList $arguments -PassThru -Wait) 
	if($processlaunchres.ExitCode -eq 0)
	{
		return $True
	}
	else
	{
		Write-Host ("ExitCode " + $processlaunchres.ExitCode) -ForegroundColor red
		return $False
	}
}

<# Function for checking if sensor is installed correctly and sensor service is configured #>
function IsSensorInstalled()
{
	$ServiceName = 'CbDefense'
	$CbService = (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)
	if ($CbService -ne $null -and $CbService.Status -eq 'Running' -or $CbService.Status -eq 'Stopped')
	{
		Write-Host ("Sensor service " + $ServiceName + " is "+ $CbService.Status +"...") -NoNewline -ForegroundColor DarkGreen
		return $True
	}
	else
	{
		Write-Host ("Sensor service " + $ServiceName + " not found ") -NoNewline -ForegroundColor red
		return $False
	}
}

<# Function for checking os architecture/platform #>
function IsRunningOnx64()
{
	if([System.Environment]::Is64BitOperatingSystem)
	{
		return $True
	}
	else
	{
	    return $False
	}
}

<# Function for encapsulating download and sensor installation #>
function DownloadAndInstallSensor([string]$cblauncherroot, [string]$cblauncherpath, [string]$cblurl, [string]$sensorurl, [string]$cfgurl)
{	
	<# Validate inputs/placeholders#>
	Write-Host ("Validating input urls...") -NoNewline
	$isvalidinputs = ValidateInputUrls $cblurl $sensorurl $cfgurl
	if($isvalidinputs -eq $False)
	{
		Write-Host ("validation failed") -ForegroundColor red
		return $false
	}
	
	Write-Host ("validation succeeded") -ForegroundColor DarkGreen
	Write-Host ("Downloading cblauncher...") -NoNewline
	$downloadres = DownloadCbLauncherExe $cblurl $cblauncherpath
	if($downloadres)
	{
		Write-Host ("Download succeeded") -ForegroundColor DarkGreen
		Write-Host ("Checking cblauncher signature...") -NoNewline
		$issigvalid  = IsCbLauncherSignatureValid $cblauncherpath
		if($issigvalid)
		{
			Write-Host ("Signature validation succeeded") -ForegroundColor DarkGreen
			Write-Host ("Starting cblauncher for downloading sensor kit and install...") -NoNewline
			$startcblres = StartCbLauncher $cblauncherpath $sensorurl $cfgurl
			if($startcblres)
			{
				Write-Host ("cblauncher succeeded") -ForegroundColor DarkGreen
				Write-Host ("Checking sensor service status...") -NoNewline
				$sensorserviceres = IsSensorInstalled
				if($sensorserviceres)
				{
					Write-Host ("Check status succeeded") -ForegroundColor DarkGreen
					return $true
				}
				else
				{
					Write-Host ("Check status failed") -ForegroundColor red
					$global:lasterror = "sensor_install_failed"
					return $false
				}
			}
			else
			{
				Write-Host ("cblauncher failed") -ForegroundColor red
				$global:lasterror = "cblauncher_failed"
				return $false
			}
		}
		else
		{
			Write-Host ("Signature validation failed") -ForegroundColor red
			$global:lasterror = "invalid_signature"
			return $false
		}
	}
	else
	{
		Write-Host ("Download cblauncher failed, Error = " + $global:downloadstatus) -ForegroundColor red
		$global:lasterror = "download_failure"
		return $false
	}
}

<# Variables #>
$global:lasterror = "unknown"
$global:downloadstatus =$null

$cbroot = "c:\cbtemp"
$cblauncherroot = $cblroot + "\cblauncher"
$cblogfile = $cbroot + "\azure_user_data_script.log"

<# Create temp folder for log and downloading files #>
$tempfolderres = New-Item -Path $cbroot -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

<# Start Logging #>
Start-Transcript -Path $cblogfile -IncludeInvocationHeader 

<# By default on older versions powershell uses TLS 1.0, so added to support site which requires TLS 1.2 #>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$configurl = $ph_config_url

<# Detect os architecture/platform and select appropriate urls/paths #>
Write-Host ("Detecting OS Architecture...") -NoNewline
if(IsRunningOnx64)
{
	$cblauncherurl = $ph_cblauncher_url_x64
	$cblauncherplatformfolder = $cblauncherroot +"\x64"
	$cblauncherpath = $cblauncherplatformfolder  + "\cblauncher.exe"
	$sensorkiturl = $ph_sensorkit_url_x64
	Write-Host ("Running on x64") -ForegroundColor DarkGreen
}
else
{
	$cblauncherurl = $ph_cblauncher_url_Win32
	$cblauncherplatformfolder = $cblauncherroot +"\Win32"
	$cblauncherpath =  $cblauncherplatformfolder + "\cblauncher.exe"
	$sensorkiturl = $ph_sensorkit_url_Win32
	Write-Host ("Running on Win32") -ForegroundColor DarkGreen
}

<# Create temp folder for cblauncher#>
New-Item -Path $cblauncherplatformfolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

<# Download and Install sensor #>
$SensorInstallRes = $false
$SensorInstallRes = DownloadAndInstallSensor $cblauncherroot $cblauncherpath $cblauncherurl $sensorkiturl $configurl
Write-Host ("--------------------------------------------------------------------------------")
if($SensorInstallRes -eq $true)
{	
	Write-Host ("Sensor installation succeeded") -ForegroundColor DarkGreen
}
else
{
	Write-Host ("Sensor installation failed with Error : " + $lasterror) -ForegroundColor red
}
Write-Host ("--------------------------------------------------------------------------------")

<# Cleanup temp files and folders #>
Write-Host ("Cleanup temp files and folders...")
$ClnupRes = CleanUpTempFileAndFolders  $cblauncherpath $cblauncherroot

Stop-Transcript
