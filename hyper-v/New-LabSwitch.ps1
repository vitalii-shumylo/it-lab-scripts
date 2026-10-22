<#
.SYNOPSIS
  Create an internal Hyper-V switch with NAT, so lab VMs can reach the internet
  without being on your home network.
.EXAMPLE
  .\New-LabSwitch.ps1 -Name LabNAT -Subnet 10.10.10.0 -Prefix 24
  The host gets the first address (10.10.10.1); give VMs 10.10.10.x with that gateway.
#>
[CmdletBinding()]
param(
    [string]$Name = 'LabNAT',
    [string]$Subnet = '10.10.10.0',
    [int]$Prefix = 24
)
$ErrorActionPreference = 'Stop'

$gateway = ([version]$Subnet).ToString() -replace '\.0$', '.1'
if (-not (Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name $Name -SwitchType Internal | Out-Null
}
$alias = "vEthernet ($Name)"
if (-not (Get-NetIPAddress -InterfaceAlias $alias -IPAddress $gateway -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -IPAddress $gateway -PrefixLength $Prefix -InterfaceAlias $alias | Out-Null
}
if (-not (Get-NetNat -Name $Name -ErrorAction SilentlyContinue)) {
    New-NetNat -Name $Name -InternalIPInterfaceAddressPrefix "$Subnet/$Prefix" | Out-Null
}
Get-NetNat -Name $Name | Format-List Name, InternalIPInterfaceAddressPrefix, Active