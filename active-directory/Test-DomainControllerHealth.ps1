<#
.SYNOPSIS
  Quick health check of a lab domain: list the DCs, run dcdiag, show replication summary,
  and show which DC a client would find.
.EXAMPLE
  .\Test-DomainControllerHealth.ps1 -DomainName corp.example.test
#>
[CmdletBinding()]
param([Parameter(Mandatory)][string]$DomainName)

Get-ADDomainController -Filter * |
    Format-Table Name, Site, IsGlobalCatalog, IPv4Address
dcdiag /q
dcdiag /test:dns
repadmin /replsummary
nltest /dsgetdc:$DomainName