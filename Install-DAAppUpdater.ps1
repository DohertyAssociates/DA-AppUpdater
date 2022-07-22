<#
.SYNOPSIS
Configure Winget to daily update installed apps.

.DESCRIPTION
Install powershell scripts and scheduled task to daily run Winget upgrade and notify connected users.
Possible to exclude apps from auto-update by adding the winget ID to the excluded_apps.txt file.
Customised from work by https://github.com/Romanitho/Winget-AutoUpdate

.PARAMETER Silent
Install DA-AppUpdater and prerequisites silently

.PARAMETER InstallPath
Specify DA-AppUpdater installation location. Default: %ProgramData%\DA-AppUpdater\

.PARAMETER DoNotUpdate
Do not run DA-AppUpdater after installation. By default, DA-AppUpdater is run just after installation.

.PARAMETER UpdatesAtLogon
Set DAAU to run at user logon.

.PARAMETER UpdatesInterval
Specify the update frequency: Daily (Default), Weekly, Biweekly or Monthly.

.PARAMETER DisableDAAUAutoUpdate
Disable DA-AppUpdater update checking. By default, DAAU will auto update if new release is available on Github.

.PARAMETER DisableDAAUPreRelease
Disable DA-AppUpdater update checking for releases marked as "pre-release". By default, DAAU will auto update to stable releases.

.PARAMETER UseWhiteList
Use White List instead of Black List. This setting will not create the "exclude_apps.txt" but instead "include_apps.txt"

.PARAMETER NotificationLevel
Specify the Notification level: Full (Default, displays all notification), SuccessOnly (Only displays notification for success) or None (Does not show any popup).

.EXAMPLE
.\Install-DAAppUpdater.ps1 -Silent -DoNotUpdate

.EXAMPLE
<<<<<<< HEAD
.\winget-install-and-update.ps1 -Silent -UseWhiteList -DoNotUpdate

.EXAMPLE
.\winget-install-and-update.ps1 -Silent -UpdatesAtLogon -UpdatesInterval Weekly
=======
.\Install-DAAppUpdater.ps1 -Silent -UseWhiteList -DoNotUpdate

.EXAMPLE
.\Install-DAAppUpdater.ps1 -Silent -UpdatesAtLogon -UpdatesInterval Weekly
>>>>>>> 8c82678 (Initial Commit)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)] [Alias('S')] [Switch] $Silent = $false,
    [Parameter(Mandatory=$False)] [Alias('Path')] [String] $DAAUPath = "$env:ProgramData\DA-AppUpdater",
    [Parameter(Mandatory=$False)] [Switch] $DoNotUpdate = $false,
    [Parameter(Mandatory=$False)] [Switch] $UpdatesAtLogon = $false,
    [Parameter(Mandatory=$False)] [ValidateSet("Daily","Weekly","BiWeekly","Monthly")] [String] $UpdatesInterval = "Daily",
    [Parameter(Mandatory=$False)] [Switch] $DisableDAAUAutoUpdate = $false,
    [Parameter(Mandatory=$False)] [Switch] $DisableDAAUPreRelease = $false,
    [Parameter(Mandatory=$False)] [Switch] $UseWhiteList = $false,
    [Parameter(Mandatory=$False)] [ValidateSet("Full","SuccessOnly","None")] [String] $NotificationLevel = "Full"
)

<# VARS #>
#Log Name
$Script:LogFile = "DAAppUpdater-$env:COMPUTERNAME.log"
$Script:WebClient = New-Object System.Net.WebClient

<<<<<<< HEAD
=======
<# APP INFO #>

$DAUVersion = "1.5.2"

>>>>>>> 8c82678 (Initial Commit)
<# FUNCTIONS #>
function Start-DALogging {  
    # Create DA Directories
    Write-Host "Creating Tech Directory"
    New-Item -ItemType "Directory" -Path "$env:systemdrive\Tech" -Force -ErrorAction SilentlyContinue
    Write-Host "Creating Temp Directory"
    New-Item -ItemType "Directory" -Path "$env:systemdrive\Temp" -Force -ErrorAction SilentlyContinue
    # Create ProgramData\Doherty Associates Subfolders
    Write-Host "Creating ProgramData\Doherty Associates Directory and Sub-Folders"
    New-Item -ItemType "Directory" -Path "$env:systemdrive\ProgramData\Doherty Associates\" -Force -ErrorAction SilentlyContinue
    $Script:DALogsFolder = New-Item -ItemType "Directory" -Path "$env:systemdrive\ProgramData\Doherty Associates\Logs" -Force -ErrorAction SilentlyContinue
    $Script:DAScriptsFolder = New-Item -ItemType "Directory" -Path "$env:systemdrive\ProgramData\Doherty Associates\Scripts" -Force -ErrorAction SilentlyContinue
    $Script:DAInstallerFolder = New-Item -ItemType "Directory" -Path "$env:systemdrive\ProgramData\Doherty Associates\Installers" -Force -ErrorAction SilentlyContinue
    
    # Set transcript logging path
    Start-Transcript -Path $DALogsFolder\$LogFile -Append
    Write-Host "Current script timestamp: $(Get-Date -f yyyy-MM-dd_HH-mm)"
}

function Install-Prerequisites {
    #Check if Visual C++ 2019 or 2022 installed
    $Visual2019 = "Microsoft Visual C++ 2015-2019 Redistributable*"
    $Visual2022 = "Microsoft Visual C++ 2015-2022 Redistributable*"
    $path = Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.GetValue("DisplayName") -like $Visual2019 -or $_.GetValue("DisplayName") -like $Visual2022}
    
    #If not installed, ask for installation
    If (!($path)){
        #If -silent option, force installation
        If ($Silent){
            $InstallApp = 1
        }
        Else {
            #Ask for installation
            $MsgBoxTitle = "Winget Prerequisites"
            $MsgBoxContent = "Microsoft Visual C++ 2015-2022 is required. Would you like to install it?"
            $MsgBoxTimeOut = 60
            $MsgBoxReturn = (New-Object -ComObject "Wscript.Shell").Popup($MsgBoxContent,$MsgBoxTimeOut,$MsgBoxTitle,4+32)
            If ($MsgBoxReturn -ne 7) {
                $InstallApp = 1
            }
            Else {
                $InstallApp = 0
            }
        }
        #Install if approved
        If ($InstallApp -eq 1){
            Try {
                If ((Get-CimInStance Win32_OperatingSystem).OSArchitecture -like "*64*"){
                    $OSArch = "x64"
                }
                Else {
                    $OSArch = "x86"
                }
                Write-Host "Downloading VC_redist.$OSArch.exe..."
                $VCURL = "https://aka.ms/vs/17/release/VC_redist.$OSArch.exe"
                $VCInstaller = "$($DAInstallerFolder)\VC_redist.$OSArch.exe"
                $WebClient.DownloadFile($VCURL, $VCInstaller)
                Write-Host "Installing VC_redist.$OSArch.exe..."
                $Proc = Start-Process -FilePath $VCInstaller -Args "/quiet /norestart" -Wait -WindowStyle Hidden -PassThru -ErrorAction Continue
                $Proc.WaitForExit()
                Write-Host "MS Visual C++ 2015-2022 installed successfully. Exit code: $($Proc.ExitCode)" -ForegroundColor Green
            }
            Catch {
                Write-Host "MS Visual C++ 2015-2022 installation failed." -ForegroundColor Red
                Start-Sleep 3
            }
        }
        Else {
            Write-Host "MS Visual C++ 2015-2022 wil not be installed." -ForegroundColor Magenta
        }
    }
    Else {
        Write-Host "Prerequisites checked. OK" -ForegroundColor Green
    }
}

function Install-WinGet {
    #Check Package Install
    Write-Host "Checking if Winget is installed" -ForegroundColor Yellow
    $TestWinGet = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "Microsoft.DesktopAppInstaller"}
    If ([Version]$TestWinGet.Version -gt "2022.519.1908.0") {
        Write-Host "WinGet is Installed" -ForegroundColor Green
    }
    Else {
        #Download WinGet MSIXBundle
        Write-Host "Not installed. Downloading WinGet..."
        #$WinGetURL = "https://aka.ms/getwinget"
        $WinGetURL = "https://github.com/microsoft/winget-cli/releases/download/v1.3.1391-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" #Current preview version to allow install of MSStoreApps without MSA Account
        $WebClient.DownloadFile($WinGetURL, "$DAInstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")

        #Install WinGet MSIXBundle
        Try {
            Write-Host "Installing MSIXBundle for App Installer..."
            Add-AppxProvisionedPackage -Online -PackagePath "$DAInstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense
            Write-Host "Installed MSIXBundle for App Installer" -ForegroundColor Green
        }
        Catch {
            Write-Host "Failed to install MSIXBundle for App Installer..." -ForegroundColor Red
        } 
        
        #Remove WinGet MSIXBundle
        #Remove-Item -Path "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Force -ErrorAction Continue
    }
}

function Install-DAAppUpdater {
    Try{
        #Copy files to location
        If (!(Test-Path $DAAUPath)){
            New-Item -ItemType Directory -Force -Path $DAAUPath
        }
        Copy-Item -Path "$PSScriptRoot\DA-AppUpdater\*" -Destination $DAAUPath -Recurse -Force -ErrorAction SilentlyContinue
        
        #White List or Black List apps
        If ($UseWhiteList) {
            If (Test-Path "$PSScriptRoot\included_apps.txt"){
                Copy-Item -Path "$PSScriptRoot\included_apps.txt" -Destination $DAAUPath -Recurse -Force -ErrorAction SilentlyContinue
            }
            Else {
                New-Item -Path $DAAUPath -Name "included_apps.txt" -ItemType "file" -ErrorAction SilentlyContinue
            }
        }
        Else {
            Copy-Item -Path "$PSScriptRoot\excluded_apps.txt" -Destination $DAAUPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Set dummy regkeys for notification name and icon
        & reg add "HKCR\AppUserModelId\Windows.SystemToast.DAAU.Notification" /v DisplayName /t REG_EXPAND_SZ /d "Doherty App Updater" /f | Out-Null
        & reg add "HKCR\AppUserModelId\Windows.SystemToast.DAAU.Notification" /v IconUri /t REG_EXPAND_SZ /d $DAAUPath\icons\DAToastIcon.png /f | Out-Null

        # Settings for the scheduled task for Updates
        $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$($DAAUPath)\winget-upgrade.ps1`""
        $taskTriggers = @()
        If ($UpdatesAtLogon){
            $tasktriggers += New-ScheduledTaskTrigger -AtLogOn
        }
        If ($UpdatesInterval -eq "Daily"){
            $tasktriggers += New-ScheduledTaskTrigger -Daily -At 6AM
        }
        ElseIf ($UpdatesInterval -eq "Weekly"){
            $tasktriggers += New-ScheduledTaskTrigger -Weekly -At 6AM -DaysOfWeek 2
        }
        ElseIf ($UpdatesInterval -eq "BiWeekly"){
            $tasktriggers += New-ScheduledTaskTrigger -Weekly -At 6AM -DaysOfWeek 2 -WeeksInterval 2
        }
        ElseIf ($UpdatesInterval -eq "Monthly"){
            $tasktriggers += New-ScheduledTaskTrigger -Weekly -At 6AM -DaysOfWeek 2 -WeeksInterval 4
        }
        $taskUserPrincipal = New-ScheduledTaskPrincipal -UserId S-1-5-18 -RunLevel Highest
        $taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 03:00:00

        # Set up the task, and register it
        $task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Settings $taskSettings -Trigger $taskTriggers
        Register-ScheduledTask -TaskName 'DA-AppUpdater' -InputObject $task -Force | Out-Null

        # Settings for the scheduled task for Notifications
        $taskAction = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$($DAAUPath)\Invisible.vbs`" `"powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"`"`"$($DAAUPath)\winget-notify.ps1`"`""
        $taskUserPrincipal = New-ScheduledTaskPrincipal -GroupId S-1-5-11
        $taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8 -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 00:05:00

        # Set up the task, and register it
        $task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Settings $taskSettings
        Register-ScheduledTask -TaskName 'DA-AppUpdater-Notify' -InputObject $task -Force | Out-Null

        # Configure Reg Key
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DA-AppUpdater"
        New-Item $regPath -Force
        New-ItemProperty $regPath -Name DisplayName -Value "DA App Updater (DAAU)" -Force
        New-ItemProperty $regPath -Name DisplayIcon -Value "C:\ProgramData\DA-AppUpdater\icons\datray.ico" -Force
<<<<<<< HEAD
        New-ItemProperty $regPath -Name DisplayVersion -Value 1.5.0 -Force
        New-ItemProperty $regPath -Name InstallLocation -Value $WingetUpdatePath -Force
        New-ItemProperty $regPath -Name UninstallString -Value "powershell.exe -noprofile -executionpolicy bypass -file `"$WingetUpdatePath\DAAU-Uninstall.ps1`"" -Force
        New-ItemProperty $regPath -Name QuietUninstallString -Value "powershell.exe -noprofile -executionpolicy bypass -file `"$WingetUpdatePath\DAAU-Uninstall.ps1`"" -Force
=======
        New-ItemProperty $regPath -Name DisplayVersion -Value $DAUVersion -Force
        New-ItemProperty $regPath -Name InstallLocation -Value $DAAUPath -Force
        New-ItemProperty $regPath -Name UninstallString -Value "powershell.exe -noprofile -executionpolicy bypass -file `"$DAAUPath\DAAU-Uninstall.ps1`"" -Force
        New-ItemProperty $regPath -Name QuietUninstallString -Value "powershell.exe -noprofile -executionpolicy bypass -file `"$DAAUPath\DAAU-Uninstall.ps1`"" -Force
>>>>>>> 8c82678 (Initial Commit)
        New-ItemProperty $regPath -Name NoModify -Value 1 -Force
        New-ItemProperty $regPath -Name NoRepair -Value 1 -Force
        New-ItemProperty $regPath -Name VersionMajor -Value 1 -Force
        New-ItemProperty $regPath -Name VersionMinor -Value 5 -Force
        New-ItemProperty $regPath -Name Publisher -Value "Doherty Associates" -Force
        New-ItemProperty $regPath -Name DAAU_UpdatePrerelease -Value 0 -PropertyType DWord -Force
        New-ItemProperty $regPath -Name DAAU_NotificationLevel -Value $NotificationLevel -Force
        New-ItemProperty $regPath -Name DAAU_PostUpdateActions -Value 0 -PropertyType DWord -Force
        If ($DisableDAAUAutoUpdate) {New-ItemProperty $regPath -Name DAAU_DisableAutoUpdate -Value 1 -Force}
        If ($UseWhiteList) {New-ItemProperty $regPath -Name DAAU_UseWhiteList -Value 1 -PropertyType DWord -Force}

        Write-Host "`n DAAU Installation succeeded!" -ForegroundColor Green
        Start-sleep 1
        
        #Run Winget ?
        Start-DAAppUpdater
    }
    Catch {
        Write-Host "`n DAAU Installation failed! Run me with admin rights" -ForegroundColor Red
        Start-sleep 1
        Return $False
    }
}

function Set-DAAUNotificationPriority {
    Set-Location $PSScriptRoot
    $LoggedInUser = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username
    If ($LoggedInUser -contains "defaultuser0") {
        Write-Host "Autopilot deployment defaultuser0 detected. Loading Default User registry hive."
        reg load HKU\Default C:\Users\Default\NTUSER.DAT
        Write-Host "Creating default user notification registry keys"
        New-Item -Path "HKU:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.DAAU.Notification"
        New-ItemProperty "HKU:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.DAAU.Notification" -Name "Rank" -Value "99" -PropertyType Dword -Force
        reg unload HKU\Default
    }
    Else {
        $objUser = New-Object System.Security.Principal.NTAccount($LoggedInUser)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        Write-Host "Standard deployment detected. Adding registry keys to logged-in user hive."
        New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS"
        Set-Location -Path "HKU:\$($strSID.Value)\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"
        New-Item -Path "HKU:\$($strSID.Value)\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "Windows.SystemToast.DAAU.Notification" -Force
        New-ItemProperty "HKU:\$($strSID.Value)\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.DAAU.Notification" -Name "Rank" -Value "99" -PropertyType Dword -Force
        Remove-PSDrive -Name "HKU" -Force -ErrorAction SilentlyContinue
    }
    Pop-Location
}

function Start-DAAppUpdater {
    #If -DoNotUpdate is true, skip.
    If (!($DoNotUpdate)){
        #If -Silent, run DA-AppUpdater now
        If ($Silent){
            $RunWinget = 1
        }
        #If running interactively, ask for DA App Updater
        Else {
            $MsgBoxTitle = "DA-AppUpdater"
            $MsgBoxContent = "Would you like to run DA-AppUpdater now?"
            $MsgBoxTimeOut = 60
            $MsgBoxReturn = (New-Object -ComObject "Wscript.Shell").Popup($MsgBoxContent,$MsgBoxTimeOut,$MsgBoxTitle,4+32)
            If ($MsgBoxReturn -ne 7) {
                $RunWinget = 1
            }
            Else {
                $RunWinget = 0
            }
        }
        If ($RunWinget -eq 1){
        Try {
            Write-host "Running DA-AppUpdater..." -ForegroundColor Yellow
            Get-ScheduledTask -TaskName "DA-AppUpdater" -ErrorAction SilentlyContinue | Start-ScheduledTask -ErrorAction SilentlyContinue
            While ((Get-ScheduledTask -TaskName "DA-AppUpdater").State -ne  'Ready') {
                Start-Sleep 1
            }
        }
        Catch {
            Write-host "Failed to run DA-AppUpdater..." -ForegroundColor Red
        }
    }
    }
    Else {
    Write-host "Skip running DA-AppUpdater"
    }
}


<# MAIN #>
Start-DALogging

Write-Host "`n"
Write-Host "###################################"
Write-Host "#                                 #"
Write-Host "#          DA App Updater         #"
Write-Host "#                                 #"
Write-Host "###################################"
Write-Host "`n"
Write-host "Installing to $DAAUPath\"

Try {
    #Check Pre-Reqs
    Install-Prerequisites
    Install-WinGet

    #Install
    Write-Host "Installing DA App Updater"
    Install-DAAppUpdater
    Write-Host "Configuring Notification Priority"
    Set-DAAUNotificationPriority
    Write-Host "Install complete. Exiting with success code"
    Start-Sleep 3
    Exit 0 #Success
}
Catch {
    Write-Error "$_.Exception.Message"
    Start-Sleep 3
    Exit 1618 #Retry
}

Stop-Transcript