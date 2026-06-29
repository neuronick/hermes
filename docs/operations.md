# Excalibur Operations

## Safe Validation

```sh
ansible-playbook playbooks/00-preflight.yml
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --check
```

Inventory targets Excalibur over Tailscale at `100.75.126.41`. The LAN address
`192.168.64.39` remains a fallback if the tailnet is unavailable.

## T7 Boot Migration

The migration is destructive to the Samsung T7. It verifies the USB disk serial
before wiping:

```sh
ansible-playbook playbooks/10-t7-root.yml \
  -e excalibur_t7_confirm_destroy=true
```

When it completes:

1. Power down the Pi.
2. Remove the microSD card.
3. Boot with the Samsung T7 connected to USB 3.
4. Verify root:

```sh
findmnt -no SOURCE,FSTYPE,OPTIONS /
hostname
```

## Agent Secrets

Each domain has a separate secrets file:

```text
/srv/excalibur/agents/openadviser/secrets/hermes.env
/srv/excalibur/agents/syndiary/secrets/hermes.env
/srv/excalibur/agents/family/secrets/hermes.env
/srv/excalibur/agents/personal/secrets/hermes.env
```

Start with only `openadviser` configured, then add the other domains after the
runtime is stable.

## Enabling Agent Domains

Set `enabled: true` for the intended domain in
`inventories/excalibur/group_vars/all.yml`, then apply:

```sh
ansible-playbook playbooks/40-hermes-containers.yml
```

The initial active domain is `openadviser` / Miro only.

## Backups

Backups use restic and are provisioned by:

```sh
ansible-playbook playbooks/50-backup.yml
```

Secrets live only on Excalibur:

```text
/etc/excalibur/backup.env
```

Minimal Synology/NAS-over-SSH setup:

```sh
sudo editor /etc/excalibur/backup.env
```

Set:

```sh
RESTIC_REPOSITORY=sftp:backup-user@nas-host:/volume1/backups/excalibur-restic
RESTIC_PASSWORD=<strong generated password>
RESTIC_INIT_REPOSITORY=true
```

Then test:

```sh
sudo /usr/local/sbin/excalibur-restic backup
sudo /usr/local/sbin/excalibur-restic snapshots
sudo /usr/local/sbin/excalibur-restic check
```

After the first successful backup, set `RESTIC_INIT_REPOSITORY=false` and set
`excalibur_backup_enable_timer: true` in inventory, then reapply
`playbooks/50-backup.yml`.
