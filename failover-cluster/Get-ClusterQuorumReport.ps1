<#
.SYNOPSIS
  Show node votes and the quorum configuration; optionally validate it or change the witness.
.DESCRIPTION
  Default mode is read-only: node state and weights, the witness dynamic weight, the quorum type.
  -FileShareWitness or -CloudWitness change the quorum, so they ask for confirmation. The storage account key
  is prompted for, never passed in a file.
  Target OS: Windows Server 2022 / 2025 with the Failover Clustering feature and RSAT.
  Full guide: https://learnitlessons.com/articles/failover-cluster-quorum-explained/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-ClusterQuorumReport.ps1 -Cluster CLUSTER1
  .\Get-ClusterQuorumReport.ps1 -Cluster CLUSTER1 -Validate
  .\Get-ClusterQuorumReport.ps1 -Cluster CLUSTER1 -FileShareWitness '\\fs1\Witness'
  .\Get-ClusterQuorumReport.ps1 -Cluster CLUSTER1 -CloudWitness -AccountName examplewitness
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)][string]$Cluster,
    [switch]$Validate,
    [string]$FileShareWitness,
    [switch]$CloudWitness,
    [string]$AccountName
)
Import-Module FailoverClusters

Get-ClusterNode -Cluster $Cluster | Format-Table Name, State, NodeWeight, DynamicWeight
"Witness dynamic weight: {0}" -f (Get-Cluster -Name $Cluster).WitnessDynamicWeight
Get-ClusterQuorum -Cluster $Cluster

if ($Validate) {
    Test-Cluster -Cluster $Cluster -Include 'Validate Quorum Configuration'
}

if ($FileShareWitness -and $PSCmdlet.ShouldProcess($Cluster, "Set file share witness $FileShareWitness")) {
    Set-ClusterQuorum -Cluster $Cluster -FileShareWitness $FileShareWitness
}

if ($CloudWitness) {
    if (-not $AccountName) { throw 'Give -AccountName (the storage account name).' }
    if ($PSCmdlet.ShouldProcess($Cluster, "Set cloud witness $AccountName")) {
        $key = Read-Host -Prompt 'Storage account access key' -AsSecureString
        $plain = [System.Net.NetworkCredential]::new('', $key).Password
        Set-ClusterQuorum -Cluster $Cluster -CloudWitness -AccountName $AccountName -AccessKey $plain
    }
}
