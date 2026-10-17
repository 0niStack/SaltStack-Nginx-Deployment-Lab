#!/usr/bin/env bash
# Run on the MASTER: list and accept pending minion keys
set -euo pipefail
salt-key -L
read -rp "Accept ALL pending keys? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  salt-key -A -y
  sleep 3
  salt '*' test.ping
fi
