#!/usr/bin/env bash
# Run on the MASTER: sync states from the project and apply the nginx site
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
rsync -a --delete "$ROOT/salt/"   /srv/salt/
rsync -a --delete "$ROOT/pillar/" /srv/pillar/

salt '*' saltutil.refresh_pillar
salt '*' test.ping
echo "--- dry run ---"
salt 'web*' state.apply nginx test=True
echo "--- apply ---"
salt 'web*' state.apply nginx
echo "--- verify ---"
salt 'web*' cmd.run 'curl -s -o /dev/null -w "%{http_code}\n" http://localhost'
