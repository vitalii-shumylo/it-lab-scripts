<#
.SYNOPSIS
  Read-only audit: user accounts with a service principal name (the ones Kerberoasting targets),
  and recent Kerberos tickets issued with weak RC4 encryption (event 4769, type 0x17).
  Run on a domain controller or a machine with RSAT.
.EXAMPLE
  .\Find-KerberoastableAccounts.ps1 -Events 500
#>
[CmdletBinding()]
param([int]$Events = 200)

'--- Accounts with an SPN ---'
Get-ADUser -Filter { ServicePrincipalName -like '*' } `
    -Properties ServicePrincipalName, PasswordLastSet, 'msDS-SupportedEncryptionTypes', adminCount |
    Select-Object Name, PasswordLastSet, 'msDS-SupportedEncryptionTypes', adminCount, ServicePrincipalName

'--- Audit policy ---'
auditpol /get /subcategory:"Kerberos Service Ticket Operations"

'--- Recent RC4 service tickets ---'
Get-WinEvent -LogName Security -MaxEvents $Events -FilterXPath `
    "*[System[EventID=4769] and EventData[Data[@Name='TicketEncryptionType']='0x17']]" `
    -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Message