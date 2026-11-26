# zabbix-dual-agent
Author: Pimploy M.

Reusable Dual Zabbix Agent Deployment Package for Linux servers.

This package enables two independent Zabbix Agent instances to run simultaneously on the same server and be managed through separate systemd services.

## Supported Platforms

- RHEL 8
- RHEL 9
- Zabbix Agent 7.x

## Agent Configuration

| Agent | Port | Purpose |
|---------|---------|---------|
| #1 | 10060 | #1 Zabbix Monitoring |
| #2 | 10050 | #2 Zabbix Monitoring |

Both agents:
- Run independently on the same server
- Use separate configuration files
- Use separate PID and log files
- Start automatically after reboot
- Are managed by dedicated systemd services

## Repository Structure

```text
zabbix-dual-agent/
├── README.md
├── install_dual_zabbix_agent.sh
├── rollback/
│   └── uninstall_dual_zabbix_agent.sh
├── templates/
│   └── TBU
└── docs/
    └── deployment-guide.md
