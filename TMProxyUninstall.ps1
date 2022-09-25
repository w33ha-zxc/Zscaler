#SYNOPSIS 
#        . Disable TMProxy

New-Item -Path 'c:\temp\uninstall_tmproxy.txt' -ItemType File
$CheckFile = Test-Path c:\temp\uninstall_tmproxy.txt
if ($CheckFile)
{
$transcriptpath = "C:\temp\uninstall_tmproxy.txt"
Start-Transcript -Path $transcriptpath -Append

#
#
# Gathers SIDs from machine
##############################
$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} |
     Select-Object  @{name="SID";expression={$_.PSChildName}},
             @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}

$SID =  Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} |
     Select-Object -Expandproperty PSChildName
Start-Sleep -s 3

#
# Creates HKEY_USERS drive
#############################
New-PSDrive HKU Registry HKEY_USERS
Set-Location HKU:
Start-Sleep -s 3

#
# Loops through SID array modifying registry value for each SID
##################################################################
$ErrorActionPreference = 'silentlycontinue'
Foreach ( $i in $SID )
{ 
Set-ItemProperty -Path "HKU:\$i\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -name ProxyServer -Value ""
Set-ItemProperty -Path "HKU:\$i\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -name ProxyEnable -Value 0
Set-ItemProperty -Path "HKU:\$i\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -name AutoConfigURL -Value "http://pac.zscalerthree.net/54qdLV878Q5D/PHSPL.pac"
}

Write-Host "Proxy Status After Registry Change"
Write-Host "-------------------------------------------"
Foreach ( $i in $SID )
{ 
Get-ItemProperty -Path "HKU:\$i\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | Select-Object PSPath, ProxyServer, ProxyEnable        
}
Start-Sleep -s 3

#
# Launches Network Settings window (for some reason some versions Windows 10 require this for the setting to be applied)
###########################################################################################################################
Start-Process ms-settings:network-proxy
Start-Sleep -s 1
taskkill /F /IM SystemSettings.exe


Stop-Transcript
Rename-Item -Path "C:\temp\logs\uninstall_tmproxy.txt" -NewName ("C:\temp\logs\$Env:COMPUTERNAME" + "_tmproxy_uninstall.txt")
} 

else {
{exit}
}
