function Write-Log ($LogMsg, $LogColor = "White") {
    #Get log
    $Log = "$(Get-Date -UFormat "%T") - $LogMsg"
    #Echo log
    $Log | Write-Host -ForegroundColor $LogColor
    #Write log to file
    $Log | Out-File -FilePath $LogFile -Append
}
