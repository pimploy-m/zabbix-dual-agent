#!/bin/bash

echo "Stopping services..."
systemctl stop zabbix-agent-atkh || true
systemctl stop zabbix-agent-ams || true

echo "Disabling services..."
systemctl disable zabbix-agent-atkh || true
systemctl disable zabbix-agent-ams || true

echo "Removing service files..."
rm -f /etc/systemd/system/zabbix-agent-atkh.service
rm -f /etc/systemd/system/zabbix-agent-ams.service

echo "Removing config files..."
rm -f /etc/zabbix/zabbix_agentd_2.conf
rm -f /etc/zabbix/zabbix_agentd_ams.conf

echo "Removing PID files..."
rm -f /run/zabbix/zabbix_agentd_2.pid
rm -f /run/zabbix/zabbix_agentd_ams.pid

if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo "Restoring backup from $BACKUP_DIR"

    cp -p "$BACKUP_DIR"/*.conf /etc/zabbix/ 2>/dev/null || true
    cp -p "$BACKUP_DIR"/*.service /etc/systemd/system/ 2>/dev/null || true
fi

echo "Reloading systemd..."
systemctl daemon-reload

echo "Rollback completed."
