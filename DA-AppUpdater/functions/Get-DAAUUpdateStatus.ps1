function Get-DAAUUpdateStatus{
    [xml]$UpdateStatus = Get-Content "$WorkingDir\config\config.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
    
    #Check if AutoUpdate is enabled
    If ($true -eq [System.Convert]::ToBoolean($UpdateStatus.app.DAAUAutoUpdate)){
        Write-Log "DAAU AutoUpdate is Enabled. Current version : $DAAUCurrentVersion" "Green"
        $Script:DAAUAutoUpdate = $true
        
        #Check if pre-release versions are enabled
        If ($true -eq [System.Convert]::ToBoolean($UpdateStatus.app.DAAUPreRelease)){
            Write-Log "DAAU AutoUpdate Pre-release versions is Enabled" "Cyan"
            $Script:DAAUPreRelease = $true
        }
        Else{
            $Script:DAAUPreRelease = $false
        }
    }
    Else{
        Write-Log "DAAU AutoUpdate is Disabled. Current version : $DAAUCurrentVersion" "Grey"
        $Script:DAAUAutoUpdate = $false
    }
}
