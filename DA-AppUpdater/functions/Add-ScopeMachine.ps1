function Add-ScopeMachine ($SettingsPath) {

    If (Test-Path $SettingsPath) {
        $ConfigFile = Get-Content -Path $SettingsPath | Where-Object {$_ -notmatch '//'} | ConvertFrom-Json
    }
    If (!$ConfigFile) {
        $ConfigFile = @{}
    }
    If ($ConfigFile.installBehavior.preferences.scope) {
        $ConfigFile.installBehavior.preferences.scope = "Machine"
    }
    Else {
        Add-Member -InputObject $ConfigFile -MemberType NoteProperty -Name 'installBehavior' -Value $(
            New-Object PSObject -Property $(@{preferences = $(
                    New-Object PSObject -Property $(@{scope = "Machine"}))
            })
        ) -Force
    }
    $ConfigFile | ConvertTo-Json | Out-File $SettingsPath -Encoding utf8 -Force
} 