User and Authentication:

    Add a user: useradd username
        Create with custom id (ex. 5000): -u 5000 before username
    Change user password: passwd username
    Add new group: groupadd groupname
        Create with custom id (ex. 5000): -g 5000
    Change user primary group: usermod -g groupname username
    Add user to supplementary group: usermod --append -G groupname username
        Grant sudo privileges: usermod --append -G wheel username
        Admin: usermod --append -G system-administrators username
    Overwrite all supplementary groups: usermod -G comma-separated-groupnames username

    Create group directory:
        Associate directory with group: chgrp groupname directory
        Change permissions to directory: chmod g+rwxs directory

    Remove user:
        Log user out: loginctl terminate-user username
        Remove user: userdel user-name
            Remove user, home directory, mail, SELinux: userdel --remove --selinux-user username
            Remove additional metadata: rm -rf /var/lib/AccountsService/users/username

    Add a user to FreeIPA: ipa user-add username
    Change user password: ipa passwd username

    Create sudo privilege rule called sysadmin_sudo: ipa sudorule-add sysadmin_sudo --hostcat=all --runasusercat=all --runasgroupcat=all --cmdcat=all
    Add sysadmin group to sudo rule: ipa sudorule-add-user sysadmin_sudo --group sysadmin

System Services:

    List all system units: systemctl
        To only see services: --type=service
        To only see active ones: --state=active
    Start a service: systemctl start service_name
    Stop a service: systemctl stop service_name
    Restart a service: systemctl restart service_name
    Enable a service to start on boot: systemctl enable service_name

Network and FreeIPA Configuration:

    Display network configuration: ifconfig or ip addr show
    Check FreeIPA server status: ipa-server-install --check-status
    Configure FreeIPA settings: ipa-server-install

Security:

    Update packages that have errata to latest version / earliest fixed version: yum update --security / yum update-minimal --security
    Check for open ports: netstat -tulpn

Backup and Restore:

    Backup FreeIPA (stored in /var/lib/ipa/backup/): ipa-backup
    Restore FreeIPA from backup: ipa-restore /path/to/backup

Basic Security:

    Display status: systemctl status firewalld
    To start firewalld: systemctl enable --now firewalld
    Check status of SELinux: getenforce
    Set SELinux to enforcing mode (instead of permissive): setenforce Enforcing
    Set SELinux to persist: Set SELINUX variable in /etc/selinux/config to enforcing/permissive/disabled
