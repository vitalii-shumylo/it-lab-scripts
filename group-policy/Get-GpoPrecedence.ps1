<#
.SYNOPSIS
  Read-only: shows which GPOs are linked to a target (site, domain or OU), their link order, the GPOs it inherits,
  and whether inheritance is blocked. Optionally writes a gpresult HTML report to see the winning GPO per setting.
.DESCRIPTION
  Lower link order number = higher precedence (1 wins). Enforced beats Block Inheritance. Processing order is
  Local, Site, Domain, then OUs from the top down (LSDOU); the last one wins for conflicting settings.
  Needs the GroupPolicy module (RSAT). Changing the order is a separate step: Set-GPLink -Order, see the guide.
  Not run against production; review before use.
  Full guide: https://learnitlessons.com/articles/gpo-link-order-lsdou-precedence/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-GpoPrecedence.ps1 -Target 'OU=Finance,OU=Users,OU=Corp,DC=corp,DC=example,DC=test'
  .\Get-GpoPrecedence.ps1 -Target 'OU=Finance,OU=Users,OU=Corp,DC=corp,DC=example,DC=test' -Report
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Target,
    [switch]$Report
)
Import-Module GroupPolicy

$inheritance = Get-GPInheritance -Target $Target
"GpoInheritanceBlocked: $($inheritance.GpoInheritanceBlocked)"
"`nLinked here (GpoLinks):"
$inheritance.GpoLinks | Format-Table DisplayName, Order, Enabled, Enforced -AutoSize
"Inherited from above (InheritedGpoLinks):"
$inheritance.InheritedGpoLinks | Format-Table DisplayName, Order, Enforced -AutoSize

if ($Report) {
    # Run this part on the affected computer, as the affected user.
    $path = Join-Path $env:TEMP 'gp-report.html'
    gpresult /h $path /f
    "Report written to $path - look at the 'Winning GPO' column."
}
