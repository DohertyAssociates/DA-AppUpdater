function Update-App ($app) {

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
        & $Winget upgrade --id $($app.Id) --all --accept-package-agreements --accept-source-agreements -h | Tee-Object -file $LogFile -Append
        
        #Check if application updated properly
        $CheckOutdated = Get-WingetOutdatedApps
        $FailedToUpgrade = $false
        Foreach ($CheckApp in $CheckOutdated){
            If ($($CheckApp.Id) -eq $($app.Id)) {
                #If app failed to upgrade, run Install command
                & $Winget install --id $($app.Id) --accept-package-agreements --accept-source-agreements -h | Tee-Object -file $LogFile -Append
                #Check if application installed properly
                $CheckOutdated2 = Get-WingetOutdatedApps
                Foreach ($CheckApp2 in $CheckOutdated2){
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
Tee-Object