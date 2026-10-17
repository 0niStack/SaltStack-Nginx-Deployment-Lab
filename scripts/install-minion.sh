#!/usr/bin/env bash
# Run on each MINION VM: sudo ./scripts/install-minion.sh <MASTER_IP> <MINION_ID>
# Example: sudo ./scripts/install-minion.sh 10.0.1.10 web1
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root (sudo)"; exit 1; }
MASTER_IP="${1:?Usage: $0 <MASTER_IP> <MINION_ID>}"
MINION_ID="${2:?Usage: $0 <MASTER_IP> <MINION_ID>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[1/3] Installing salt-minion..."
apt-get update -y && apt-get install -y curl
curl -fsSL https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh -o /tmp/bootstrap-salt.sh
sh /tmp/bootstrap-salt.sh -X stable

echo "[2/3] Configuring minion (master=$MASTER_IP id=$MINION_ID)..."
mkdir -p /etc/salt/minion.d
sed -e "s/__MASTER_IP__/${MASTER_IP}/" -e "s/__MINION_ID__/${MINION_ID}/" \
  "$ROOT/config/minion.d/master.conf.tpl" > /etc/salt/minion.d/master.conf
echo "$MINION_ID" > /etc/salt/minion_id

echo "[3/3] Starting salt-minion..."
systemctl enable --now salt-minion
systemctl restart salt-minion
echo "Done. Now accept the key on the master: sudo ./scripts/accept-keys.sh"
