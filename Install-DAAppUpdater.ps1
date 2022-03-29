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

.PARAMETER DisableDAAUAutoUpdate
Disable DA-AppUpdater update checking. By default, DAAU will auto update if new release is available on Github.

.EXAMPLE
.\Install-DAAppUpdater.ps1 -Silent -DoNotUpdate
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)] [Alias('S')] [Switch] $Silent = $false,
    [Parameter(Mandatory=$False)] [Alias('Path')] [String] $DAAUPath = "$env:ProgramData\DA-AppUpdater",
    [Parameter(Mandatory=$False)] [Switch] $DoNotUpdate = $false,
    [Parameter(Mandatory=$False)] [Switch] $DisableDAAUAutoUpdate = $false
)

<# FUNCTIONS #>
function Start-DALogging{
$TimeStamp = (Get-Date -f yyyy-MM-dd_HH-mm)
$DALogsFolder = "$env:systemdrive\ProgramData\Doherty Associates\Logs\"
$LogFile = "DAAppUpdater-$env:COMPUTERNAME-$TimeStamp.log"

# Create Tech Directory
if (!(test-path "$env:systemdrive\Tech")) {
    Write-Host "Creating Tech Directory"
    New-Item -itemtype "directory" -path "$env:systemdrive\Tech" | out-null
}
else {
    write-host "Tech Directory Already exists"
}

# Create Temp Directory
if (!(test-path "$env:systemdrive\Temp")) {
    Write-Host "Creating Temp Directory"
    New-Item -itemtype "directory" -path "$env:systemdrive\Temp" | out-null
}
else {
    write-host "Temp Directory Already exists"
}

# Create ProgramData\Doherty Associates Directory
if (!(test-path "$env:systemdrive\programdata\Doherty Associates")) {
    Write-Host "Creating ProgramData\Doherty Associates Directory"
    New-Item -itemtype "directory" -path "$env:systemdrive\ProgramData\Doherty Associates\" | out-null
}
else {
    write-host "ProgramData\Doherty Associates Already exists"
}

# Create ProgramData\Doherty Associates\Logs Directory
if (!(test-path $dalogsfolder)) {
    Write-Host "Creating ProgramData\Doherty Associates\Logs Directory"
    New-Item -itemtype "directory" -path "$env:systemdrive\ProgramData\Doherty Associates\Logs\" | out-null
}
else {
    write-host "ProgramData\Doherty Associates\Logs Already exists"
}

# Set transcript logging path
Start-Transcript -path $DALogsFolder\$LogFile -append
Write-Host "Current script timestamp: $(Get-Date)"
}

function Confirm-PrereqVC{
    #Check if Visual C++ 2019 installed
    $app = "Microsoft Visual C++*2019*"
    $path = Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.GetValue("DisplayName") -like $app}
    
    #If not installed, ask for installation
    if (!($path)){
        #If -silent option, force installation
        if ($Silent){
            $InstallApp = "y"
        }
        else{
            #Ask for installation
            while("y","n" -notcontains $InstallApp){
	            $InstallApp = Read-Host "[Prerequisite for Winget] Microsoft Visual C++ 2019 is not installed. Would you like to install it? [Y/N]"
            }
        }
        if ($InstallApp -eq "y"){
            try{
                if((Get-CimInStance Win32_OperatingSystem).OSArchitecture -like "*64*"){
                    $OSArch = "x64"
                }
                else{
                    $OSArch = "x86"
                }
                Write-host "Downloading VC_redist.$OSArch.exe..."
                $SourceURL = "https://aka.ms/vs/16/release/VC_redist.$OSArch.exe"
                $Installer = $WingetUpdatePath + "\VC_redist.$OSArch.exe"
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest $SourceURL -OutFile (New-Item -Path $Installer -Force)
                Write-host "Installing VC_redist.$OSArch.exe..."
                Start-Process -FilePath $Installer -Args "/quiet /norestart" -Wait
                Remove-Item $Installer -ErrorAction Ignore
                Write-host "MS Visual C++ 2015-2019 installed successfully" -ForegroundColor Green
            }
            catch{
                Write-host "MS Visual C++ 2015-2019 installation failed." -ForegroundColor Red
                Start-Sleep 3
            }
        }
    }
    else{
        Write-Host "Prerequisites checked. OK" -ForegroundColor Green
    }
}

function Confirm-PrereqWinGet{
    $WindowsAppsPath = $env:SystemDrive + "\Program Files\WindowsApps"
    $AppInstallerFolders = (Get-ChildItem -Path $WindowsAppsPath | Where-Object { $_.Name -like "Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe" } | Select-Object Name)
    $AppInstallerFound = $False
    If ($AppInstallerFolders) {
        ForEach ($FolderName in $AppInstallerFolders) {
        $AppFilePath = (Join-Path -path $WindowsAppsPath -ChildPath $FolderName.Name | Join-Path -ChildPath "AppInstallerCLI.exe")
            If (Test-Path -Path $AppFilePath) {
                $AppInstallerFound = $True
                }
            Else{
                $AppFilePath = (Join-Path -path $WindowsAppsPath -ChildPath $FolderName.Name | Join-Path -ChildPath "winget.exe")
                    If (Test-Path -Path $AppFilePath) {
                        $AppInstallerFound = $True
                }
            }
        }
    }
    If ($AppInstallerFound) {
        Write-Verbose "App Installer is already present"
        $Script:WingetInstall = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq “Microsoft.DesktopAppInstaller”}
        Return $True 
    }
    Else{
        Write-Verbose "App Installer not Installed"
        Return $False
    }
}

function Install-WinGet{
        #Download WinGet MSIXBundle
        Write-Host "Downloading WinGet..."
        $WinGetURL = "https://aka.ms/getwinget"
        $WebClient=New-Object System.Net.WebClient
        $WebClient.DownloadFile($WinGetURL, "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
    
        #Install WinGet MSIXBundle
        Write-host "Installing MSIXBundle for App Installer..."
        Add-AppxProvisionedPackage -Online -PackagePath "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense
    
        #Check Package Install
        Write-Host "Checking Package Install"
        $TestWinGet = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq “Microsoft.DesktopAppInstaller”}
            If($TestWinGet.DisplayName) {
                Write-Host "WinGet Installed"
                Remove-Item -Path "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Force -ErrorAction Continue
                Return $True
            }
            Else {
                Write-Host "WinGet Not Installed"
                Return $False
            }
}

function Invoke-MSStoreUpdate{
    Write-Host "Attempting to force a Microsoft Store Update"
    Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
}


function Install-DAAppUpdater{
    try{
        #Copy files to install location
        if (!(Test-Path $DAAUPath)){
            New-Item -ItemType Directory -Force -Path $DAAUPath
        }
        Copy-Item -Path "$PSScriptRoot\DA-AppUpdater\*" -Destination $DAAUPath -Recurse -Force -ErrorAction SilentlyContinue

        # Set regkeys for notification name and icon
        & reg add "HKCR\AppUserModelId\Windows.SystemToast.DAAU.Notification" /v DisplayName /t REG_EXPAND_SZ /d "Doherty App Updater" /f | Out-Null
        & reg add "HKCR\AppUserModelId\Windows.SystemToast.DAAU.Notification" /v IconUri /t REG_EXPAND_SZ /d $DAAUPath\icons\DAToastIcon.png /f | Out-Null

        # Settings for the scheduled task for Updates
        $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$($DAAUPath)\daau-upgrade.ps1`""
        $taskTrigger1 = New-ScheduledTaskTrigger -AtLogOn
        $taskTrigger2 = New-ScheduledTaskTrigger  -Daily -At 6AM
        $taskUserPrincipal = New-ScheduledTaskPrincipal -UserId S-1-5-18 -RunLevel Highest
        $taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 03:00:00

        # Set up the task, and register it
        $task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Settings $taskSettings -Trigger $taskTrigger2,$taskTrigger1
        Register-ScheduledTask -TaskName 'DA-AppUpdater' -InputObject $task -Force

        # Settings for the scheduled task for Notifications
        $taskAction = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$($DAAUPath)\Invisible.vbs`" `"powershell.exe -ExecutionPolicy Bypass -File `"`"`"$($DAAUPath)\daau-notify.ps1`"`""
        $taskUserPrincipal = New-ScheduledTaskPrincipal -GroupId S-1-5-11
        $taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8 -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 00:05:00

        # Set up the task, and register it
        $task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Settings $taskSettings
        Register-ScheduledTask -TaskName 'DA-AppUpdater-Notify' -InputObject $task -Force

        # Install config file
        [xml]$ConfigXML = @"
<?xml version="1.0"?>
<app>
    <DAAUAutoUpdate>$(!($DisableDAAUAutoUpdate))</DAAUAutoUpdate>
</app>
"@
        $ConfigXML.Save("$DAAUPath\config\config.xml")

        Write-Host "`nInstallation succeeded!" -ForegroundColor Green
        Start-Sleep 1
        
        #Run Winget Immediately
        Start-DAAppUpdater
    }
    catch{
        Write-host "`nInstallation failed! Run me with admin rights" -ForegroundColor Red
        Start-sleep 1
        return $False
    }
}

function Set-DAAUNotificationPriority{
    $LoggedInUser = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username
    If($LoggedInUser -contains "defaultuser0") {
        Write-Host "Autopilot deployment defaultuser0 detected. Loading Default User registry hive."
        reg load HKU\Default C:\Users\Default\NTUSER.DAT
        Write-Host "Creating default user notification registry keys"
        New-Item -Path "HKU:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.DAAU.Notification"
        reg unload HKU\Default
    }
    Else {
        $objUser = New-Object System.Security.Principal.NTAccount($LoggedInUser)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        Write-Host "Standard deployment detected. Adding registry keys to logged-in user hive."
        New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS"
        Set-Location -Path "HKU:\$($strSID.Value)\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
        New-Item -Path "HKU:\$($strSID.Value)\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "Windows.SystemToast.DAAU.Notification" -Force
        New-ItemProperty "HKU:\$($strSID.Value)\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.DAAU.Notification" -Name "Rank" -Value "99" -PropertyType Dword -Force
        Remove-PSDrive -Name "HKU" -Force -ErrorAction Continue
    }
}

function Start-DAAppUpdater{
    #If -DoNotUpdate is true, skip.
    if (!($DoNotUpdate)){
            #If -Silent, run DA-AppUpdater now
            if ($Silent){
                $RunWinget = "y"
            }
            #Ask for DA-AppUpdater
            else{
                while("y","n" -notcontains $RunWinget){
	                $RunWinget = Read-Host "Start DA-AppUpdater now? [Y/N]"
                }
            }
        if ($RunWinget -eq "y"){
            try{
                Write-host "Running DA-AppUpdater..." -ForegroundColor Yellow
                Get-ScheduledTask -TaskName "DA-AppUpdater" -ErrorAction SilentlyContinue | Start-ScheduledTask -ErrorAction SilentlyContinue
            }
            catch{
                Write-host "Failed to run DA-AppUpdater..." -ForegroundColor Red
            }
        }
    }
    else{
        Write-host "Skip running DA-AppUpdater"
    }
}


<# MAIN #>
Start-DALogging

Write-host "###################################"
Write-host "#                                 #"
Write-host "#          DA App Updater         #"
Write-host "#                                 #"
Write-host "###################################`n"
Write-host "Installing to $DAAUPath\"

Try {
    #Attempt MS Store Update
    Invoke-MSStoreUpdate
    Start-Sleep -Seconds 60

    #Check Pre-Reqs
    Confirm-PrereqVC
    $CheckWinGet = Confirm-PrereqWinGet

    #Start Install
    If($CheckWinGet -eq $True) {
        Write-Host "Winget Installed - Version $($WingetInstall.Version)"
        Write-Host "Installing DA App Updater"
        Install-DAAppUpdater
        Write-Host "Configuring Notification Priority"
        Set-DAAUNotificationPriority
        Write-Host "Install complete. Exiting with success code"
        Start-Sleep 3
        Exit 0
    }
    Else {
        $InstallWinGet = Install-WinGet
            If($InstallWinGet -eq $True) {
                Write-Host "Winget Installed - Version $($WingetInstall.Version)"
                Write-Host "Installing DA App Updater"
                Install-DAAppUpdater
                Write-Host "Configuring Notification Priority"
                Set-DAAUNotificationPriority
                Write-Host "Install complete. Exiting with success code"
                Start-Sleep 3
                Exit 0  
            }
            Else {
                Write-Error "Winget is not installed. Exiting with retry code"
                Start-Sleep 3
                Exit 1618 
            }
    }
}
Catch {
    Write-Error "$_.Exception.Message"
    Start-Sleep 3
    Exit 1618 
}

Stop-Transcript