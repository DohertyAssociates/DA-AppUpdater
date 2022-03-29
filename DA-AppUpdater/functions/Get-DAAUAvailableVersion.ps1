function Get-DAAUAvailableVersion {
    #Get Github latest version
    if ($true -eq $DAAUprerelease) {
        #Get latest pre-release info
        $DAAUurl = 'https://api.github.com/repos/DohertyAssociates/DA-AppUpdater/releases'
    }
    else {
        #Get latest stable info
        $DAAUurl = 'https://api.github.com/repos/DohertyAssociates/DA-AppUpdater/releases/latest'
    }
    $Script:DAAUAvailableVersion = ((Invoke-WebRequest $DAAUurl -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace("v","")
}