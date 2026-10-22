<#
.SYNOPSIS
  Stop a lab VM cleanly and take a named checkpoint, so you can roll back after an experiment.
.EXAMPLE
  .\Checkpoint-LabVM.ps1 -Name DC1 -SnapshotName 'Clean install'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$SnapshotName
)
$ErrorActionPreference = 'Stop'

if ((Get-VM -Name $Name).State -ne 'Off') { Stop-VM -Name $Name }
Checkpoint-VM -Name $Name -SnapshotName $SnapshotName
Get-VMCheckpoint -VMName $Name | Format-Table VMName, Name, CreationTime