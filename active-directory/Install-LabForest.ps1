<#
.SYNOPSIS
  Install AD DS and create a new forest. Runs the prerequisite test first and stops if it fails.
  The DSRM password is asked for interactively - it is never stored in the script.
.EXAMPLE
  .\Install-LabForest.ps1 -DomainName corp.example.test -NetbiosName CORP
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$DomainName,
    [Parameter(Mandatory)][string]$NetbiosName,
    [string]$Mode = 'Win2025'
)
$ErrorActionPreference = 'Stop'

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null
$dsrm = Read-Host -Prompt 'DSRM (safe mode) password' -AsSecureString

$common = @{
    DomainName                    = $DomainName
    DomainNetbiosName             = $NetbiosName
    ForestMode                    = $Mode
    DomainMode                    = $Mode
    InstallDns                    = $true
    SafeModeAdministratorPassword = $dsrm
}
$test = Test-ADDSForestInstallation @common
if ($test.Status -eq 'Error') { throw "Prerequisite test failed: $($test.Message)" }
Install-ADDSForest @common -Force