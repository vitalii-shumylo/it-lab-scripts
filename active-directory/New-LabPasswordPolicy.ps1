<#
.SYNOPSIS
  Create a fine-grained password policy (PSO) and apply it to a group, then show what a user gets.
.EXAMPLE
  .\New-LabPasswordPolicy.ps1 -PolicyName PSO-IT-Admins -GroupName G-IT-Admins -TestUser ben
  The group must already exist.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$PolicyName,
    [Parameter(Mandatory)][string]$GroupName,
    [string]$TestUser,
    [int]$Precedence = 10,
    [int]$MinLength = 16
)
$ErrorActionPreference = 'Stop'

New-ADFineGrainedPasswordPolicy -Name $PolicyName -Precedence $Precedence `
    -MinPasswordLength $MinLength -PasswordHistoryCount 24 -ComplexityEnabled $true `
    -ReversibleEncryptionEnabled $false -MinPasswordAge '1.00:00:00' -MaxPasswordAge '90.00:00:00' `
    -LockoutThreshold 5 -LockoutDuration '00:30:00' -LockoutObservationWindow '00:30:00'
Add-ADFineGrainedPasswordPolicySubject -Identity $PolicyName -Subjects $GroupName
if ($TestUser) {
    Get-ADUserResultantPasswordPolicy -Identity $TestUser | Format-List Name, Precedence, MinPasswordLength
}