# Function to get latest DAAU version published on Github

function Get-DAAUAvailableVersion {
    #Get update URL definitions
    [xml]$Update = Get-Content "$WorkingDir\config\update.xml" -Encoding UTF8 -ErrorAction SilentlyContinue

    #Get Github latest version
    If ($DAAUConfig.DAAU_UpdatePrerelease -eq 1) {

        #Log
        Write-Log "DAAU AutoUpdate Pre-release versions is Enabled" "Cyan"

        #Get latest pre-release info
        $DAAUurl = $Update.urls.git + 'releases' 
    }
    Else {       
        #Get latest stable info
        $DAAUurl = $Update.urls.git + 'releases/latest'
    
    }
    Return ((Invoke-WebRequest $DAAUurl -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace("v","")
}
