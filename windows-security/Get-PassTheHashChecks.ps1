<#
.SYNOPSIS
  Read-only: two quick checks for pass-the-hash exposure on one computer - is Credential Guard running, and which
  recent network sign-ins used NTLM.
.DESCRIPTION
  1. Reads SecurityServicesRunning from Win32_DeviceGuard. The value 1 in the list means Credential Guard is running.
  2. Reads the last Security log events with ID 4624 and lists those whose Authentication Package is NTLM.
  Run it in a test first: the Security log can be large. Needs an elevated window to read the Security log.
  Not run against production; review before use.
  Full guide: https://learnitlessons.com/articles/pass-the-hash-attack-explained/?s=github
  Written with AI assistance and checked by the author.
.EXAMPLE
  .\Get-PassTheHashChecks.ps1
  .\Get-PassTheHashChecks.ps1 -MaxEvents 500 -Show 10
#>
[CmdletBinding()]
param(
    [int]$MaxEvents = 200,
    [int]$Show = 5
)

$running = (Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard).SecurityServicesRunning
"SecurityServicesRunning: $($running -join ', ')"
if ($running -contains 1) {
    'Credential Guard: running'
} else {
    'Credential Guard: NOT running (check virtualization support, TPM, Secure Boot and policy). It does not protect local account hashes.'
}

"`nNTLM sign-ins in the last $MaxEvents events with ID 4624:"
Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4624 } -MaxEvents $MaxEvents |
    Where-Object { $_.Message -match 'Authentication Package:\s+NTLM' } |
    Select-Object -First $Show TimeCreated
