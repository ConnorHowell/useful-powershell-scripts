<#
.SYNOPSIS
  Action1 PowerShell script for reporting local administrator accounts.

.DESCRIPTION
  This script is designed to be used as a data source in Action1 reporting. 
  Its primary purpose is to identify accounts with local administrator rights on the target system.

.NOTES
  Author: Connor Howell
  Date: 09/07/2025

#>

$hostname = $env:COMPUTERNAME

Get-LocalGroupMember -Group 'Administrators' | ForEach-Object {

  # Try to get the local user object (if applicable)
  $localUser = $null
  if ($_.ObjectClass -eq 'User') {
    $userName = $_.Name
    if ($userName -like "$hostname\*") {
      $userName = $userName -replace "^$hostname\\", ""
    }
    try {
      $localUser = Get-LocalUser -Name $userName -ErrorAction Stop
    } catch {
      $localUser = $null
    }
  }

  $isEnabled = $null
  $hasPassword = $null
  $isLocalAccount = $false

  if ($localUser) {
    $isEnabled = $localUser.Enabled
    # Check if the user has a password set
    # Note: PasswordLastSet is only available for local accounts.
    # If PasswordLastSet is $null, the account has never had a password set
    if ($localUser -and $localUser.PSObject.Properties['PasswordLastSet']) {
      $hasPassword = $localUser.PasswordLastSet -ne $null
    } else {
      $hasPassword = $null
    }
    $hasPassword = $localUser.PasswordLastSet -ne $null
  }

  # Determine if the account is a local account
  if ($_.Name -like "$hostname\*") {
    $isLocalAccount = $true
  }

  $output = [PSCustomObject]@{
    'User Name'      = $_.Name
    'Type'           = $_.ObjectClass
    'Enabled'        = $isEnabled
    'HasPassword'    = $hasPassword
    'IsLocalAccount' = $isLocalAccount
    # Unique ID for Action1 (this is the account SID)
    'A1_Key'         = $_.SID
  }

  Write-Output $output
}