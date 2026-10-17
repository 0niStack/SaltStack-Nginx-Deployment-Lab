# Salt Nginx Project (1 master + 2 minions)

Deploys an Nginx website on two minions (`web1`, `web2`) from one Salt master.

```
            +------------------+
            |  salt-master     |  4505/tcp, 4506/tcp
            +--------+---------+
                     |
          +----------+----------+
          |                     |
     +----+-----+          +----+-----+
     |  web1    |          |  web2    |   80/tcp
     | (minion) |          | (minion) |
     +----------+          +----------+
```

## Layout
```
config/master.d/roots.conf        master file_roots / pillar_roots
config/minion.d/master.conf.tpl   minion config template
salt/top.sls                      targets 'web*' -> nginx
salt/nginx/init.sls               install, site config, index, service
salt/nginx/files/*.jinja          site.conf + index.html templates
pillar/nginx.sls                  site name, port, title, web root
scripts/                          install-master / install-minion / accept-keys / deploy
```

## Requirements
- 3 Ubuntu 22.04/24.04 VMs that can reach each other
- Security groups: master allows 4505-4506/tcp from minions; minions allow 80/tcp
- Copy this project to all 3 VMs (scp -r or git clone)

## Steps
1. Master
   ```bash
   sudo ./scripts/install-master.sh
   ```
2. Minion 1 and 2 (use the master's private IP)
   ```bash
   sudo ./scripts/install-minion.sh 10.0.1.10 web1
   sudo ./scripts/install-minion.sh 10.0.1.10 web2
   ```
   Minion IDs must start with `web` to match `salt/top.sls`.
3. Master: accept keys
   ```bash
   sudo ./scripts/accept-keys.sh
   ```
4. Master: deploy
   ```bash
   sudo ./scripts/deploy.sh
   ```
5. Browse `http://<web1-ip>` and `http://<web2-ip>`; each page shows its minion id.

## Customize
Edit `pillar/nginx.sls` (title, port, server_name), then `make apply`.
Replace `salt/nginx/files/index.html.jinja` with your own site.

## Troubleshooting
- `salt-key -L` empty: check `/var/log/salt/minion` on the minion and that 4505/4506 are reachable
- Master IP changed: edit `/etc/salt/minion.d/master.conf`, then `systemctl restart salt-minion`
- Show pillar: `sudo salt web1 pillar.items`
