<#
.SYNOPSIS
     Enables BitLocker encryption on the system drive if it is not already enabled.

.DESCRIPTION
     This script checks the system drive for BitLocker encryption status and enables BitLocker if it is not already active.
     It requires elevated privileges to run successfully.
     Ensure that Group Policy is configured to store BitLocker recovery passwords in Active Directory before executing this script.

.NOTES
     Author: Connor Howell
     Date: 16/01/2025

#>

# Check if Bitlocker is enabled on the system drive
$BitlockerStatus = Get-BitLockerVolume $env:SystemDrive

# If Bitlocker is not enabled, enable it
if ($BitlockerStatus.KeyProtector.Count -eq 0)
{
     # Enable Bitlocker on the system drive, using a recovery password protector and TPM protector  
     Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector  
     Enable-Bitlocker -MountPoint $env:SystemDrive -EncryptionMethod XtsAes256 -TpmProtector  
}