<#
.SYNOPSIS
  Read-only health check of a Windows certification authority: is it answering,
  what is its name, and what are its CRL and validity settings.
.EXAMPLE
  .\Test-CertificationAuthority.ps1
  .\Test-CertificationAuthority.ps1 -Config 'CA1\Corp-Issuing-CA'
#>
[CmdletBinding()]
param([string]$Config)

$cfg = if ($Config) { @('-config', $Config) } else { @() }
certutil @cfg -ping
certutil @cfg -cainfo name
foreach ($v in 'CRLPeriod', 'CRLPeriodUnits', 'CRLDeltaPeriod', 'CRLDeltaPeriodUnits', 'ValidityPeriod', 'ValidityPeriodUnits') {
    certutil @cfg -getreg "CA\$v"
}
Get-Service -Name certsvc | Format-Table Name, Status