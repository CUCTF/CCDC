# Wazuh Notes

# Installing Wazuh Dashboard, Server, and Indexer

```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```

If curl isn’t working, you can find [wazuh-install.sh](http://wazuh-install.sh) in this directory and directly run

```xml
sudo bash ./wazuh-install.sh -a
```

# First Steps after installation

1. After logging into dashboard, change password
    1. Might be unable to change pw through dashboard. In this case, go to machine thats running Wazuh server and vim /etc/filebeat/filebeat.yml
    2. In that yml file, change the password
2. In Management (accessing from Wazuh dashboard)
    1. You can find **rules** under Management > Rules
    2. Enable vulnerability detector in Management > Configuration > Vulnerabilities. Reduce min_full_scan_interval to something on the order of minutes.
    3. Turn on Debian, Ubuntu, Windows OS, etc. vulnerabilties based on what operating systems we are using
3. Restart Manager to ensure changes to management configuration go through. If you change config file after agents have already been added, you will need to restart the agents with “systemctl restart wazuh-agent” on linux and “Restart-Service wazuh-agent” on windows

# Active Response

- Go to Management > Configuration > “edit configuration”. Scroll down to Active Response section. **To add automated active response, we can add the following code.**

```xml
<active-response>
	<command>firewall-drop</command>
	<location>local</location>
	<rules_id>5710</rules_id>
	<timeout>1000</timeout>
</active-response>
```

This active-response responds to brute force login attempts (Rule 5710) by timing out the attacker for 1000 seconds. Remember to restart the manager after editing the config file!

# Adding Agents

- Remember to fix the dashboard configuration file first before adding agents. If you add agents and then make changes to the dashboard config file, you will need to restart each agent

# Important Commands

- To stop, start, restart, or enable the wazuh-manager or wazuh-agent, run the following:
    - on linux:
    
    ```xml
    systemctl [restart/status/enable/start/stop] [wazuh-manager/wazuh-agent]
    ```
    
    - on macos (agent only):
    
    ```xml
    sudo /Library/Ossec/bin/wazuh-control [restart/status/enable/start/stop]
    ```