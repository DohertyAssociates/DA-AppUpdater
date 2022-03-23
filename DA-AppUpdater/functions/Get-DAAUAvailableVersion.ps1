function Get-DAAUAvailableVersion{
    #Get Github latest version
    $DAAUurl = 'https://api.github.com/repos/DohertyAssociates/DA-AppUpdater/releases/latest'
    $Script:DAAULatestVersion = ((Invoke-WebRequest $DAAUurl -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace("v","")
    return [version]$DAAULatestVersion
}