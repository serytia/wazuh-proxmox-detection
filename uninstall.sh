#!/bin/bash
# Desinstalle le pack de detection Proxmox VE.
# Usage : sudo ./uninstall.sh
set -e

OSSEC="/var/ossec"
[ "$(id -u)" -eq 0 ] || { echo "Lancez ce script en root (sudo)."; exit 1; }

rm -f "$OSSEC/etc/decoders/proxmox-pack_decoders.xml" \
      "$OSSEC/etc/rules/proxmox-pack_rules.xml"
echo "[*] Fichiers retires. Redemarrage de Wazuh..."
"$OSSEC/bin/wazuh-control" restart
echo "[OK] Pack Proxmox VE desinstalle."
