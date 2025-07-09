<#
.SYNOPSIS
    Creates or updates a VPN connection on Windows 10/11 using PowerShell.

.DESCRIPTION
    This script is configured for a Meraki VPN connection but can be adapted for other VPNs.
    Ensure to provide the PSK and DNS suffix before running the script.

.NOTES
    Author: Connor Howell
    Date: 16/01/2025
#>

# Configuration
$Name = "Company VPN" # Name of the VPN connection
$ServerAddress = "vpn.domain.com" # Provide the VPN server address
$TunnelType = "L2TP"
$L2tpPsk = '' # Provide the PSK
$AuthenticationMethod = "PAP"
$EncryptionLevel = "Optional"
$UseWinlogonCredential = $true
$RememberCredential = $true
$SplitTunneling = $false
$DnsSuffix = '' # Provide the DNS suffix

if (Get-Command 'Get-VpnConnection') {
    # If VPN exists, update VPN settings
    if (Get-VpnConnection -Name $Name -AllUserConnection -ErrorAction SilentlyContinue) {
        Set-VpnConnection -Name $Name -AllUserConnection -ServerAddress $ServerAddress -TunnelType $TunnelType -EncryptionLevel $EncryptionLevel -AuthenticationMethod $AuthenticationMethod -SplitTunneling $SplitTunneling -DnsSuffix $DnsSuffix -L2tpPsk $L2tpPsk -UseWinlogonCredential $UseWinlogonCredential -RememberCredential $RememberCredential -Force
    }
    # Else, create VPN connection
    else {
        Add-VpnConnection -Name $Name -AllUserConnection -ServerAddress $ServerAddress -TunnelType $TunnelType -EncryptionLevel $EncryptionLevel -AuthenticationMethod $AuthenticationMethod -DnsSuffix $DnsSuffix -L2tpPsk $L2tpPsk -Force
        Set-VpnConnection -Name $Name -AllUserConnection -SplitTunneling $SplitTunneling -UseWinlogonCredential $UseWinlogonCredential -RememberCredential $RememberCredential
    }
    return Get-VpnConnection -Name $Name -AllUserConnection
}
else {
    return "Client does not support VpnClient cmdlets"
    Write-Error "Client does not support VpnClient cmdlets"
    exit 1
}