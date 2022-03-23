# DA App Updater (DAAU)
Customised from work originally created by [Romanitho](https://github.com/Romanitho/Winget-AutoUpdate)

## Configurations
### Excluding apps from DA App Updater
You can exclude apps from update job (for instance, apps you want to keep at a specific version or apps with built-in auto-update):
Winget App ID's needing to be excluding from the autoupdate will need to be added to 'excluded_apps.txt'.
Default Exclusions are set for:
* Google.Chrome
* Mozilla.Firefox
* Microsoft.Edge
* Microsoft.EdgeWebView2Runtime
* Microsoft.Office
* Microsoft.OneDrive
* Microsoft.Teams
### Default install location
By default, scripts and components will be placed in %ProgramData%\DA-AppUpdater. You can change this with script arguments.
### Notification language
Toast notification text and locales can be edited via the \locale folder
### When does the script run?
The created scheduled task is set to run:
- At user logon
- At 6AM every day (with the -StartWhenAvailable flag on the scheduled task to be sure it is run at least once a day)
This way, even without connected user, powered on computers get applications updated anyway.
### Log location
You can find logs in %ProgramData%\DA-AppUpdater\logs.
Logs for the DA-AppUpdater install itself can be found in DA Log folder.
### "Unknown" App version
As explained in this [post](https://github.com/microsoft/winget-cli/issues/1255), sometimes Winget cannot detect the current version of some installed apps. We decided to skip managing these apps with DAAU to avoid retries each time DAAU runs.
If this is causing issues, try to reinstall or update app manually to see if new version is detected.
## Update DAAU
A new Auto-Update process has been added which will automatically update the app if updated on Github. By default, DAAU AutoUpdate is enabled. To disable DAAU AutoUpdate, the install script will need to be run with "-DisableDAAUAutoUpdate" switch.