<#
.SYNOPSIS
  Install AD DS and add this server as an extra domain controller of an existing domain.
  Credentials and the DSRM password are asked for interactively.
.EXAMPLE
  .\Add-LabDomainController.ps1 -DomainName corp.example.test -SourceDC DC1.corp.example.test
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$DomainName,
    [Parameter(Mandatory)][string]$SourceDC
)
$ErrorActionPreference = 'Stop'

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null
$netbios = $DomainName.Split('.')[0].ToUpper()
$cred = Get-Credential "$netbios\Administrator"
$dsrm = Read-Host -Prompt 'DSRM (safe mode) password' -AsSecureString

$common = @{
    DomainName                    = $DomainName
    InstallDns                    = $true
    Credential                    = $cred
    SafeModeAdministratorPassword = $dsrm
}
$test = Test-ADDSDomainControllerInstallation @common
if ($test.Status -eq 'Error') { throw "Prerequisite test failed: $($test.Message)" }
Install-ADDSDomainController @common -ReplicationSourceDC $SourceDC -Force