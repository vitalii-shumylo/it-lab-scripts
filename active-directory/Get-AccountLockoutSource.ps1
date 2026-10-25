<#
.SYNOPSIS
  Read-only: find where an AD account keeps getting locked out, and show what to clean up.
.DESCRIPTION
  Shows the user's lockout state, the domain lockout policy, and the last lockout events (4740) from the PDC emulator,
  which names the caller computer. Optionally lists sessions on that computer. Unlocking is a separate switch.
  Needs the ActiveDirectory module and rights to read the Security log on the PDC emulator.
  Target OS: Windows Server 2022 / 2025 with RSAT-AD-PowerShell.
  Full guide: https://learnitlessons.com/articles/ad-account-lockout-troubleshooting/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-AccountLockoutSource.ps1 -User jsmith
  .\Get-AccountLockoutSource.ps1 -User jsmith -ShowSessionsOn RDS02
  .\Get-AccountLockoutSource.ps1 -User jsmith -Unlock
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$User,
    [int]$Events = 10,
    [string]$ShowSessionsOn,
    [switch]$Unlock
)
Import-Module ActiveDirectory

Get-ADUser -Identity $User -Properties LockedOut, AccountLockoutTime, LastBadPasswordAttempt |
    Format-List Name, Enabled, LockedOut, AccountLockoutTime, LastBadPasswordAttempt

Get-ADDefaultDomainPasswordPolicy |
    Format-List LockoutThreshold, LockoutDuration, LockoutObservationWindow

# Every bad password is forwarded to the PDC emulator, so 4740 events are reliable there.
$pdc = (Get-ADDomain).PDCEmulator
Write-Host "Lockout events (4740) on $pdc"
Invoke-Command -ComputerName $pdc -ArgumentList $User, $Events -ScriptBlock {
    param($u, $max)
    Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740 } -MaxEvents ($max * 20) |
        Where-Object { $_.Properties[0].Value -eq $u } |
        Select-Object -First $max TimeCreated,
            @{ n = 'User';   e = { $_.Properties[0].Value } },
            @{ n = 'Caller'; e = { $_.Properties[1].Value } }
} | Format-Table TimeCreated, User, Caller

if ($ShowSessionsOn) {
    # Disconnected sessions that still hold an old password are a classic source.
    # Log one off with: logoff <id> /server:<name>
    quser /server:$ShowSessionsOn
}

if ($Unlock) {
    Unlock-ADAccount -Identity $User
    Get-ADUser -Identity $User -Properties LockedOut | Select-Object Name, LockedOut
}
