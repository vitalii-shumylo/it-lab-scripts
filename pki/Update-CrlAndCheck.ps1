<#
.SYNOPSIS
  Publish a new CRL on a Windows CA and show its validity window; optionally add the OCSP responder role.
.DESCRIPTION
  Runs certutil -CRL, then dumps the newest .crl in the CA's CertEnroll folder so you can see "This Update" and
  "Next Update". Useful when clients report that revocation checking failed because the CRL expired.
  Run on the CA, elevated. Target OS: Windows Server 2022 / 2025 with AD CS.
  Full guide: https://learnitlessons.com/articles/crl-vs-ocsp-certificate-revocation/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Update-CrlAndCheck.ps1
  .\Update-CrlAndCheck.ps1 -InstallOcsp        # adds the Online Responder role; configure it afterwards in its console
#>
[CmdletBinding()]
param([switch]$InstallOcsp)

certutil -CRL

$dir = Join-Path $env:SystemRoot 'System32\CertSrv\CertEnroll'
$crl = Get-ChildItem -Path $dir -Filter *.crl -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($crl) {
    Write-Host "Newest CRL: $($crl.FullName)"
    certutil -dump $crl.FullName | Select-String -Pattern 'This Update|Next Update|CRL Number'
} else {
    Write-Warning "No .crl file found in $dir - is this a CA?"
}

if ($InstallOcsp) {
    Install-WindowsFeature ADCS-Online-Cert -IncludeManagementTools
}
