<# LOAD FUNCTIONS #>

#Get Working Dir
$Script:WorkingDir = $PSScriptRoot
#Get Functions
Get-ChildItem "$WorkingDir\functions" | ForEach-Object {. $_.FullName}


<# MAIN #>

#Run log initialisation function
Start-Init

#Get DAAU Configurations
$Script:DAAUConfig = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DA-AppUpdater"

#Run post update actions if necessary
If (!($DAAUConfig.DAAU_PostUpdateActions -eq 0)) {
    Invoke-PostUpdateActions
}

#Run Scope Machine funtion if run as system
If ([System.Security.Principal.WindowsIdentity]::GetCurrent().IsSystem) {
    $SettingsPath = "$Env:windir\system32\config\systemprofile\AppData\Local\Microsoft\WinGet\Settings\settings.json"
    Add-ScopeMachine $SettingsPath
}

#Get Notif Locale function
Get-NotifLocale

#Check network connectivity
If (Test-Network) {
    $TestWinget = Get-WingetCmd
    
    If ($TestWinget) {
        #Get Current Version
        $DAAUCurrentVersion = $DAAUConfig.DisplayVersion
        Write-Log "DAAU current version: $DAAUCurrentVersion"
        #Check if DAAU update feature is enabled or not
        $DAAUDisableAutoUpdate = $DAAUConfig.DAAU_DisableAutoUpdate
        #If yes then check DAAU update
        If ($DAAUDisableAutoUpdate -eq 1) {
            Write-Log "DAAU AutoUpdate is Disabled." "Grey"
        }
        Else{
            Write-Log "DAAU AutoUpdate is Enabled." "Green"
            #Get Available Version
            $DAAUAvailableVersion = Get-DAAUAvailableVersion
            #Compare
            If ([version]$DAAUAvailableVersion -gt [version]$DAAUCurrentVersion){
                #If new version is available, update it
                Write-Log "DAAU Available version: $DAAUAvailableVersion" "Yellow"
                Update-DAAU
            }
            Else{
                Write-Log "DAAU is up to date." "Green"
            }
        }

        #Get White or Black list
        If ($DAAUConfig.DAAU_UseWhiteList -eq 1) {
            Write-Log "DAAU uses White List config"
            $toUpdate = Get-IncludedApps
            $UseWhiteList = $true
        }
        Else{
            Write-Log "DAAU uses Black List config"
            $toSkip = Get-ExcludedApps
        }

        #Get outdated Winget packages
        $outdated = Get-WingetOutdatedApps

        #Log list of app to update
        foreach ($app in $outdated) {
            #List available updates
            $Log = "-> Available update : $($app.Name). Current version : $($app.Version). Available version : $($app.AvailableVersion)."
            $Log | Write-Host
            $Log | Out-File -FilePath $LogFile -Append
        }
        
        #Count good update installations
        $Script:InstallOK = 0

        #If White List
        If ($UseWhiteList){
            #For each app, notify and update
            ForEach ($app in $outdated){
                If (($toUpdate -contains $app.Id) -and $($app.Version) -ne "Unknown"){
                    Update-App $app
                }
                #if current app version is unknown
                ElseIf($($app.Version) -eq "Unknown"){
                    Write-Log "$($app.Name) : Skipped upgrade because current version is 'Unknown'" "Gray"
                }
                #if app is in "excluded list"
                Else{
                    Write-Log "$($app.Name) : Skipped upgrade because it is not in the included app list" "Gray"
                }
            }
        }
        #If Black List or default
        Else{
            #For each app, notify and update
            ForEach ($app in $outdated){
                If (-not ($toSkip -contains $app.Id) -and $($app.Version) -ne "Unknown"){
                    Update-App $app
                }
                #if current app version is unknown
                ElseIf($($app.Version) -eq "Unknown"){
                    Write-Log "$($app.Name) : Skipped upgrade because current version is 'Unknown'" "Gray"
                }
                #if app is in "excluded list"
                Else{
                    Write-Log "$($app.Name) : Skipped upgrade because it is in the excluded app list" "Gray"
                }
            }
        }
        
        If ($InstallOK -gt 0){
            Write-Log "$InstallOK apps updated ! No more update." "Green"
        }
        If ($InstallOK -eq 0){
            Write-Log "No new update." "Green"
        }
    }
}

#End
Write-Log "End of process!" "Cyan"
Start-Sleep 3
