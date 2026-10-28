<#
.SYNOPSIS
  Read-only: lists Hyper-V virtual switches with their type (External, Internal, Private), the physical adapters,
  host-side vEthernet adapters, NAT networks, and which switch each VM adapter is connected to.
.DESCRIPTION
  External = VMs reach the physical network through a real adapter. Internal = VMs and host only (add NAT for internet).
  Private = VMs only. Run on the Hyper-V host in an elevated window.
  Not run against production; review before use.
  Full guide: https://learnitlessons.com/articles/hyper-v-virtual-switch-types/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-LabSwitchReport.ps1
  .\Get-LabSwitchReport.ps1 -VMName DC1
#>
[CmdletBinding()]
param(
    [string]$VMName
)

"Virtual switches:"
Get-VMSwitch | Format-Table Name, SwitchType, NetAdapterInterfaceDescription -AutoSize
"Physical adapters:"
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status
"Host-side virtual adapters:"
Get-NetIPAddress -InterfaceAlias 'vEthernet*' -ErrorAction SilentlyContinue |
    Format-Table InterfaceAlias, IPAddress, PrefixLength -AutoSize
"NAT networks:"
Get-NetNat | Format-Table Name, InternalIPInterfaceAddressPrefix -AutoSize
"VM adapters:"
$vms = if ($VMName) { Get-VM -Name $VMName } else { Get-VM }
Get-VMNetworkAdapter -VM $vms | Format-Table VMName, SwitchName, MacAddress -AutoSize
