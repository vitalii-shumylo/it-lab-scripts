<#
.SYNOPSIS
  Print usable hosts per CIDR prefix, or the mask, first/last host and broadcast for one network.
.DESCRIPTION
  Pure calculation, changes nothing. Helps choose a subnet size before you assign addresses.
  Target OS: Windows PowerShell 5.1 or PowerShell 7 on any OS.
  Full guide: https://learnitlessons.com/articles/subnet-mask-cidr-explained/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-SubnetTable.ps1                              # table for /22 to /30
  .\Get-SubnetTable.ps1 -Network 10.0.0.77 -Prefix 26
#>
[CmdletBinding()]
param(
    [ValidateRange(1, 32)][int]$From = 22,
    [ValidateRange(1, 32)][int]$To = 30,
    [string]$Network,
    [ValidateRange(1, 32)][int]$Prefix
)

function ConvertTo-Number([string]$ip) {
    $b = ([System.Net.IPAddress]::Parse($ip)).GetAddressBytes()
    [uint64]$b[0] * 16777216 + [uint64]$b[1] * 65536 + [uint64]$b[2] * 256 + [uint64]$b[3]
}
function ConvertFrom-Number([uint64]$n) {
    '{0}.{1}.{2}.{3}' -f [math]::Floor($n / 16777216 % 256), [math]::Floor($n / 65536 % 256), [math]::Floor($n / 256 % 256), ($n % 256)
}

if ($Network) {
    if (-not $Prefix) { throw 'Give -Prefix with -Network.' }
    $size = [uint64][math]::Pow(2, 32 - $Prefix)               # addresses in the block
    $ip = ConvertTo-Number $Network
    $net = $ip - ($ip % $size)
    $bcast = $net + $size - 1
    [pscustomobject]@{
        Network     = ConvertFrom-Number $net
        Mask        = ConvertFrom-Number (4294967296 - $size)
        FirstHost   = ConvertFrom-Number ($net + 1)
        LastHost    = ConvertFrom-Number ($bcast - 1)
        Broadcast   = ConvertFrom-Number $bcast
        UsableHosts = $size - 2
    } | Format-List
    return
}

foreach ($n in $From..$To) { '/{0} = {1} usable hosts' -f $n, ([math]::Pow(2, 32 - $n) - 2) }
