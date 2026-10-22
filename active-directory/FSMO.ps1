<#
.SYNOPSIS
  Show the five FSMO role holders, or move roles to another DC.
.EXAMPLE
  .\FSMO.ps1                                  # show only
  .\FSMO.ps1 -MoveTo DC2                      # move PDC emulator and RID master (a planned, healthy move)
  .\FSMO.ps1 -MoveTo DC2 -All                 # move all five roles
  .\FSMO.ps1 -MoveTo DC2 -All -Seize          # DANGER: seize when the old holder is gone for good
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$MoveTo,
    [switch]$All,
    [switch]$Seize
)

function Show-Roles {
    Get-ADForest | Format-List SchemaMaster, DomainNamingMaster
    Get-ADDomain | Format-List PDCEmulator, RIDMaster, InfrastructureMaster
    netdom query fsmo
}

Show-Roles
if (-not $MoveTo) { return }

$roles = if ($All) { 'SchemaMaster', 'DomainNamingMaster', 'PDCEmulator', 'RIDMaster', 'InfrastructureMaster' }
         else { 'PDCEmulator', 'RIDMaster' }
if ($PSCmdlet.ShouldProcess($MoveTo, "Move $($roles -join ', ')$(if ($Seize) { ' (SEIZE)' })")) {
    $args2 = @{ Identity = $MoveTo; OperationMasterRole = $roles }
    if ($Seize) { $args2.Force = $true }
    Move-ADDirectoryServerOperationMasterRole @args2
    Show-Roles
}