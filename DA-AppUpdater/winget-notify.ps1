﻿#Send Notif Script

#get xml notif config
[xml]$NotifConf = Get-Content "$env:ProgramData\DA-AppUpdater\config\notif.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
If (!($NotifConf)) {
    Break
}

#Load Assemblies
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
 
#Prepare XML
$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
$ToastXml.LoadXml($NotifConf.OuterXml)

#Specify Launcher App ID
$LauncherID = "Windows.SystemToast.DAAU.Notification"
 
#Prepare and Create Toast
$ToastMessage = [Windows.UI.Notifications.ToastNotification]::New($ToastXML)
$ToastMessage.Tag = $NotifConf.toast.tag
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($LauncherID).Show($ToastMessage)
