<#
.SYNOPSIS
  Read-only: checks a computer before a domain join (edition, domain and SRV record resolve, port 389 to the DC),
  or with -Verify checks the result after the join (domain name, secure channel, DC in use).
.DESCRIPTION
  Most join failures are DNS: the client must use the domain's DNS server so it can find the SRV records.
  Also check the clock yourself: Kerberos fails if the time differs by more than five minutes.
  The join itself is not done here: Add-Computer -DomainName <domain> -Credential (Get-Credential) -Restart.
  Not run against production; review before use.
  Full guide: https://learnitlessons.com/articles/join-windows-computer-to-domain-powershell/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Test-DomainJoinReadiness.ps1 -DomainName corp.example.test -DcAddress 10.10.10.10
  .\Test-DomainJoinReadiness.ps1 -DomainName corp.example.test -DcAddress 10.10.10.10 -Verify
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$DomainName,
    [Parameter(Mandatory)][string]$DcAddress,
    [switch]$Verify
)

if ($Verify) {
    "Domain: $((Get-CimInstance Win32_ComputerSystem).Domain)"
    Test-ComputerSecureChannel -Verbose
    nltest /dsgetdc:$DomainName
    return
}

"Edition: $((Get-CimInstance Win32_OperatingSystem).Caption) (Home cannot join a domain; Pro, Enterprise and Education can)"
Resolve-DnsName $DomainName
Resolve-DnsName -Type SRV "_ldap._tcp.dc._msdcs.$DomainName"
Test-NetConnection $DcAddress -Port 389 | Format-List ComputerName, RemotePort, TcpTestSucceeded
"If any step fails, fix DNS first (use the domain controller as the DNS server), then join."
