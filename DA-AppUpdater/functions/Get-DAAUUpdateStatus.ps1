function Get-DAAUUpdateStatus{
    #Get AutoUpdate status
    [xml]$UpdateStatus = Get-Content "$WorkingDir\config\config.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($true -eq $UpdateStatus.app.DAAUAutoUpdate){
        Write-Log "DAAU AutoUpdate is Enabled" "Green"
        return $true
    }
    else{
        Write-Log "DAAU AutoUpdate is Disabled" "Grey"
        return $false
    }
}