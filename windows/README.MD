# Windows

- [Scripts!](#scripts)

## Scripts
- Blue Team tools taken from [simeononsecurity](https://github.com/simeononsecurity/Blue-Team-Tools/tree/master)
    - description

## PowerShell Scripts
- Some Powershell Scripts we might want depending on the services we'll be running courtesy of [WiredPulse](https://github.com/WiredPulse/PowerShell)
- A disclaimer that I am not sure if these will be able to run on the Windows Server 2019, since a quick and nowhere near extensive google search showed PowerShell does not seem backwards compatible? Most of the folders are from 7 years ago, but the Eventlogs (described below) is from 3 years ago.
- AD
    - Quick searches using activedirectory module on users such as inactive, recently created, last logon, change passwords, check permissions for an OU. Depending on how many users in AD we'll be responsible for, this could help to speed things up.
- DNS
    - We might want to flush DNS cache with: ipconfig /flushdns
    - Can track the DNS queries being made by the RedTeam and possible sinkhole a domain.
- Eventlogs
    - Include log auditing using Get-WinEvent module that track logins, logouts, new services, user creation, deletion, disabling, password reset attempts, account changes, group membership modifications, process creations, etc.
    - I am not sure how much our SIEM will be tracking Active Directory changes, so this might come in use also if we have trouble setting that up.

