<#
.SYNOPSIS
  Set up an iSCSI target on Windows Server (-Mode Target) or connect a client to it (-Mode Initiator).
.DESCRIPTION
  Target: installs the role, creates a VHDX-backed LUN, a target limited to one initiator IQN, and the mapping.
  Initiator: starts the iSCSI service, adds the portal, connects persistently, brings the new disk online and formats it.
  CHAP is optional and the secret is asked for, never stored. Formatting erases the disk; the script only touches a
  RAW iSCSI disk, but check what is attached first.
  Target OS: Windows Server 2022 / 2025.
  Full guide: https://learnitlessons.com/articles/iscsi-target-windows-server/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  # on the client: print its IQN
  .\New-LabIscsiTarget.ps1 -Mode Initiator -ShowIqn
  # on the storage server
  .\New-LabIscsiTarget.ps1 -Mode Target -TargetName SRV1-Target -InitiatorIqn iqn.1991-05.com.microsoft:srv1.corp.example.test
  # on the client: connect and format
  .\New-LabIscsiTarget.ps1 -Mode Initiator -Portal 10.10.10.22 -TargetName SRV1-Target -DriveLetter I
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Target', 'Initiator')][string]$Mode,
    [string]$TargetName = 'LabTarget',
    [string]$InitiatorIqn,
    [string]$Path = 'C:\iSCSI\LUN1.vhdx',
    [long]$SizeBytes = 20GB,
    [string]$Portal,
    [char]$DriveLetter = 'I',
    [switch]$ShowIqn,
    [switch]$Chap
)

if ($Mode -eq 'Target') {
    if (-not $InitiatorIqn) { throw 'Give -InitiatorIqn (run -Mode Initiator -ShowIqn on the client).' }
    Install-WindowsFeature -Name FS-iSCSITarget-Server
    New-Item -Path (Split-Path $Path) -ItemType Directory -Force | Out-Null
    New-IscsiVirtualDisk -Path $Path -SizeBytes $SizeBytes
    New-IscsiServerTarget -TargetName $TargetName -InitiatorIds "IQN:$InitiatorIqn"
    Add-IscsiVirtualDiskTargetMapping -TargetName $TargetName -Path $Path
    if ($Chap) {
        $cred = Get-Credential -Message 'CHAP user name and secret (secret 12-16 characters)'
        Set-IscsiServerTarget -TargetName $TargetName -EnableChap $true -Chap $cred
    }
    Get-IscsiServerTarget | Format-List TargetName, TargetIqn, InitiatorIds, LunMappings, Status
    return
}

Set-Service -Name 'MSiSCSI' -StartupType Automatic
Start-Service -Name 'MSiSCSI'
if ($ShowIqn) {
    (Get-InitiatorPort | Where-Object ConnectionType -eq 'iSCSI').NodeAddress
    return
}
if (-not $Portal) { throw 'Give -Portal (the target server address).' }
New-IscsiTargetPortal -TargetPortalAddress $Portal
$t = Get-IscsiTarget | Where-Object NodeAddress -like "*$($TargetName.ToLower())*"
if (-not $t) { throw "No target matching $TargetName found on $Portal." }
Connect-IscsiTarget -NodeAddress $t.NodeAddress -IsPersistent $true
Get-IscsiSession | Format-Table TargetNodeAddress, IsConnected, IsPersistent

$disk = Get-Disk | Where-Object { $_.BusType -eq 'iSCSI' -and $_.PartitionStyle -eq 'RAW' } | Select-Object -First 1
if (-not $disk) { throw 'No new (RAW) iSCSI disk found; nothing was formatted.' }
$disk | Set-Disk -IsOffline $false
$disk | Initialize-Disk -PartitionStyle GPT
New-Partition -DiskNumber $disk.Number -UseMaximumSize -DriveLetter $DriveLetter |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel 'iSCSI-LUN1'
