# 2016-01-09
# Injabie3
#
# Description:
# PowerShell Robocopy script with e-mail notification
# Created by Michel Stevelmans - http://www.michelstevelmans.com
# Modified by Injabie3 - https://injabie3.moe

# Change these values
$BackupDate = Get-Date -format "yyyy-MM-dd"
$SourceFolder = "G:\EFS"
$DestinationFolder1 = "H:\Backups\EFS\$BackupDate" #2TB
$DestinationFolder2 = "I:\Backups\EFS\$BackupDate" #3TB
$DestinationFolder3 = "E:\Backups\EFS\$BackupDate" #RAID mirror
$Logfile = "G:\Logs\EFSCopy-Last.txt"
$LogfileAppend = "G:\Logs\EFSCopy.txt"
$EmailFrom = "no-reply@injabie3.tk"
$EmailTo = "sysadmin@injabie3.tk"

$ComputerName = (Get-CIMInstance CIM_ComputerSystem).Name
$EmailSubject = "${ComputerName}: Weekly Backup Log - EFS: $BackupDate"
$Username = "no-reply@injabie3.tk"
$Password = "<password here>"

#Send a message to domain computers to warn about virtual hard drives being dismounted.
start msg.exe "* /server:PC-name ""The server will be dismounting its drives for backup in 15 minutes. Please save your work and logoff to avoid data loss."""
TIMEOUT 600
start msg.exe "* /server:PC-name ""The server will be dismounting its drives for backup in 5 minutes. Please save your work and logoff now to avoid data loss."""
TIMEOUT 300
start msg.exe "* /server:PC-name ""The server has dismounted its drives. Please wait until the backup is complete before logging back on."""

#Dismount the VHDs
.\VHD-Dismount.ps1

# Copy Folder with Robocopy
Robocopy $SourceFolder $DestinationFolder1 /E /ZB /R:10 /W:30 /LOG:$Logfile /TEE /NP
Robocopy $SourceFolder $DestinationFolder2 /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP
Robocopy $SourceFolder $DestinationFolder3 /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP

#Mount the VHDs again
.\VHD-Mount.ps1

start msg.exe "* /server:PC-name ""The server has mounted its drives. You may now log in again."""

#Prep the email to be sent.
$LogfileContents = Get-Content $Logfile | Out-String
$EmailBodyComplete = "<pre style=""font-size:14px"">" + $LogfileContents + "</pre>"

#Append to continuous log
Add-Content $LogfileAppend $LogfileContents

# Send E-mail message with log file attachment
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBodyComplete)
$Message.IsBodyHtml = $true
$SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$SMTPClient.Send($Message)
