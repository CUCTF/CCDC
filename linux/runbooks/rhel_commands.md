# RHEL and IPA cheatsheet

- [User and Authentication](#user-and-authentication)
  - [Setup New User](#user-setup)
  - [Remove User](#remove-user)
- [Groups](#groups)
  - [Permissions](#permissions)
  - [Create Group Directory](#create-group-directory)
- [System Services](#system-services)
- [Network](#network)
- [FreeIPA](#freeipa)
- [Backup and Restore](#backup-and-restore)
- [Basic Security](#basic-security)
  - [SELinux](#selinux)
  
## User and Authentication

### User Setup

- Add a user:

  ```console
  useradd [username]
  ```

  - Create with custom id (ex. 5000):
  
    ```console
    useradd -u 5000 [username]
    ```

- Change user password:

  ```console
  passwd [username]
  ```

### Remove user

- Log user out:

  ```console
  loginctl terminate-user [username]
  ```

- Remove user:

  ```console
  userdel [username]
  ```

  - Remove user, home directory, mail, SELinux:

      ```console
      userdel --remove --selinux-user [username]
      ```

  - Remove additional metadata:

      ```console
      rm -rf /var/lib/AccountsService/users/username
      ```

## Groups

- Add new group:
  
  ```console
  groupadd [groupname]
  ```

  - Create with custom id (ex. 5000):

    ```console
    groupadd -g 5000 [groupname]
    ```

- Change user primary group:
  
  ```console
  usermod -g [groupname] [username]
  ```

- Add user to supplementary group:
  
  ```console
  usermod --append -G [groupname] [username]
  ```

### Permissions

- Grant sudo privileges:
  
  ```console
  usermod --append -G wheel [username]
  ```

- Admin:
  
  ```console
  usermod --append -G [system-administrators] [username]
  ```

- Overwrite all supplementary groups:
  
  ```console
  usermod -G [comma-separated-groupnames] [username]
  ```

### Create group directory

- Associate directory with group:
  
  ```console
  chgrp [groupname] [directory]
  ```

- Change permissions to directory:
  
  ```console
  chmod g+rwxs [directory]
  ```

- Create sudo privilege rule called sysadmin_sudo:

  ```console
  ipa sudorule-add sysadmin_sudo --hostcat=all -runasusercat=all --runasgroupcat=all --cmdcat=all
  ```

- Add sysadmin group to sudo rule:

  ```console
  ipa sudorule-add-user sysadmin_sudo --group sysadmin
  ```

## FreeIPA

- Add a user to FreeIPA:

  ```console
  ipa user-add [username]
  ```

- Change user password:

  ```console
  ipa passwd [username]
  ```

- Check FreeIPA server status:

  ```console
  ipa-server-install --check-status
  ```

- Configure FreeIPA settings:

  ```console
  ipa-server-install
  ```

## System Services

- List all system units:
  
  ```console
  systemctl
  ```

  - To only see services:

    ```console
    systemctl --type=service
    ```

  - To only see active ones:

    ```console
    systemctl --state=active
    ```

- Start a service:
  
  ```console
  systemctl start [service_name]
  ```

- Stop a service:
  
  ```console
  systemctl stop [service_name]
  ```

- Restart a service:
  
  ```console
  systemctl restart [service_name]
  ```

- Enable a service to start on boot:
  
  ```console
  systemctl enable [service_name]
  ```

## Network

- Display network configuration:

  ```console
  ifconfig 
  ```

  or

  ```console
  ip addr show
  ```

## Backup and Restore

- Backup FreeIPA (stored in ```/var/lib/ipa/backup/```):

  ```console
  ipa-backup
  ```

- Restore FreeIPA from backup:

  ```console
  ipa-restore [/path/to/backup]
  ```

## Basic Security

- Update packages that have errata to latest version earliest fixed version

  ```console
    yum update --security 
    yum update-minimal --security
  ```

- Check for open ports:

  ```console
  netstat -tulpn
  ```

- Display status:

  ```console
  systemctl status firewalld
  ```

- To start firewalld:

  ```console
  systemctl enable --now firewalld
  ```

### SELinux

- Check status of SELinux:

  ```console
  getenforce
  ```

- Set SELinux to enforcing mode (instead of permissive):

  ```console
  setenforce Enforcing
  ```

- Set SELinux to persist
  - Set `SELINUX` variable in ```/etc/selinux/config``` to ```enforcing/permissive/disabled```
