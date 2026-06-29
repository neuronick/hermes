# 2026-06-29 Excalibur State

## Provisioned

- Hostname set to `excalibur`.
- Boot from the Samsung T7 was verified after microSD removal:
  `/dev/sda2 ext4 rw,noatime,stripe=8191`.
- Samsung T7 is prepared as a bootable Pi OS disk:
  - boot: `/dev/sda1`, `vfat`, label `bootfs`, PARTUUID `f566fc80-b0b0-4c6a-9ab8-c533a7c98057`
  - root: `/dev/sda2`, `ext4`, label `rootfs`, PARTUUID `77362c8f-2cd4-4f87-a323-489aee7b3688`
- T7 filesystem checks passed after migration.
- T7 `cmdline.txt` points to the T7 root PARTUUID.
- T7 copied `/etc/fstab` points to the T7 boot and root PARTUUIDs.

## Hardened / Installed

- SSH hardening drop-in installed and validated.
- UFW enabled:
  - default deny incoming
  - default allow outgoing
  - SSH allowed on Tailscale
  - SSH allowed from LAN fallback
  - mDNS allowed from `192.168.64.0/24`
- `fail2ban` active.
- unattended upgrades enabled.
- journald retention limited.
- kernel hardening sysctls installed.
- Docker installed and active; user was not added to the Docker group.
- Tailscale installed, `tailscaled` active, and authenticated as
  `excalibur` at `100.75.126.41`.
- `cloudflared` installed, no tunnel service installed yet.
- Hermes Docker image pulled: `nousresearch/hermes-agent:latest`.
- No failed systemd units after T7 boot.
- No USB reset, I/O error, undervoltage, or throttling evidence after T7 boot.

## Hermes Domain Layout

Created under `/srv/excalibur`:

- `agents/openadviser`: Miro
- `agents/syndiary`: Enid
- `agents/family`: Mary
- `agents/personal`: Lunete

Each domain has:

- `home/`
- `workspace/`
- `logs/`
- `secrets/hermes.env`

`excalibur-hermes.service` exists but is disabled and stopped until secrets are
configured.

Only `openadviser` / Miro is enabled in the active Docker Compose file. Enid,
Mary, and Lunete are staged on disk but not rendered into the active runtime
until their domain entries are enabled.

## Next Auth / Runtime Steps

- Ansible inventory now uses the Tailscale IP `100.75.126.41`.

- Create/install the Cloudflare Tunnel when public ingress is ready.
- Populate domain-specific `secrets/hermes.env` files.
- Enable `excalibur-hermes.service` only after at least one domain has valid
  credentials.
