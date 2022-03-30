function Update-DAAU ($VersionToUpdate){
    #Send available update notification
    $Title = $NotifLocale.local.outputs.output[2].title -f "Doherty App Updater"
    $Message = $NotifLocale.local.outputs.output[2].message -f $DAAUCurrentVersion, $DAAUAvailableVersion.Replace("v","")
    $MessageType = "info"
    $Balise = "Doherty App Updater"
    Start-NotifTask $Title $Message $MessageType $Balise

    #Run DAAU update
    Try{
        #Force to create a zip file 
        $ZipFile = "$WorkingDir\DAAU_update.zip"
        New-Item $ZipFile -ItemType File -Force | Out-Null

        #Download the zip 
        #Get update URL definitions
        [xml]$Update = Get-Content "$WorkingDir\config\update.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
        Write-Log "Downloading the GitHub Repository version $DAAUAvailableVersion" "Cyan"
        $DAAUUpdateURL = $Update.urls.git.tagarchiveurl + "v$($DAAUAvailableVersion).zip/"
        $WebClient=New-Object System.Net.WebClient
        $WebClient.DownloadFile($DAAUUpdateURL, "$WorkingDir\DAAU_update.zip")
        Write-Log "Download finished" "Green"

        #Extract Zip File
        Write-Log "Starting unzipping the DAAU GitHub Repository"
        $location = "$WorkingDir\DAAU_update"
        Expand-Archive -Path $ZipFile -DestinationPath $location -Force
        Get-ChildItem -Path $location -Recurse | Unblock-File
        Write-Log "Updating DAAU" "Yellow"
        $TempPath = (Resolve-Path "$location\*\DA-AppUpdater\")[0].Path
        If ($TempPath){
            Copy-Item -Path "$TempPath\*" -Destination "$WorkingDir\" -Exclude "icons" -Recurse -Force
        }
        
        #Remove update zip file
        Write-Log "Done. Cleaning temp files" "Cyan"
        Remove-Item -Path $ZipFile -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $location -Recurse -Force -ErrorAction SilentlyContinue

        #Set new version to about.xml
        [xml]$XMLconf = Get-content "$WorkingDir\config\about.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
        $XMLconf.app.version = $DAAUAvailableVersion
        $XMLconf.Save("$WorkingDir\config\about.xml")

        #Send success Notif
        Write-Log "DAAU Update completed." "Green"
        $Title = $NotifLocale.local.outputs.output[3].title -f "DA App Updater"
        $Message = $NotifLocale.local.outputs.output[3].message -f $DAAUAvailableVersion
        $MessageType = "success"
        $Balise = "DA App Updater"
        Start-NotifTask $Title $Message $MessageType $Balise

        #Rerun with newer version
	    Write-Log "Re-run DAAU"
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$WorkingDir\daau-upgrade`""
        Exit
    }
    Catch{
        #Send Error Notif
        $Title = $NotifLocale.local.outputs.output[4].title -f "DA App Updater"
        $Message = $NotifLocale.local.outputs.output[4].message
        $MessageType = "error"
        $Balise = "DA App Updater"
        Start-NotifTask $Title $Message $MessageType $Balise
        Write-Log "DAAU Update failed" "Red"
    }
}
