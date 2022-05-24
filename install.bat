@echo off
powershell -Command "Get-ChildItem -Path '%~dp0' -Recurse | Unblock-File; Start-Process powershell.exe -Argument '-noprofile -executionpolicy bypass -file """%~dp0Install-DAAppUpdater.ps1"" -UpdatesAtLogon -NotificationLevel SuccessOnly'" -Verb RunAs
