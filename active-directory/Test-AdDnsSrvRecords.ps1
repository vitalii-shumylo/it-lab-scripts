<#
.SYNOPSIS
  Read-only check that the DNS SRV records a client needs to find a domain controller exist and resolve.
.DESCRIPTION
  Resolves the LDAP, Global Catalog and Kerberos SRV records, runs nltest /dsgetdc, shows the client's DNS servers and
  runs dcdiag /test:dns when run on a DC. With -Repair it re-registers the records (restarts Netlogon).
  Target OS: Windows Server 2022 / 2025 (and Windows 11 for the client checks).
  Full guide: https://learnitlessons.com/articles/dns-srv-records-active-directory/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Test-AdDnsSrvRecords.ps1 -Domain corp.example.test
  .\Test-AdDnsSrvRecords.ps1 -Domain corp.example.test -Repair     # run on the DC that is missing records
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Domain,
    [string]$InterfaceAlias = 'Ethernet',
    [switch]$Repair
)

foreach ($name in "_ldap._tcp.dc._msdcs.$Domain", "_gc._tcp.$Domain", "_kerberos._tcp.$Domain") {
    Write-Host "SRV $name"
    Resolve-DnsName -Name $name -Type SRV -ErrorAction Continue
}

nltest /dsgetdc:$Domain /force

# A domain member must use the domain's own DNS servers, not a public resolver.
Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4

if (Get-Service -Name NTDS -ErrorAction SilentlyContinue) {
    dcdiag /test:dns
}

if ($Repair) {
    Restart-Service -Name Netlogon
    ipconfig /registerdns
    ipconfig /flushdns
}
