<!-- vscode-markdown-toc -->
1. [Powershell](#Powershell)
2. [Sysmon](#Sysmon)
3. [Sysinternal Useful Tools](#SysinternalUsefulTools)
4. [WinRM](#WinRM)
5. [Solarwinds](#Solarwinds)
6. [File Hashing and Integrity](#FileHashingandIntegrity)
	6.1. [Commands](#Commands)
7. [Setting Environment Variables (Adding to Path)](#SettingEnvironmentVariablesAddingtoPath)
8. [Policy Editors](#PolicyEditors)
9. [Windows Renaming of CMD.exe and PowerShell.exe](#WindowsRenamingofCMD.exeandPowerShell.exe)
10. [Logging](#Logging)
11. [Helpful (short) scripts](#Helpfulshortscripts)
	11.1. [Continual Hashing and File Addition Script](#ContinualHashingandFileAdditionScript)
	11.2. [Script for reverse DNS lookup](#ScriptforreverseDNSlookup)
	11.3. [Script for ping scan](#Scriptforpingscan)
12. [NET](#NET)
13. [Constrained Language Mode](#ConstrainedLanguageMode)
14. [RUN COMMANDS](#RUNCOMMANDS)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

# Helpful Commands

- Kill Logon Sessions

  ```Powershell
  Logoff [sessionid | sessionname]
  ```

- List DC, workstations

  ```Powershell
  Netdom query [workstation | DC | server | PDC]
  Dsquery computer
  Net group [___] #can input domain controllers, domain computers”
  ```

- Firewall Management (rest in BTFM)

  ```Powershell
  Netsh advfirewall set [currentprofile | allprofile | publicprofile | privateprofile | domainprofile] state on
  Netsh advfirewall set currenprofile firewallpolicy blockinboundalways, allowoutbound
  ```

- Group policy updates (GPO)

  ```Powershell
  Gpupdate [/force | /sync]
  ```

- Ipconfig DNS renewal

  ```Powershell
  Ipconfig /flushdns
  Ipconfig /release
  Ipconfig /renew
  ```

##  1. <a name='Powershell'></a>Powershell

- Powershell Install IIS

  ```Powershell
  Install-WindowsFeature -name Web-Server -IncludeManagementTools
  <http://stackoverflow.com/questions/5615296/cannot-read-configuration-file-due-to-insufficient-permissions>
  <http://stackoverflow.com/questions/20048486/http-error-500-19-and-error-code-0x80070021>
  ```

- Powershell Install Hyper-V

```Powershell
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
```

- Powershell back up and restore gpo
  - ``Backup-gpo -all -path \\<server>\<pathtobackup>``
  - ``Restore-gpo -all -domain <insert domain> -Path \\<server>\<pathtobackup>``
- Install SQL Server Management Studio

  ```Powershell
  <https://www.sqlshack.com/sql-server-management-studio-##> Step-## Step-installation-guide
  ```

##  2. <a name='Sysmon'></a>Sysmon

- Install Sysmon:
  Download: <https://technet.microsoft.com/en-us/sysinternals/sysmon>

  ```Powershell
  install: sysmon -accepteula -i
  github.com/SwiftOnSecurity/sysmon-config
  sysmon.exe -c sysmonconfig-export.xml
  update config or dump config if no args: sysmon -c
  ```

- Sysmon Forwarding
  - admin cmd:
    - on collector: ``wecutil qc``
    - on forwarder: ``wimrm quickconfig``
  - add collector to “Event Log Readers” group
  - Event Viewer -> subscriptions

##  3. <a name='SysinternalUsefulTools'></a>Sysinternal Useful Tools

- accesschk - check accesses specific users or groups have to files, directories, Registry keys, global objects and Windows services.
- Handle - check which process/service is currently using a specific file/directory
- PsFile - shows files opened remotely
- pslist - list detail information about process/service
- psloggedon - show who is currently logged on
- psloglist - show event logs
- pspasswd - reset passwords for computers on domain
- psservice - deal with services can do remote
- shareenum - show all shares

##  4. <a name='WinRM'></a>WinRM

  ```Powershell
  winrm get winrm/config
  winrm enumerate winrm/config/listener
  winrm set winrm/config/client @{TrustedHosts="<sources>"}
  winrm set winrm/config/client '@{TrustedHosts="athena,artemis"}'
  ```

  on the collector computer to allow all of the source computers to use NTLM authentication when communicating with WinRM on the collector computer

##  5. <a name='Solarwinds'></a>Solarwinds

  Solarwinds Windows Event Log Forwarder

  On collector computer, download and intall Solarwinds Windows Event Log Forwarder: <http://downloads.solarwinds.com/solarwinds/Release/FreeTool/SolarWinds-LogForwarder-FreeTool-v1.2.0.zip>
  Configure to forward sysmon event logs to Linux syslog server

##  6. <a name='FileHashingandIntegrity'></a>File Hashing and Integrity

- Download: <https://support.microsoft.com/en-us/kb/841290> (FCIV Tool)
- Reference: <https://en.wikibooks.org/wiki/File_Checksum_Integrity_Verifier_(FCIV)_Examples>

###  6.1. <a name='Commands'></a>Commands

- Creating file hashes: ``fciv [directory name] -r -xml fileHashes.xml -sha1``
- Verifying hashes: ``fciv [directory name] -v -xml fileHashes.xml -sha1``
- Without fciv: ``certUtil -hashfile <file> MD5`` (or SHA1, etc.)
- powershell: ``Get-FileHash filename`` (press tab)

##  7. <a name='SettingEnvironmentVariablesAddingtoPath'></a>Setting Environment Variables (Adding to Path)

- Run sysdm.cpl then advanced -> environment variables

##  8. <a name='PolicyEditors'></a>Policy Editors

- Local Group: ``gpedit.msc``
- Local Security: ``secpol.msc``
- GPO - Domain Group: ``gpmc.msc``
  - To reset GPOs in cmd:  ``dcgpofix /target:both``
- Defined groups:
  - Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Restricted Groups
- Passwords:
  - Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policy -> Password Policy
- Check for “store passwords using reversible encryption”
- Banner: Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Local Policies -> Security Options -> Interactive logon: Message text for users attempting to log on
- Windows Update: Computer Configuration -> Policies -> Administrative Templates -> Windows Components -> Windows Update
- Refresh Interval: Computer Configuration -> policies -> administrative templates -> group policy -> group policy refresh interval

##  9. <a name='WindowsRenamingofCMD.exeandPowerShell.exe'></a>Windows Renaming of CMD.exe and PowerShell.exe

 ***write down on paper what you rename it to, IF YOU DO, these are examples and rename something else to CMD and Powershell***

- Open an administrative command prompt:

  ```CMD
  C:\WINDOWS\system32>
  takeown /f C:\Windows\System32\cmd.exe
  icacls C:\Windows\System32\cmd.exe /grant:r Administrators:F
  rename C:\Windows\System32\cmd.exe vpn.com
  takeown /f C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
  icacls C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /grant:r Administrators:F
  rename C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe help.exe
  ```

##  10. <a name='Logging'></a>Logging

- Script to continuously log sessions with time

  ```Powershell
  @echo off
  :loop
  Date /t > con & time /t > con & query session > con & date /t >> sess.txt & time /t >> sess.txt & query session >> sess.txt & timeout /t 120 /nobreak > nul
  Goto loop
  ```

- Logs:
  - Set Audit Policy to log everything:

    ```Powershell
    auditpol /set /category:*(probably shouldn’t run this)
    auditpol /get /category:*
    ```

##  11. <a name='Helpfulshortscripts'></a>Helpful (short) scripts

###  11.1. <a name='ContinualHashingandFileAdditionScript'></a>Continual Hashing and File Addition Script

***Download fciv add to path before***

- InitHashNMap Script

  ``` CMD
  Fciv -r -xml winhv.xml -type *.exe -type*.dll -type *.com -type*.bat -type *.cnv -type*.vbs -type *.ini -type*.sys C:\Windows
  Fciv -r -xml userhv.xml C:\Users
  Dir /s /b C:\Windows | findstr /v “\.log” > winfiles.txt
  Dir /s /b C:\Users | findstr /v “\.log” > userfiles.txt
  ```

- Continual Checker Script

```CMD
:loop
@fciv -v -xml winhv.xml
@fciv -v -xml userhv.xml
@dir /s /b C:\Windows | findstr /v “\.log” > winfiles2.txt
@dir /s /b C:\Users | findstr /v “\.log” > userfiles2.txt
@fc winfiles.txt winfiles2.txt
@fc userfiles.txt userfiles2.txt
@timeout /t 300 /nobreak > nul
Goto loop
```

###  11.2. <a name='ScriptforreverseDNSlookup'></a>Script for reverse DNS lookup

```CMD
For /l %n in (1,1,254) do @nslookup 192.168.12%n | findstr /i “name address” | findstr /v “::” >> names.txt
```

###  11.3. <a name='Scriptforpingscan'></a>Script for ping scan

```cmd
For /l %n in (1,1, 254) do @ping -n 1 192.168.12.%n | findstr /i “reply time” | findstr /v “unreachable milli out” >> ipaddress.txt
```

##  12. <a name='NET'></a>NET

- Display a local share

  ```Powershell
  NET SHARE sharename
  ```

- Display a list of computers in the current domain.

  ```Powershell
  NET VIEW
  ```

- To see a list of shares on a remote computer

  ```Powershell
  NET VIEW \\ComputerName
  ```

- To see a list of all shares in the domain:

  ```Powershell
  NET VIEW /DOMAIN
  ```

- To see a list of shares on a different domain

  ```Powershell
  NET VIEW /DOMAIN:domainname
  ```

- To see a list of shares on a remote Netware computer

  ```Powershell
  NET VIEW /NETWORK:NW [\\ComputerName]
  ```

- Create a new local file share

  ```Powershell
  NET SHARE sharename=drive:path /REMARK:"text" [/CACHE:Manual | Automatic | No ]
  ```

- Limit the number of users who can connect to a share

  ```Powershell
  NET SHARE sharename /USERS:number /REMARK:"text"
  ```

- Remove any limit on the number of users who can connect to a share

  ```Powershell
  NET SHARE sharename /UNLIMITED /REMARK:"text"
  ```

- Delete a share

  ```Powershell
  NET SHARE {sharename | devicename | drive:path} /DELETE
  ```

- Delete all shares that apply to a given device

  ```Powershell
  NET SHARE devicename /DELETE
  ```

In this case the devicename can be a printer (Lpt1) or a pathname (C:\Docs\)
- Join a file share (Drive MAP)

  ```Powershell
  NET USE
  ```

- Display all the open shared files on a server and the lock-id

  ```Powershell
  NET FILE
  ```

- Close a shared file (disconnect other users and remove file locks)

  ```Powershell
  NET FILE id /CLOSE
  ```

- List all sessions connected to this machine

  ```Powershell
  NET SESSION
  ```

- List sessions from a given machine

  ```Powershell
  NET SESSION \\ComputerName
  ```

- Disconnect all sessions connected to this machine

  ```Powershell
  NET SESSION /DELETE
  ```

- Disconnect all sessions connected to this machine (without any prompts)

  ```Powershell
  NET SESSION /DELETE /y
  ```

- Disconnect sessions from a given machine

  ```Powershell
  NET SESSION \\ComputerName /DELETE
  ```

Notes: NET SESSION displays incoming connections only, in other words it must be run on the machine that is acting as the server. To create file shares the SERVER service must be running, which in turn requires 'File and Print Sharing' to be installed.


##  13. <a name='ConstrainedLanguageMode'></a>Constrained Language Mode

- Set Contrained Language Mode

  ```Powershell
  [Environment]::SetEnvironmentVariable(‘__PSLockdownPolicy‘, ‘4’, ‘Machine‘) 
  ```

- Remove Constrained Language Mode:
  - sysdm.cpl -> advanced -> environment variables delete__PSLockdownPolicy
Check Language Mode:
- $ExecutionContext.SessionState.LanguageMode

##  14. <a name='RUNCOMMANDS'></a>RUN COMMANDS

- AD Domains and Trusts
``domain.msc``
- Active Directory Management
``admgmt.msc``
- AD Sites and Services
``dssite.msc``
- AD Users and Computers
``dsa.msc``
- ADSI Edit
``adsiedit.msc``
- Authorization manager
``azman.msc``
- Certification Authority Management
``certsrv.msc``
- Certificate Templates
``certtmpl.msc``
- Cluster Administrator
``cluadmin.exe``
- Computer Management
``compmgmt.msc``
- Component Services
``comexp.msc``
- Configure Your Server
``cys.exe``
- Device Manager
``devmgmt.msc``
- DHCP Management
``dhcpmgmt.msc``
- Disk Defragmenter
``dfrg.msc``
- Disk Manager
``diskmgmt.msc``
- Distributed File System
``dfsgui.msc``
- DNS Management
``dnsmgmt.msc``
- Event Viewer
``eventvwr.msc``
- Indexing Service Management
``ciadv.msc``
- IP Address Manage
``ipaddrmgmt.msc``
- Licensing Manager
``llsmgr.exe``
- Local Certificates Management
``certmgr.msc``
- Local Group Policy Editor
``gpedit.msc``
- Local Security Settings Manager
``secpol.msc``
- Local Users and Groups Manager
``lusrmgr.msc``
- Network Load balancing
``nlbmgr.exe``
- Performance Monitor
``perfmon.msc``
- PKI Viewer
``pkiview.msc``
- Public Key Management
``pkmgmt.msc``
- Quality of Service Control Management
``acssnap.msc``
- Remote Desktop
``tsmmc.msc``
- Remote Storage Administration
``rsadmin.msc``
- Removable Storage
``ntmsmgr.msc``
- Removable Storage Operator Requests
``ntmsoprq.msc``
- Routing and Remote Access Manager
``rrasmgmt.msc``
- Resultant Set of Policy
``rsop.msc``
- Schema management
``schmmgmt.msc``
- Services Management
``services.msc``
- Shared Folders
``fsmgmt.msc``
- SID Security Migration
``sidwalk.msc``
- Telephony Management
``Tapimgmt.msc``
- Task Manager
``Taskschd.msc``
- Task Manager
``taskmgr``
- Terminal Server Configuration
``tscc.msc``
- Terminal Server Licensing
``licmgr.exe``
- Terminal Server Manager
``tsadmin.exe``
- Teminal Services RDP MSTSC
``Teminal Services RDP to Console mstsc /v:[server] /console``
- UDDI Services Managment
``uddi.msc``
- Windows Mangement Instumentation
``wmimgmt.msc``
- WINS Server manager
``Winsmgmt.msc``
