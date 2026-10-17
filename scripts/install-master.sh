#!/usr/bin/env bash
# Run on the MASTER VM (Ubuntu 22.04/24.04) from the project root: sudo ./scripts/install-master.sh
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root (sudo)"; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[1/4] Installing salt-master (official bootstrap)..."
apt-get update -y && apt-get install -y curl rsync
curl -fsSL https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh -o /tmp/bootstrap-salt.sh
sh /tmp/bootstrap-salt.sh -M -N -X stable

echo "[2/4] Copying config, states and pillar..."
mkdir -p /etc/salt/master.d /srv/salt /srv/pillar
cp "$ROOT"/config/master.d/*.conf /etc/salt/master.d/
rsync -a --delete "$ROOT/salt/"   /srv/salt/
rsync -a --delete "$ROOT/pillar/" /srv/pillar/

echo "[3/4] Starting salt-master..."
systemctl enable --now salt-master
systemctl restart salt-master

echo "[4/4] Done. Open ports 4505/tcp and 4506/tcp to the minions."
echo "Next: install minions, then run ./scripts/accept-keys.sh"
