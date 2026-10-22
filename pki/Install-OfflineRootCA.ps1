<#
.SYNOPSIS
  Install a standalone root CA (for an offline root in a two-tier PKI) and set sensible lab defaults:
  yearly-style CRL (52 weeks), no delta CRL, 10-year validity for issued CA certificates.
  Publication URLs are set from the -PkiHost name you give.
.EXAMPLE
  .\Install-OfflineRootCA.ps1 -CommonName Corp-Root-CA -PkiHost pki.corp.example.test
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$CommonName,
    [Parameter(Mandatory)][string]$PkiHost,
    [int]$ValidityYears = 20
)
$ErrorActionPreference = 'Stop'

Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools | Out-Null
Install-AdcsCertificationAuthority -CAType StandaloneRootCA -CACommonName $CommonName `
    -CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' -KeyLength 4096 `
    -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits $ValidityYears -Force

certutil -setreg CA\CRLPeriodUnits 52
certutil -setreg CA\CRLPeriod "Weeks"
certutil -setreg CA\CRLDeltaPeriodUnits 0
certutil -setreg CA\ValidityPeriodUnits 10
certutil -setreg CA\ValidityPeriod "Years"
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\System32\CertSrv\CertEnroll\%3%8%9.crl\n2:http://$PkiHost/CertEnroll/%3%8%9.crl"
certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\System32\CertSrv\CertEnroll\%1_%3%4.crt\n2:http://$PkiHost/CertEnroll/%1_%3%4.crt"
Restart-Service -Name certsvc
certutil -crl