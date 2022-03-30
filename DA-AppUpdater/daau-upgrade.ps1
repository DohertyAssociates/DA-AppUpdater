<# LOAD FUNCTIONS #>

#Get Working Dir
$Script:WorkingDir = $PSScriptRoot
#Get Functions
Get-ChildItem "$WorkingDir\functions" | ForEach-Object {. $_.FullName}


<# MAIN #>

#Run log initialisation function
Start-Init

#Get Notif Locale function
Get-NotifLocale

#Check network connectivity
If (Test-Network){
    #Get Current Version
    Get-DAAUCurrentVersion
    #Check if DAAU update feature is enabled
    Get-DAAUUpdateStatus
    #If yes then check DAAU update
    If ($true -eq $DAAUautoupdate){
        #Get Available Version
        Get-DAAUAvailableVersion
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

    #Get exclude apps list
    $toSkip = Get-ExcludedApps

    #Get outdated Winget packages
    Write-Log "Checking application updates on Winget Repository..." "yellow"
    $outdated = Get-WingetOutdatedApps

    #Log list of app to update
    ForEach ($app in $outdated){
        #List available updates
        $Log = "Available update : $($app.Name). Current version : $($app.Version). Available version : $($app.AvailableVersion)."
        $Log | Write-host
        $Log | out-file -filepath $LogFile -Append
    }
    
    #Count good update installations
    $InstallOK = 0

    #For each app, notify and update
    ForEach ($app in $outdated){

        If (-not ($toSkip -contains $app.Id) -and $($app.Version) -ne "Unknown"){

            #Send available update notification
            Write-Log "Updating $($app.Name) from $($app.Version) to $($app.AvailableVersion)..." "Cyan"
            $Title = $NotifLocale.local.outputs.output[2].title -f $($app.Name)
            $Message = $NotifLocale.local.outputs.output[2].message -f $($app.Version), $($app.AvailableVersion)
            $MessageType = "info"
            $Balise = $($app.Name)
            Start-NotifTask $Title $Message $MessageType $Balise

            #Winget upgrade
            Write-Log "##########   WINGET UPGRADE PROCESS STARTS FOR APPLICATION ID '$($App.Id)'   ##########" "Gray"
                #Run Winget Upgrade command
                & $UpgradeCmd upgrade --id $($app.Id) --all --accept-package-agreements --accept-source-agreements -h | Tee-Object -file $LogFile -Append
                
                #Check if application updated properly
                $CheckOutdated = Get-WingetOutdatedApps
                $FailedToUpgrade = $false
                ForEach ($CheckApp in $CheckOutdated){
                    If ($($CheckApp.Id) -eq $($app.Id)) {
                        #If app failed to upgrade, run Install command
                        & $upgradecmd install --id $($app.Id) --accept-package-agreements --accept-source-agreements -h | Tee-Object -file $LogFile -Append
                        #Check if application installed properly
                        $CheckOutdated2 = Get-WingetOutdatedApps
                        ForEach ($CheckApp2 in $CheckOutdated2){
                            If ($($CheckApp2.Id) -eq $($app.Id)) {
                                $FailedToUpgrade = $true
                            }      
                        }
                    }
                }
            Write-Log "##########   WINGET UPGRADE PROCESS FINISHED FOR APPLICATION ID '$($App.Id)'   ##########" "Gray"   

            #Notify installation
            If ($FailedToUpgrade -eq $false){   
                #Send success updated app notification
                Write-Log "$($app.Name) updated to $($app.AvailableVersion) !" "Green"
                
                #Send Notif
                $Title = $NotifLocale.local.outputs.output[3].title -f $($app.Name)
                $Message = $NotifLocale.local.outputs.output[3].message -f $($app.AvailableVersion)
                $MessageType = "success"
                $Balise = $($app.Name)
                Start-NotifTask $Title $Message $MessageType $Balise

                $InstallOK += 1
            }
            Else {
                #Send failed updated app notification
                Write-Log "$($app.Name) update failed." "Red"
                
                #Send Notif
                $Title = $NotifLocale.local.outputs.output[4].title -f $($app.Name)
                $Message = $NotifLocale.local.outputs.output[4].message
                $MessageType = "error"
                $Balise = $($app.Name)
                Start-NotifTask $Title $Message $MessageType $Balise
            }
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

    If ($InstallOK -gt 0){
        Write-Log "$InstallOK apps updated ! No more updates available." "Green"
    }
    If ($InstallOK -eq 0){
        Write-Log "No new updates available." "Green"
    }
}

#End
Write-Log "Process Complete" "Cyan"
Start-Sleep 3
