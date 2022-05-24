#Function to make actions post DAAU update

function Invoke-PostUpdateActions {
    
    #log
    Write-Log "Running Post Update actions..." "Yellow"
    
    #Create DAAU Regkey if not present
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DA-AppUpdater"
    If (!(Test-Path $regPath)) {
        New-Item $regPath -Force
        New-ItemProperty $regPath -Name DisplayName -Value "DA App Updater (DAAU)" -Force
        New-ItemProperty $regPath -Name DisplayIcon -Value "C:\ProgramData\DA-AppUpdater\icons\datray.ico" -Force
        New-ItemProperty $regPath -Name NoModify -Value 1 -Force
        New-ItemProperty $regPath -Name NoRepair -Value 1 -Force
        New-ItemProperty $regPath -Name Publisher -Value "Doherty Associates" -Force
        New-ItemProperty $regPath -Name InstallLocation -Value $WorkingDir -Force
        New-ItemProperty $regPath -Name UninstallString -Value "powershell.exe -noprofile -executionpolicy bypass -file `"$WingetUpdatePath\DAAU-Uninstall.ps1`"" -Force
        New-ItemProperty $regPath -Name QuietUninstallString -Value "powershell.exe -noprofile -executionpolicy bypass -file `"$WingetUpdatePath\DAAU-Uninstall.ps1`"" -Force
        New-ItemProperty $regPath -Name DAAU_UpdatePrerelease -Value 0 -PropertyType DWord -Force

        #log
        Write-Log "-> $regPath created." "Green"
    }
    
    #Convert about.xml if exists (previous DAAU versions) to reg
    $DAAUAboutPath = "$WorkingDir\config\about.xml"
    If (Test-Path $DAAUAboutPath) {
        [xml]$About = Get-Content $DAAUAboutPath -Encoding UTF8 -ErrorAction SilentlyContinue
        New-ItemProperty $regPath -Name DisplayVersion -Value $About.app.version -Force
        New-ItemProperty $regPath -Name VersionMajor -Value ([version]$About.app.version).Major -Force
        New-ItemProperty $regPath -Name VersionMinor -Value ([version]$About.app.version).Minor -Force

        #Remove file once converted
        Remove-Item $DAAUAboutPath -Force -Confirm:$false

        #log
        Write-Log "-> $DAAUAboutPath converted." "Green"
    }

    #Convert config.xml if exists (previous DAAU versions) to reg
    $DAAUConfigPath = "$WorkingDir\config\config.xml"
    If (Test-Path $DAAUConfigPath) {
        [xml]$Config = Get-Content $DAAUConfigPath -Encoding UTF8 -ErrorAction SilentlyContinue
        If ($Config.app.DAAUAutoUpdate -eq "False") {New-ItemProperty $regPath -Name DAAU_DisableAutoUpdate -Value 1 -Force}
        If ($Config.app.NotificationLevel) {New-ItemProperty $regPath -Name DAAU_NotificationLevel -Value $Config.app.NotificationLevel -Force}
        If ($Config.app.UseDAAUWhiteList -eq "True") {New-ItemProperty $regPath -Name DAAU_UseWhiteList -Value 1 -PropertyType DWord -Force}
        If ($Config.app.DAAUPreRelease -eq "True") {New-ItemProperty $regPath -Name DAAU_UpdatePrerelease -Value 1 -PropertyType DWord -Force}

        #Remove file once converted
        Remove-Item $DAAUConfigPath -Force -Confirm:$false

        #log
        Write-Log "-> $DAAUConfigPath converted." "Green"
    }

    #Remove old functions
    $FileNames = @(
        "$WorkingDir\functions\Get-DAAUConfig.ps1",
        "$WorkingDir\functions\Get-DAAUCurrentVersion.ps1",
        "$WorkingDir\functions\Get-DAAUUpdateStatus.ps1"
    )
    ForEach ($FileName in $FileNames){
        If (Test-Path $FileName) {
            Remove-Item $FileName -Force -Confirm:$false
            
            #log
            Write-Log "-> $FileName removed." "Green"
        }
    }

    #Reset DAAU_UpdatePostActions Value
    $DAAUConfig | New-ItemProperty -Name DAAU_PostUpdateActions -Value 0 -Force

    #Get updated DAAU Config
    $Script:DAAUConfig = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DA-AppUpdater"

    #Log
    Write-Log "Post Update actions finished" "Green"
   
}