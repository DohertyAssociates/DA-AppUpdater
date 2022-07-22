function Start-Init {

    #Config console output encoding
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    #Log Header
    $Log = "`n##################################################`n#     CHECK FOR APP UPDATES - $(Get-Date -Format (Get-culture).DateTimeFormat.ShortDatePattern)`n##################################################"
    $Log | Write-host

    #Logs initialisation if admin
    Try {

        $LogPath = "$WorkingDir\logs"
        
        if (!(Test-Path $LogPath)){
            New-Item -ItemType Directory -Force -Path $LogPath
        }
        
        #Log file
        $Script:LogFile = "$LogPath\updates.log"
        $Log | Out-File -filepath $LogFile -Append
    
    }
    #Logs initialisation if non-admin
    Catch {
    
        $LogPath = "$env:USERPROFILE\DA-AppUpdater\logs"
    
        If (!(Test-Path $LogPath)){
            New-Item -ItemType Directory -Force -Path $LogPath
        }

        #Log file
        $Script:LogFile = "$LogPath\updates.log"
        $Log | Out-File -filepath $LogFile -Append
    
    }

}
