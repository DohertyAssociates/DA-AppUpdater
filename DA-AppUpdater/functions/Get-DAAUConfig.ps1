function Get-DAAUConfig{
    
    #Get config file
    [xml]$DAAUConfig = Get-Content "$WorkingDir\config\config.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
    
    #Check if DAAU is configured for Black or White List
    If ($true -eq [System.Convert]::ToBoolean($DAAUConfig.app.UseDAAUWhiteList)){
        $Script:UseWhiteList = $true
    }
    Else {
        $Script:UseWhiteList = $false
    }

    #Get Notification Level
    If ($DAAUConfig.app.NotificationLevel){
        $Script:NotificationLevel = $DAAUConfig.app.NotificationLevel
    }
    Else{
        #Default: Full
        $Script:NotificationLevel = "Full"
    }
    
}
