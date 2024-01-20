# Windows Immediate Steps

Every CLI command is in powershell unless otherwise stated.

## Step 1

Make sure machine is in English.

```console
Control intl.cpl
```

## Step 2

Create backup administrator account.

```console
net user WGU-Admin * /add
net localgroup administrators WGU-Admin /add
```

## Step 3

Change all user passwords to strong passwords.

```console
Net localgroup administrators >>LocalAdministratorUsers.txt
Net user [username_here ]*
Net user >>localUsers.txt
Net user [username] *
```

## Step 4

Delete or disable any unnecessary accounts.

- Disable

  ```Powershell
  Net user accountname /active:no
  ```

  - Or with Windows Management Instruction (WMI)

    ```Powershell
    Wmic useraccount where name=[’name’] set disabled=true
    ```

  - For Active Directory

    ```Powershell
    Dsmod user -u [username] -disabled yes
    ```
  
- Delete

  ```Powershell
  Net user [accountname] /delete
  ```

- Mass Rolling Passwords (mass password rest) or Mass Disable for Active Directory

  ```Powershell
  dsquery group -name [group name] | dsget group -members | findstr /V "[ignoreduser] [otherignoreduser]" | dsmod user -pwd [password]
  -disabled yes #to disable, no to enable
  ```

## Step 5

Enable Windows Firewall and allow some ports through.

***Important: You only want to run the reset command if you are local to the box***

```Powershell
netsh advfirewall reset
```

```Powershell
netsh advfirewall firewall delete rule *
netsh advfirewall firewall add rule dir=in action=allow protocol=tcp localport=3389 name=”Allow-TCP-3389-RDP”

netsh advfirewall firewall add rule dir=in action=allow protocol=icmpv4 name=”Allow ICMP V4”
netsh advfirewall set domainprofile firewallpolicy blockinbound,allowoutbound
netsh advfirewall set privateprofile firewallpolicy blockinbound,allowoutbound
netsh advfirewall set publicprofile firewallpolicy blockinbound,allowoutbound
netsh advfirewall set allprofile state on
```

## Step 6

- Check for any logged on users.

  ```Powershell
  Query session
  Query user
  quser /server:ip
  Query process
  Net session #shows remote logons
  ```

  - On WMIC (Process, service, share, startup, useraccount, qfe):

  ```Powershell
  wmic computersystem get roles
  wmic netlogin list brief
  wmic ntdomain > test.txt
  ```

## Step 7

- Delete Unnecessary Shares on the Machine if needed Create Shares

  ```Powershell
  Net share
  Net share sharename /delete
  ```

- Adding Share:
  - Right click on folder, properties, share, advance sharing, permission, add, search for object names, set permissions.

## Step 8

Delete any scheduled tasks

```Powershell
schtasks /delete /tn * /f
```

## Step 9

Identify running services and processes and kill process if needed

- Get Services

  ```Powershell
  Get-service
  Sc query type=service state=all
  Tasklist >>RunningProcesses.Txt
  ```

- Killing a Process:

  ```Powershell
  Taskkill /im [name].exe
  Taskkill /pid [pid]
  ```

- List Processes:

  ```Powershell
  Tasklist
  Tasklist /m #show each process and dll loaded
  Tasklist /m [dll] #list all processes with that dll
  Tasklist /svc #list all processes and services associated with each
  Wmic process list full
  ```

## Step 10

- Setup for Powershell Scripts

```Powershell
Set-executionpolicy bypass -force
Disable-psremoting -force
Clear-item -path wsman:\localhost\client\trustedhosts -force
Add-windowsfeature powershell-ise
```

## Step 11

Enable and set to highest setting UAC.

```Powershell
C:\windows\system32\UserAccountControlSettings.exe
```

## Step 12

Verify Certificate stores for any suspicious certs
Win 8 / 2012 or higher
certlm

  ```Powershell
  mmc.exe
  ```

  1. File -> Add / Remove Snap-In -> Certificates -> Click Add->Computer Account->Local Computer->Finish
  2. File -> Add / Remove Snap-In -> Certificates -> Click Add->My User Account->Finish
  3. File -> Add / Remove Snap-In -> Certificates -> Click Add->Service Account->Local Computer->Select potential service accounts to review -> Finish

## Step 13

Check startup & disable unnecessary items via ```msconfig```

## Step 14

Uninstall any unnecessary software

```Powershell
Control appwiz.cpl
```

- I.E. remove tightvnc, aim, trillian, gaim, pidgin, any extraneous software that is not required by the given scenario.
- Check browsers for any malicious or unnecessary toolbars etc Reset the browsers if possible

## Step 15

Make sure Antivirus is installed!

~~
TODO: FIX STEP 16

## Step 16

Configure local policies (Work in progress)

```Powershell
Secpol.msc
```

- Security Settings>Account Policies>Account Lockout Policy Account Lockout Duration: 30min Account Lockout threshold: 2 failed logins Reset account lockout counter after: 30 mins
- Local Policies>Audit Policy Enable all for failure and success

~~

## Step 17

Preliminary Hardening

- Disable Server Message Block (SMB)
  - Win 7 way is

    ``` Powershell
    Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters | ForEach-Object {Get-ItemProperty $_.pspath}
    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force
    ```

    - Then restart
- Disable Netbios
- Disable Login to Certain accounts
- System File Checker

  ```Powershell
  sfc.exe /scannow #Scans for any missing or corrupted system files
  ```

  - Execute CMD from Powershell:

    ```CMD
    cmd.exe /c start
    ```

  - Searching for File in Directory (CMD):

  ```CMD
    Dir “*.ova” /s /b
  ```

- Display Last Reboot Time and Machine Statistics

  ```Powershell
  Net statistics workstation
  ```

## Step 18

Get these tools onto the machine

- Sysinternals
  - Sysmon
  - Process Explorer
  - AutoRuns
- Active defense and endpoint detection software
- [EMET (If Windows 7)](https://www.microsoft.com/en-us/download/details.aspx?id=48240)
- Monitor system resources software
- [Microsoft Security Compliance Toolkit 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=55319)

## Step 19

List Detailed User and Computer Information

- Gpresult /r
- Gpresult /v

## Step 20

Check if can reach computer on domain + its info

```Powershell
Nbtstat -a [cn or ip]
```

- Add or Remove Computer from Domain:

```Powershell
Net computer \\[cn] /add
Net computer \\[cn] /del
```
