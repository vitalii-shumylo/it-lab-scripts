# it-lab-scripts

Small, generic scripts for building and checking an IT home lab: Hyper-V, Active Directory, Group Policy, a two-tier PKI and a few Linux helpers. They are the scripts behind the step-by-step guides on [learnitlessons.com](https://learnitlessons.com), cleaned up so you can run them with your own names and addresses.

I'm Vitalii Shumylo, an IT instructor. I write these guides and courses from lab work, so every script here has been run in a lab before it is shared. Use them in a lab first, not on a production domain.

## Rules the scripts follow

- No passwords, keys or tokens in any file. Where a password is needed (for example the AD DSRM password), the script asks for it when you run it.
- Names and addresses are parameters. The examples use `corp.example.test` and the `10.10.10.0/24` range; change them to suit your lab. (Some guides on the site use a different example range, so check the addresses before you copy a line.)
- Scripts that change things say so at the top. Scripts that only read are marked "read-only".

## What is in each folder

### hyper-v

| Script | What it does | Guide |
|---|---|---|
| `New-LabSwitch.ps1` | Internal Hyper-V switch with NAT, so VMs reach the internet without joining your home network | [Hyper-V lab on Windows 11](https://learnitlessons.com/articles/hyper-v-lab-windows-11/) |
| `New-LabVM.ps1` | Generation 2 VM with an ISO attached and set as first boot device | same |
| `Checkpoint-LabVM.ps1` | Stops a VM cleanly and takes a named checkpoint | same |

### active-directory

| Script | What it does | Guide |
|---|---|---|
| `Set-LabServerNetwork.ps1` | Static IP, DNS server and final name before promotion (restarts the server) | [Promote a domain controller](https://learnitlessons.com/articles/promote-domain-controller-powershell/) |
| `Install-LabForest.ps1` | Installs AD DS, runs the prerequisite test, creates a new forest | same |
| `Add-LabDomainController.ps1` | Adds an extra domain controller to an existing domain | same |
| `Test-DomainControllerHealth.ps1` | Read-only: DC list, `dcdiag`, replication summary, DC locator | same |
| `FSMO.ps1` | Shows the five FSMO roles; can move or (with `-Seize`) seize them | [FSMO roles explained](https://learnitlessons.com/articles/fsmo-roles-explained/) |
| `New-LabPasswordPolicy.ps1` | Fine-grained password policy applied to a group | [Fine-grained password policy](https://learnitlessons.com/articles/fine-grained-password-policy/) |
| `Find-KerberoastableAccounts.ps1` | Read-only: accounts with an SPN and recent RC4 service tickets | [Kerberoasting and how to prevent it](https://learnitlessons.com/articles/kerberoasting-explained-prevention/) |

### group-policy

| Script | What it does | Guide |
|---|---|---|
| `Get-GpoDiagnostics.ps1` | First checks when a GPO is not applying: refresh, HTML report, permissions, inheritance, versions, events | [Group Policy not applying](https://learnitlessons.com/articles/group-policy-not-applying/) |

### pki

| Script | What it does | Guide |
|---|---|---|
| `Install-OfflineRootCA.ps1` | Standalone root CA with lab-friendly CRL and validity settings | [Two-tier PKI with an offline root](https://learnitlessons.com/articles/pki-two-tier-ca-design/) |
| `Test-CertificationAuthority.ps1` | Read-only: CA answers, name, CRL and validity settings, service state | same |

### linux

| Script | What it does | Guide |
|---|---|---|
| `create-sudo-user.sh` | Creates a user and optionally adds them to `wheel` (RHEL family) | [RHEL: create a user and grant sudo](https://learnitlessons.com/articles/rhel-create-user-grant-sudo/) |
| `ping-hosts.sh` | Pings each host in a file and prints up / DOWN | [Bash for loops for sysadmins](https://learnitlessons.com/articles/bash-for-loops-sysadmins/) |
| `rotate-log.sh` | Numbered log rotation | same |
| `rename-extensions.sh` | Renames `*.jpeg` to `*.jpg` and so on, never overwriting | same |

## How to run

PowerShell scripts: open PowerShell as administrator on the right machine (the Hyper-V host, a server, or a machine with the RSAT tools), read the script, then run it with its parameters, for example:

```powershell
.\hyper-v\New-LabSwitch.ps1 -Name LabNAT -Subnet 10.10.10.0 -Prefix 24
Get-Help .\active-directory\FSMO.ps1 -Examples
```

If Windows blocks a downloaded script, unblock it with `Unblock-File` after you have read it.

Linux scripts: `chmod +x script.sh`, then run it. The usage line is at the top of each file.

## Courses and more

If you prefer to learn this as video lessons with labs, my courses are listed at [learnitlessons.com](https://learnitlessons.com).

## Licence

MIT. See `LICENSE`. Issues and suggestions are welcome.