function Uninstall-DAAppUpdater{
    try{
        $DAAUPath = "$env:ProgramData\DA-AppUpdater"
        
        Write-Host "Removing Scheduled Tasks"
		Get-ScheduledTask -TaskName "DA-AppUpdater" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$False
		Get-ScheduledTask -TaskName "DA-AppUpdater-Notify" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$False
        
        Write-Host "Removing Reg Keys"
        reg delete "HKCR\AppUserModelId\Windows.SystemToast.DAAU.Notification" /f
        
        Write-Host "Deleting Install Directory"
		Remove-Item -Path "$env:ProgramData\DA-AppUpdater" -Force -Recurse
        
        Write-host "`nUninstallation succeeded!" -ForegroundColor Green
        Start-Sleep 1
    }
    catch{
        Write-host "`nUninstallation failed!" -ForegroundColor Red
        Start-Sleep 1
        return $False
    }
}

<# MAIN #>

Write-host "###################################"
Write-host "#                                 #"
Write-host "#          DA App Updater         #"
Write-host "#                                 #"
Write-host "###################################`n"
Write-host "Uninstalling DA App Updater\"

Uninstall-DAAppUpdater

Write-host "End of process."
Start-Sleep 3