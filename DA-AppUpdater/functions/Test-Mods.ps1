#Function to check if modification exists in 'mods' directory

function Test-Mods ($app) {

    #Takes care of a null situation
    $ModsInstall = $null
    $ModsUpgrade = $null

    $Mods = "$WorkingDir\mods"
    If (Test-Path "$Mods\$app-*") {
        If (Test-Path "$Mods\$app-install.ps1") {
            $ModsInstall = "$Mods\$app-install.ps1"
            $ModsUpgrade = "$Mods\$app-install.ps1"
        }
        If (Test-Path "$Mods\$app-upgrade.ps1") {
            $ModsUpgrade = "$Mods\$app-upgrade.ps1"
        }
    }

    Return $ModsInstall,$ModsUpgrade
}
