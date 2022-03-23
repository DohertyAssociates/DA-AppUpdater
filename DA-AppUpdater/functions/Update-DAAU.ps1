
function Update-DAAU ($VersionToUpdate){
    #Send available update notification
    $Title = $NotifLocale.local.outputs.output[2].title -f "Doherty App Updater"
    $Message = $NotifLocale.local.outputs.output[2].message -f $CurrentVersion, $LatestVersion.Replace("v","")
    $MessageType = "info"
    $Balise = "Doherty App Updater"
    Start-NotifTask $Title $Message $MessageType $Balise

    #Run DAAU update
    try{
        #Force to create a zip file 
        $ZipFile = "$WorkingDir\DAAU_update.zip"
        New-Item $ZipFile -ItemType File -Force | Out-Null

        #Download the zip 
        Write-Log "Starting downloading the GitHub Repository version $VersionToUpdate"
        Invoke-RestMethod -Uri "https://github.com/DohertyAssociates/DA-AppUpdater/archive/refs/tags/v$($VersionToUpdate).zip/" -OutFile $ZipFile
        Write-Log "Download finished" "Green"

        #Extract Zip File
        Write-Log "Starting unzipping the DAAU GitHub Repository"
        $location = "$WorkingDir\DAAU_update"
        Expand-Archive -Path $ZipFile -DestinationPath $location -Force
        Get-ChildItem -Path $location -Recurse | Unblock-File
        Write-Log "Unzip finished" "Green"
        $TempPath = (Resolve-Path "$location\*\DA-AppUpdater\")[0].Path
	$TempPath = (Resolve-Path "$location\*\DA-AppUpdater\")[0].Path
	if ($TempPath){
		Copy-Item -Path "$TempPath\*" -Destination "$WorkingDir\" -Recurse -Force
	}
        
        #Remove update zip file
        Write-Log "Cleaning temp files"
        Remove-Item -Path $ZipFile -Force -ErrorAction SilentlyContinue
        #Remove update folder
        Remove-Item -Path $location -Recurse -Force -ErrorAction SilentlyContinue

        #Set new version to about.xml
        [xml]$XMLconf = Get-content "$WorkingDir\config\about.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
        $XMLconf.app.version = $VersionToUpdate
        $XMLconf.Save("$WorkingDir\config\about.xml")

        #Send success Notif
        $Title = $NotifLocale.local.outputs.output[3].title -f "Doherty App Updater"
        $Message = $NotifLocale.local.outputs.output[3].message -f $LatestVersion
        $MessageType = "success"
        $Balise = "Doherty App Updater"
        Start-NotifTask $Title $Message $MessageType $Balise

        #Rerun with newer version
	    Write-Log "Re-run DAAU"
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$WorkingDir\winget-upgrade`""
        exit
    }
    catch{
        #Send Error Notif
        $Title = $NotifLocale.local.outputs.output[4].title -f "Doherty App Updater"
        $Message = $NotifLocale.local.outputs.output[4].message
        $MessageType = "error"
        $Balise = "Doherty App Updater"
        Start-NotifTask $Title $Message $MessageType $Balise
        Write-Log "DAAU Update failed"
    }
}
