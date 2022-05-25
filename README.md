# DA App Updater (DAAU)
Customised from work originally created by [Romanitho](https://github.com/Romanitho/Winget-AutoUpdate)

## App Concept
This tool utilises the new [WinGet](https://github.com/microsoft/winget-cli) functionality to automatically update applications that are installed on a device. It adds functionality to make it possible to automatically notify users of updates having been applied, and the updater itself will automatically update via GitHub when available. Initial work on calling the winget cli from a system context documented here: [Usage with System Account - Github](https://github.com/microsoft/winget-cli/discussions/962#discussioncomment-1561274)
## Install Options
All parameters can be seen in the "Install-DAAAppUpdater.ps1" file.
### Silent Install
The -S install switch will install the app and pre-requisites silently.
### Default install location
By default, scripts and components will be placed in %ProgramData%\DA-AppUpdater. You can change this with the -Path argument.
### Disable post-install update
By default, the app will run through configured applications after the app itself is installed. The -DoNotUpdate switch will disable this functionality.
### Update at user log-on
Option to make DAAU to check for app updates when a user logs into a device. Default is False, can be enabled with the "-UpdatesAtLogon" switch.
### Update interval
The default update cycle is "Daily". This can be changed to "Weekly", "BiWeekly" or "Monthly" by using the -UpdatesInterval switch. e.g. -UpdatesInterval Weekly
### Update DAAU
An auto-update feature will automatically update the app itself if an update is available on Github. By default, DAAU AutoUpdate is enabled. To disable DAAU AutoUpdate, the install script will need to be run with the "-DisableDAAUAutoUpdate" switch.
### Pre-Release Updates
If -DisableDAAUPreRelease is set to "True", then any automatic updates set as pre-release versions on GitHub will be installed. This is set to disabled by default.
### Include/Exclude Behavior
#### Exclude
By default, the tool will ignore certain installed applications. Winget App ID's needing to be excluding from the autoupdate will need to be added to 'excluded_apps.txt'.
Default Exclusions are set for:
* Microsoft Edge
* Microsoft EdgeWebView2Runtime
* Microsoft Office
* Microsoft OneDrive
* Microsoft Teams
* Google Chrome (Including Dev and Beta branches)
* Mozilla Firefox (Including Beta and ESR branches)
* TeamViewer & TeamViewer Host
#### Include
Alternatively, the application can only update apps as defined in the 'included_apps.txt' file if the -UseWhiteList switch is set to True. This could be helpful for updating just standard baseline apps:
* 7zip.7zip
* Notepad++.Notepad++
* Adobe.Acrobat.Reader.64-bit
* Google.Chrome
### End-User Notification Level
The default notification is set to "Full". This will display all notifications to users, including if the tool has updated, or an app update has succeeded or failed. This can be set to "SuccessOnly" which will only show successful updates (failures could generate tickets), or "None", which will silently update applications.
## App Information
### When does the script run?
By default The created scheduled task is set to run:
- At 6AM every day (with the -StartWhenAvailable flag on the scheduled task to be sure it is run at least once a day). This way, even without connected user, powered-on computers get applications updated anyway.
See the above UpdatesAtLogon and UpdatesInterval switches to amend how often the script runs.
### Log location
You can find logs in %ProgramData%\DA-AppUpdater\logs.
Logs for the DA-AppUpdater install itself can be found in DA Log folder.
### Notification language
Toast notification text and locales can be edited via the \locale folder
### "Unknown" App version
As explained in this [post](https://github.com/microsoft/winget-cli/issues/1255), sometimes Winget cannot detect the current version of some installed apps. We decided to skip managing these apps with DAAU to avoid retries each time DAAU runs.
If this is causing issues, try to reinstall or update app manually to see if new version is detected.
