#!/bin/bash
# Uninstalls the Proxmox VE detection pack.
# Usage: sudo ./uninstall.sh
set -e

OSSEC="/var/ossec"
[ "$(id -u)" -eq 0 ] || { echo "Run this script as root (sudo)."; exit 1; }

rm -f "$OSSEC/etc/decoders/proxmox-pack_decoders.xml" \
      "$OSSEC/etc/rules/proxmox-pack_rules.xml"
echo "[*] Files removed. Restarting Wazuh..."
"$OSSEC/bin/wazuh-control" restart
echo "[OK] Proxmox VE pack uninstalled."
