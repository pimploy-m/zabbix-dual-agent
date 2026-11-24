#!/bin/bash

###############################################################################
# install_dual_zabbix_agent.sh
#
# Version : 1.0.0
#
# Purpose:
#   Deploy dual Zabbix Agent instances on the same server
#
#   ATKH
#     Config : /etc/zabbix/zabbix_agentd_2.conf
#     Port   : 10060
#
#   AMS
#     Config : /etc/zabbix/zabbix_agentd_ams.conf
#     Port   : 10050
#
###############################################################################

set -e

VERSION="1.0.0"
BUILD_DATE="2026-11-24"

###############################################################################
# PARAMETERS
###############################################################################

ATKH_SERVER="${ATKH_SERVER:-92.120.128.136}"
AMS_SERVER="${AMS_SERVER:-92.120.118.82}"

HOSTNAME_FQDN=$(hostname -f)

###############################################################################

echo
echo "========================================================="
echo " Dual Zabbix Agent Deployment"
echo " Version : ${VERSION}"
echo " Build   : ${BUILD_DATE}"
echo "========================================================="
echo
echo "Hostname    : ${HOSTNAME_FQDN}"
echo "ATKH Server : ${ATKH_SERVER}"
echo "AMS Server  : ${AMS_SERVER}"
echo

###############################################################################
# PRECHECK
###############################################################################

echo "[1/10] Validating prerequisites..."

if [ ! -x /usr/sbin/zabbix_agentd ]; then
    echo "ERROR: /usr/sbin/zabbix_agentd not found"
    exit 1
fi

mkdir -p /etc/zabbix
mkdir -p /run/zabbix
mkdir -p /var/log/zabbix

###############################################################################
# CREATE ATKH CONFIG
###############################################################################

echo "[2/10] Creating ATKH config..."

cat > /etc/zabbix/zabbix_agentd_2.conf <<EOF
PidFile=/run/zabbix/zabbix_agentd_2.pid
LogFile=/var/log/zabbix/zabbix_agentd_2.log

Server=${ATKH_SERVER}
ServerActive=${ATKH_SERVER}

Hostname=${HOSTNAME_FQDN}

ListenPort=10060

Timeout=30
EOF

###############################################################################
# CREATE AMS CONFIG
###############################################################################

echo "[3/10] Creating AMS config..."

cat > /etc/zabbix/zabbix_agentd_ams.conf <<EOF
PidFile=/run/zabbix/zabbix_agentd_ams.pid
LogFile=/var/log/zabbix/zabbix_agentd_ams.log

Server=${AMS_SERVER}
ServerActive=${AMS_SERVER}

Hostname=${HOSTNAME_FQDN}

ListenPort=10050

Timeout=30
EOF

###############################################################################
# CREATE ATKH SERVICE
###############################################################################

echo "[4/10] Creating ATKH service..."

cat > /etc/systemd/system/zabbix-agent-atkh.service <<EOF
[Unit]
Description=Zabbix Monitor Agent (ATKH)
After=network.target

[Service]
Type=simple
User=zabbix
ExecStart=/usr/sbin/zabbix_agentd -f -c /etc/zabbix/zabbix_agentd_2.conf
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

###############################################################################
# CREATE AMS SERVICE
###############################################################################

echo "[5/10] Creating AMS service..."

cat > /etc/systemd/system/zabbix-agent-ams.service <<EOF
[Unit]
Description=Zabbix Monitor Agent (AMS)
After=network.target

[Service]
Type=simple
User=zabbix
ExecStart=/usr/sbin/zabbix_agentd -f -c /etc/zabbix/zabbix_agentd_ams.conf
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

###############################################################################
# VALIDATE CONFIG
###############################################################################

echo "[6/10] Validating configurations..."

zabbix_agentd -t agent.ping -c /etc/zabbix/zabbix_agentd_2.conf >/dev/null

zabbix_agentd -t agent.ping -c /etc/zabbix/zabbix_agentd_ams.conf >/dev/null

###############################################################################
# STOP EXISTING AGENTS (IF ANY)
###############################################################################

echo "[7/10] Cleaning existing processes..."

systemctl stop zabbix-agent-atkh 2>/dev/null || true
systemctl stop zabbix-agent-ams 2>/dev/null || true

pkill zabbix_agentd 2>/dev/null || true

rm -f /run/zabbix/zabbix_agentd_2.pid
rm -f /run/zabbix/zabbix_agentd_ams.pid

###############################################################################
# RELOAD SYSTEMD
###############################################################################

echo "[8/10] Reloading systemd..."

systemctl daemon-reload

###############################################################################
# ENABLE SERVICES
###############################################################################

echo "[9/10] Enabling services..."

systemctl enable zabbix-agent-atkh
systemctl enable zabbix-agent-ams

###############################################################################
# START SERVICES
###############################################################################

echo "[10/10] Starting services..."

systemctl restart zabbix-agent-atkh
systemctl restart zabbix-agent-ams

###############################################################################
# VERIFICATION
###############################################################################

echo
echo "========================================================="
echo " Verification"
echo "========================================================="
echo

echo "Service Status"
echo "------------------------------------------"

systemctl is-active zabbix-agent-atkh
systemctl is-active zabbix-agent-ams

echo
echo "Service Startup"
echo "------------------------------------------"

systemctl is-enabled zabbix-agent-atkh
systemctl is-enabled zabbix-agent-ams

echo
echo "Listening Ports"
echo "------------------------------------------"

ss -tlnp | egrep '10050|10060'

echo
echo "Agent Processes"
echo "------------------------------------------"

ps -ef | grep "[z]abbix_agentd"

echo
echo "Deployment completed successfully."
echo
