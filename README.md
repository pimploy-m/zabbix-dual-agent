# zabbix-dual-agent
Dual Zabbix Agent Deployment

#name Agent
Port 10060
Config: /etc/zabbix/zabbix_agentd_2.conf

#name Agent
Port 10050
Config: /etc/zabbix/zabbix_agentd_ams.conf

Install
chmod +x install_dual_zabbix_agent.sh

./install_dual_zabbix_agent.sh

Verify
systemctl status zabbix-agent-atkh systemctl status zabbix-agent-ams

ss -tlnp | egrep '10050|10060'
