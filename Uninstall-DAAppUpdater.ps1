function Uninstall-DAAppUpdater{
    Try {
        $DAAUPath = "$env:ProgramData\DA-AppUpdater"
        
        Write-Host "Removing Scheduled Tasks"
		Get-ScheduledTask -TaskName "DA-AppUpdater" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$False
		Get-ScheduledTask -TaskName "DA-AppUpdater-Notify" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$False
        
        Write-Host "Removing Reg Keys"
        reg delete "HKCR\AppUserModelId\Windows.SystemToast.DAAU.Notification" /f

        Write-Host "Determining current user & removing Toast"
        $LoggedInUser = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username
        $objUser = New-Object System.Security.Principal.NTAccount($LoggedInUser)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS"
        Remove-Item -Path "HKU:\$strSID\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.DAAU.Notification" -Force -Recurse
        Remove-PSDrive -Name "HKU" -Force -ErrorAction Continue
        
        Write-Host "Deleting Install Directory"
		Remove-Item -Path "$DAAUPath" -Force -Recurse
        
        Write-Host "`nUninstallation succeeded!" -ForegroundColor Green
        Start-Sleep 1
    }
    Catch {
        Write-Host "`nUninstallation failed!" -ForegroundColor Red
        Start-Sleep 1
        Return $False
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