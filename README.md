# Hermes Excalibur Provisioning

Personal Hermes setup on Raspberry Pi 4 8GB + Samsung SSD T7 1TB.

Ansible prototype for provisioning `excalibur`, the always-on Raspberry Pi 4
host for domain-isolated Hermes agents.

## Target

- Host: Raspberry Pi 4, arm64 Debian/Raspberry Pi OS
- Current bootstrap address: `192.168.64.39`
- Production hostname: `excalibur`
- Production storage: Samsung T7, serial `S7MLNL0L313066X`

## Agent Domains

The system uses separate Hermes containers by trust boundary:

- `hermes-openadviser`: Miro, Openadviser administrative assistant
- `hermes-syndiary`: Enid, Syndiary admin and organisational knowledge gatherer
- `hermes-family`: Mary, home and family administration
- `hermes-personal`: Lunete, personal coach and assistant

Each domain gets its own `/srv/excalibur/agents/<domain>` tree, `SOUL.md`,
`config.yaml`, secrets file, workspace, logs, and Docker container.

## First Commands

```sh
cd ~/Development/personal/hermes

# Verify Ansible can reach the current Pi.
ansible all -m ping

# Read-only preflight against the live target.
ansible-playbook playbooks/00-preflight.yml

# Syntax check all non-destructive provisioning.
ansible-playbook playbooks/site.yml --syntax-check
```

## Provisioning Order

1. `playbooks/00-preflight.yml`: read-only hardware, OS, and storage checks.
2. `playbooks/10-t7-root.yml`: destructive T7 boot/root migration. This is
   intentionally not part of `site.yml`.
3. `playbooks/site.yml`: base OS, hardening, Docker, Tailscale, Cloudflare
   tooling, and Hermes container layout.

The T7 migration refuses to run unless this explicit flag is passed:

```sh
ansible-playbook playbooks/10-t7-root.yml \
  -e excalibur_t7_confirm_destroy=true
```

After the T7 migration completes, power down, remove the microSD card, and boot
from the T7. Then update `inventories/excalibur/hosts.yml` if the LAN address
changes.

## Auth-Bound Steps

These are prepared by Ansible but require manual or secret-backed activation:

- Tailscale: set `tailscale_auth_key` or run `sudo tailscale up --hostname excalibur`.
- Cloudflare Tunnel: set `cloudflare_tunnel_token` or run `cloudflared tunnel login`.
- Slack/Google/GitHub/Linear: fill each agent's secrets file under
  `/srv/excalibur/agents/<domain>/secrets/hermes.env`.

Do not commit real tokens to this repository.
