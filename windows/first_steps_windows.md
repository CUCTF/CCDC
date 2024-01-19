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
Net user {username_here} *
Net user >>localUsers.txt
Net user {username} *
```

## Step 4

Delete or disable any unnecessary accounts.

- Disable

  ```Powershell
  Net user accountname /active:no
  ```

  - Or with Windows Management Instruction (WMI)

    ```Powershell
    Wmic useraccount where name=’john’ set disabled=true
    ```

  - For Active Directory

    ```Powershell
    Dsmod user -u [username] -disabled yes
    ```
  
- Delete

  ```Powershell
  Net user accountname /delete
  ```

- Mass Rolling Passwords (mass password rest) or Mass Disable for Active Directory

  ```Powershell
  dsquery group -name [group name] | dsget group -members | findstr /V "[ignoreduser] [otherignoreduser]" | dsmod user -pwd [password]
  -disabled yes (to disable, no to enable)
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

Check for any logged on users

```Powershell
Query session
Query [user]
Query [process]
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
  Tasklist /m (show each process and dll loaded)
  Tasklist /m [dll] (list all processes with that dll)
  Tasklist /svc (list all processes and services associated with each)
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

From runbook git hub, working on combining this section to top half
Highlighted portions are parts that have been combined already

Order of things in the first minutes:

User Disable and Changing Password: ## Step 4
Net user [username] /active:no
Wmic useraccount where name=’john’ set disabled=true
Dsmod user -u [username] -disabled yes
Net user [username] [password]

Mass Rolling Passwords or Mass Disable ## Step 4
dsquery group -name [group name] | dsget group -members | findstr /V "[ignoreduser] [otherignoreduser]" | dsmod user -pwd [password]
-disabled yes (to disable, no to enable)

Creating and Removing Shares: ## Step 7
Removing Shares:
Net share [sharename] /delete
Adding Share:
Right click on folder, properties, share, advance sharing, permission, add, search for object names, set permissions.

Killing a Process: ## Step 9
Taskkill /im [name].exe
Taskkill /pid [pid]
List Processes:
Tasklist
Tasklist /m (show each process and dll loaded)
Tasklist /m [dll] (list all processes with that dll)
Tasklist /svc (list all processes and services associated with each)
Wmic process list full

List Detailed User and Computer Information
Gpresult /r
Gpresult /v

Check if can reach computer on domain + its info
Nbtstat -a [cn or ip]

Add or Remove Computer from Domain:
Net computer \\[cn] /add
Net computer \\[cn] /del

WMIC:
Process, service, share, startup, useraccount, qfe
wmic computersystem get roles
wmic netlogin list brief
wmic ntdomain > test.txt

View current sessions:
quser
quser /server:ip

System File Checker:
sfc.exe /scannow
Scans for any missing or corrupted system files

Execute CMD from Powershell:
cmd.exe /c start

Searching for File in Directory:
Dir “*.ova” /s /b

Display Last Reboot Time and Machine Statistics
Net statistics workstation

Show Current local and remote Logons
Query session
Query user (shows user sessions)
Net session (shows remote logons)

Kill Logon Sessions
Logoff [sessionid | sessionname]

List DC, workstations
Netdom query [workstation | DC | server | PDC]
Dsquery computer
Net group “___” [can input domain controllers, domain computers”

Firewall Management (rest in BTFM)
Netsh advfirewall set [currentprofile | allprofile | publicprofile | privateprofile | domainprofile] state on
Netsh advfirewall set currenprofile firewallpolicy blockinboundalways, allowoutbound

Group policy updates (GPO)
Gpupdate [/force | /sync]

Ipconfig DNS renewal
Ipconfig /flushdns
Ipconfig /release
Ipconfig /renew

Powershell Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools
<http://stackoverflow.com/questions/5615296/cannot-read-configuration-file-due-to-insufficient-permissions>
<http://stackoverflow.com/questions/20048486/http-error-500-19-and-error-code-0x80070021>

Powershell Install Hyper-V
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart

Install SQL Server Management Studio
<https://www.sqlshack.com/sql-server-management-studio-##> Step-## Step-installation-guide

Install Sysmon:
Download: <https://technet.microsoft.com/en-us/sysinternals/sysmon>

install: sysmon -accepteula -i
github.com/SwiftOnSecurity/sysmon-config
sysmon.exe -c sysmonconfig-export.xml
update config or dump config if no args: sysmon -c

Sysmon Forwarding
 - admin. cmd:
  - on collector: wecutil qc
  - on forwarder: wimrm quickconfig
 - add collector to “Event Log Readers” group
 - Event Viewer -> subscriptions

WinRM
winrm get winrm/config
winrm enumerate winrm/config/listener
winrm set winrm/config/client @{TrustedHosts="<sources>"}
winrm set winrm/config/client '@{TrustedHosts="athena,artemis"}'
on the collector computer to allow all of the source computers to use NTLM authentication when communicating with WinRM on the collector computer

Solarwinds Windows Event Log Forwarder

On collector computer, download and intall Solarwinds Windows Event Log Forwarder: <http://downloads.solarwinds.com/solarwinds/Release/FreeTool/SolarWinds-LogForwarder-FreeTool-v1.2.0.zip>
Configure to forward sysmon event logs to Linux syslog server

Microsoft Management Console:
mmc.exe

File Hashing and Integrity:
Download: <https://support.microsoft.com/en-us/kb/841290> (FCIV Tool)
Reference: <https://en.wikibooks.org/wiki/File_Checksum_Integrity_Verifier_(FCIV)_Examples>
Commands
Creating file hashes: fciv [directory name] -r -xml fileHashes.xml -sha1
Verifying hashes: fciv [directory name] -v -xml fileHashes.xml -sha1
Without fciv: certUtil -hashfile <file> MD5 (or SHA1, etc.)
powershell: Get-FileHash filename (press tab)

Setting Environment Variables (Adding to Path):
Run sysdm.cpl then advanced -> environment variables

Powershell back up and restore gpo
Backup-gpo -all -path \\<server>\<pathtobackup>
Restore-gpo -all -domain <insert domain> -Path \\<server>\<pathtobackup>

Policy Editors:
Local Group: gpedit.msc
Local Security: secpol.msc
GPO - Domain Group: gpmc.msc
To reset GPOs in cmd:  dcgpofix /target:both
Defined groups: Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Restricted Groups
Passwords: Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policy -> Password Policy
Check for “store passwords using reversible encryption”
Banner: Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Local Policies -> Security Options -> Interactive logon: Message text for users attempting to log on
Windows Update: Computer Configuration -> Policies -> Administrative Templates -> Windows Components -> Windows Update
Refresh Interval: Computer Configuration -> policies -> administrative templates -> group policy -> group policy refresh interval

Windows Renaming of CMD.exe and PowerShell.exe

Open an administrative command prompt:

C:\WINDOWS\system32>
takeown /f C:\Windows\System32\cmd.exe
icacls C:\Windows\System32\cmd.exe /grant:r Administrators:F
rename C:\Windows\System32\cmd.exe vpn.com
takeown /f C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
icacls C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /grant:r Administrators:F
rename C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe help.exe

Script to continuously log sessions with time

@echo off
:loop
Date /t > con & time /t > con & query session > con & date /t >> sess.txt & time /t >> sess.txt & query session >> sess.txt & timeout /t 120 /nobreak > nul
Goto loop

Logs:
Set Audit Policy to log everything:
auditpol /set /category:*(probably shouldn’t run this)
auditpol /get /category:*

Continual Hashing and File Addition Script (download fciv add to path before)
InitHashNMap Script:
Fciv -r -xml winhv.xml -type *.exe -type*.dll -type *.com -type*.bat -type *.cnv -type*.vbs -type *.ini -type*.sys C:\Windows
Fciv -r -xml userhv.xml C:\Users
Dir /s /b C:\Windows | findstr /v “\.log” > winfiles.txt
Dir /s /b C:\Users | findstr /v “\.log” > userfiles.txt

Continual Checker Script:
:loop
@fciv -v -xml winhv.xml
@fciv -v -xml userhv.xml
@dir /s /b C:\Windows | findstr /v “\.log” > winfiles2.txt
@dir /s /b C:\Users | findstr /v “\.log” > userfiles2.txt
@fc winfiles.txt winfiles2.txt
@fc userfiles.txt userfiles2.txt
@timeout /t 300 /nobreak > nul
Goto loop

Script for reverse DNS lookup

For /l %n in (1,1,254) do @nslookup 192.168.12%n | findstr /i “name address” | findstr /v “::” >> names.txt

Script for ping scan

For /l %n in (1,1, 254) do @ping -n 1 192.168.12.%n | findstr /i “reply time” | findstr /v “unreachable milli out” >> ipaddress.txt

Display a local share
NET SHARE sharename
Display a list of computers in the current domain.
NET VIEW
To see a list of shares on a remote computer
NET VIEW \\ComputerName
To see a list of all shares in the domain:
NET VIEW /DOMAIN
To see a list of shares on a different domain
NET VIEW /DOMAIN:domainname
To see a list of shares on a remote Netware computer
NET VIEW /NETWORK:NW [\\ComputerName]
Create a new local file share
NET SHARE sharename=drive:path /REMARK:"text" [/CACHE:Manual | Automatic | No ]
Limit the number of users who can connect to a share
NET SHARE sharename /USERS:number /REMARK:"text"
Remove any limit on the number of users who can connect to a share
NET SHARE sharename /UNLIMITED /REMARK:"text"
Delete a share
NET SHARE {sharename | devicename | drive:path} /DELETE
Delete all shares that apply to a given device
NET SHARE devicename /DELETE
In this case the devicename can be a printer (Lpt1) or a pathname (C:\Docs\)
Join a file share (Drive MAP)
NET USE
Display all the open shared files on a server and the lock-id
NET FILE
Close a shared file (disconnect other users and remove file locks)
NET FILE id /CLOSE
List all sessions connected to this machine
NET SESSION
List sessions from a given machine
NET SESSION \\ComputerName
Disconnect all sessions connected to this machine
NET SESSION /DELETE
Disconnect all sessions connected to this machine (without any prompts)
NET SESSION /DELETE /y
Disconnect sessions from a given machine
NET SESSION \\ComputerName /DELETE
Notes: NET SESSION displays incoming connections only, in other words it must be run on the machine that is acting as the server. To create file shares the SERVER service must be running, which in turn requires 'File and Print Sharing' to be installed.

Sysinternal Useful Tools
accesschk: check accesses specific users or groups have to files, directories, Registry keys, global objects and Windows services.
Handle: check which process/service is currently using a specific file/directory
PsFile: shows files opened remotely
pslist: list detail information about process/service
psloggedon: show who is currently logged on
psloglist: show event logs
pspasswd: reset passwords for computers on domain
psservice: deal with services can do remote
shareenum: show all shares

Constrained Language Mode - Powershell:
[Environment]::SetEnvironmentVariable(‘__PSLockdownPolicy‘, ‘4’, ‘Machine‘)
Remove Constrained Language Mode:
sysdm.cpl -> advanced -> environment variables delete__PSLockdownPolicy
Check Language Mode:
$ExecutionContext.SessionState.LanguageMode

RUN COMMANDS

AD Domains and Trusts
domain.msc
Active Directory Management
admgmt.msc
AD Sites and Services
dssite.msc
AD Users and Computers
dsa.msc
ADSI Edit
adsiedit.msc
Authorization manager
azman.msc
Certification Authority Management
certsrv.msc
Certificate Templates
certtmpl.msc
Cluster Administrator
cluadmin.exe
Computer Management
compmgmt.msc
Component Services
comexp.msc
Configure Your Server
cys.exe
Device Manager
devmgmt.msc
DHCP Management
dhcpmgmt.msc
Disk Defragmenter
dfrg.msc
Disk Manager
diskmgmt.msc
Distributed File System
dfsgui.msc
DNS Management
dnsmgmt.msc
Event Viewer
eventvwr.msc
Indexing Service Management
ciadv.msc
IP Address Manage
ipaddrmgmt.msc
Licensing Manager
llsmgr.exe
Local Certificates Management
certmgr.msc
Local Group Policy Editor
gpedit.msc
Local Security Settings Manager
secpol.msc
Local Users and Groups Manager
lusrmgr.msc
Network Load balancing
nlbmgr.exe
Performance Monitor
perfmon.msc
PKI Viewer
pkiview.msc
Public Key Management
pkmgmt.msc
Quality of Service Control Management
acssnap.msc
Remote Desktop
tsmmc.msc
Remote Storage Administration
rsadmin.msc
Removable Storage
ntmsmgr.msc
Removable Storage Operator Requests
ntmsoprq.msc
Routing and Remote Access Manager
rrasmgmt.msc
Resultant Set of Policy
rsop.msc
Schema management
schmmgmt.msc
Services Management
services.msc
Shared Folders
fsmgmt.msc
SID Security Migration
sidwalk.msc
Telephony Management
Tapimgmt.msc
Task Manager
Taskschd.msc
Task Manager
taskmgr
Terminal Server Configuration
tscc.msc
Terminal Server Licensing
licmgr.exe
Terminal Server Manager
tsadmin.exe
Teminal Services RDP MSTSC
Teminal Services RDP to Console mstsc /v:[server] /console   
UDDI Services Managment
uddi.msc
Windows Mangement Instumentation
wmimgmt.msc
WINS Server manager
Winsmgmt.msc
