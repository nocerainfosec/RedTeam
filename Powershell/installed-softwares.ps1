<#
.SYNOPSIS
    This script gathers information about the installed applications on a Windows machine and writes the information to a file in a network share.

.DESCRIPTION
    The script retrieves information about installed applications by querying the Windows registry. The information gathered includes the application name only. The script also gathers information about the hostname and username of the machine.

.AUTHOR
    Guilherme Nocera - Red Team - Security Researcher - Nocera Labs
#>

$currentuser = (query user /server:127.0.0.1 | Select-String -Pattern "\s\d+\s").ToString().Split()[1]
$hostname = hostname
$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$filename = "\\path\to\remote\location\installed_apps_$hostname-$date.txt"


$installedApps = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" |
  Get-ItemProperty |
  Select-Object DisplayName

$installedApps += Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" |
  Get-ItemProperty |
  Select-Object DisplayName

$installedApps += Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\*\Products" |
  ForEach-Object { Get-ItemProperty $_.PSPath } |
  Where-Object { $_ -ne $null } |
  Select-Object DisplayName

$installedApps | 
  Select-Object @{Name="Hostname";Expression={$hostname}},@{Name="Username";Expression={$currentuser}},@{Name="DisplayName";Expression={$_.DisplayName}} |
  ConvertTo-Csv -NoTypeInformation |
  ForEach-Object {$_ -replace '""', '' -replace ',', ', '} |
  Format-Table -Autosize | 
  Out-File $filename -Encoding UTF8 -Append
