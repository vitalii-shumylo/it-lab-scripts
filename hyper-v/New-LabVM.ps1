<#
.SYNOPSIS
  Create a Generation 2 lab VM with an ISO attached and booting from it.
.EXAMPLE
  .\New-LabVM.ps1 -Name DC1 -IsoPath D:\ISO\server_eval.iso -SwitchName LabNAT
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$IsoPath,
    [string]$SwitchName = 'LabNAT',
    [string]$VmRoot = 'D:\Hyper-V',
    [int]$MemoryGB = 4,
    [int]$CpuCount = 2,
    [int]$DiskGB = 60
)
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $IsoPath)) { throw "ISO not found: $IsoPath" }
New-VM -Name $Name -Generation 2 -MemoryStartupBytes ($MemoryGB * 1GB) `
    -NewVHDPath (Join-Path $VmRoot "$Name\$Name.vhdx") -NewVHDSizeBytes ($DiskGB * 1GB) `
    -SwitchName $SwitchName -Path $VmRoot | Out-Null
Set-VMProcessor -VMName $Name -Count $CpuCount
Add-VMDvdDrive -VMName $Name -Path $IsoPath
Set-VMFirmware -VMName $Name -FirstBootDevice (Get-VMDvdDrive -VMName $Name)
Get-VMFirmware -VMName $Name | Format-Table VMName, SecureBoot, SecureBootTemplate