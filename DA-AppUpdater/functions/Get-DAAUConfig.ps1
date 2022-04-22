function Get-DAAUConfig{
    
    [xml]$DAAUConfig = Get-Content "$WorkingDir\config\config.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
    
    #Check if WAU is configured for Black or White List
    If ($true -eq [System.Convert]::ToBoolean($DAAUConfig.app.UseDAAUWhiteList)){
        Write-Log "DAAU uses White List config"
        $Script:UseWhiteList = $true
    }
    Else{
        Write-Log "DAAU uses Black List config"
        $Script:UseWhiteList = $false
    }
}
