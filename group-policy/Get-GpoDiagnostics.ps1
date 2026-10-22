<#
.SYNOPSIS
  First checks when a Group Policy Object is not applying: force a refresh, write an HTML result report,
  show the GPO permissions, link inheritance, version numbers on one DC and recent GroupPolicy events.
.EXAMPLE
  .\Get-GpoDiagnostics.ps1 -GpoName 'Finance drive' -TargetOU 'OU=Finance,OU=Users,OU=Corp,DC=corp,DC=example,DC=test' -DomainName corp.example.test
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$GpoName,
    [Parameter(Mandatory)][string]$TargetOU,
    [Parameter(Mandatory)][string]$DomainName,
    [string]$Server
)

gpupdate /force
$report = Join-Path $env:TEMP 'gpresult.html'
gpresult /h $report /f
"Report written to $report"

Get-GPPermission -Name $GpoName -All |
    Format-Table @{ Name = 'Trustee'; Expression = { $_.Trustee.Name } }, Permission
Get-GPInheritance -Target $TargetOU
Get-GPO -Name $GpoName | Format-List DisplayName, GpoStatus, UserVersion, ComputerVersion

nltest /dsgetdc:$DomainName
if ($Server) {
    Get-GPO -Name $GpoName -Server $Server | Format-List UserVersion, ComputerVersion
}
Get-WinEvent -LogName 'Microsoft-Windows-GroupPolicy/Operational' -MaxEvents 30 |
    Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize -Wrap