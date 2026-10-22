<#
.SYNOPSIS
  Give a lab server its final static address, DNS server and name before promotion.
.EXAMPLE
  .\Set-LabServerNetwork.ps1 -ComputerName DC1 -IPAddress 10.10.10.10 -Gateway 10.10.10.1 -DnsServer 10.10.10.10
  The computer restarts at the end.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ComputerName,
    [Parameter(Mandatory)][string]$IPAddress,
    [Parameter(Mandatory)][string]$Gateway,
    [Parameter(Mandatory)][string[]]$DnsServer,
    [int]$PrefixLength = 24,
    [string]$InterfaceAlias = 'Ethernet'
)
$ErrorActionPreference = 'Stop'

New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway | Out-Null
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServer
Rename-Computer -NewName $ComputerName -Restart