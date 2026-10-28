<#
.SYNOPSIS
  Read-only by default: checks the domain functional level and lists the members of Protected Users, flagging
  computer accounts (should not be members). With -Add or -Remove it changes membership of the named accounts.
.DESCRIPTION
  Members cannot use NTLM, DES or RC4 in Kerberos, cannot be delegated, get a 4-hour TGT, and their credentials are
  not cached (they cannot sign in when no DC is reachable). Add admin accounts after a test, one at a time. Do not
  add computer accounts, service accounts or your only break-glass account. Members must sign in again to get the effect.
  Needs the ActiveDirectory module.
  Not run against production; review before use.
  Full guide: https://learnitlessons.com/articles/protected-users-group-active-directory/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-ProtectedUsersReport.ps1
  .\Get-ProtectedUsersReport.ps1 -Add adm-user1
  .\Get-ProtectedUsersReport.ps1 -Remove adm-user1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Add,
    [string[]]$Remove
)
Import-Module ActiveDirectory

$mode = (Get-ADDomain).DomainMode
"DomainMode: $mode (the full set of domain-side protections needs Windows2012R2Domain or higher)"

if ($Add -and $PSCmdlet.ShouldProcess(($Add -join ', '), 'Add to Protected Users')) {
    Add-ADGroupMember -Identity 'Protected Users' -Members $Add
}
if ($Remove -and $PSCmdlet.ShouldProcess(($Remove -join ', '), 'Remove from Protected Users')) {
    Remove-ADGroupMember -Identity 'Protected Users' -Members $Remove -Confirm:$false
}

"`nMembers of Protected Users:"
$members = Get-ADGroupMember -Identity 'Protected Users'
$members | Select-Object Name, SamAccountName, objectClass | Format-Table -AutoSize
$computers = $members | Where-Object objectClass -eq 'computer'
if ($computers) { Write-Warning 'Computer accounts are in the group; they get no protection and may cause problems.' }
"To see the 4-hour TGT, run 'klist tgt' in the member session after a new sign-in."
