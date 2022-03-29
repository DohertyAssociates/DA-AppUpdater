function Get-DAAUAvailableVersion {
    #Get update URL definitions
    [xml]$Update = Get-Content "$WorkingDir\config\update.xml" -Encoding UTF8 -ErrorAction SilentlyContinue

    #Get Github latest version
    If ($DAAUPreRelease -eq $true) {
        #Get latest pre-release info
        $DAAUurl = $Update.urls.api.baseurl + 'releases'
    }
    Else {
        #Get latest stable info
        $DAAUurl = $Update.urls.api.baseurl + 'releases/latest'
    }
    $Script:DAAUAvailableVersion = ((Invoke-WebRequest $DAAUurl -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace("v","")
}