---
name: homelab-ops
description: Use when operating the Docker homelab (ssh homelab, host ubuntu-lab) — checking container health, restarting exited services, editing compose stacks, or restricting database ports. Triggers: homelab, unhealthy container, Exited 127, DOCKER-USER, dockhand, mongo-express, postgres-homelab.
---

# Homelab Ops

## Overview

Personal homelab: ~25 independent Docker Compose stacks managed over `ssh homelab`
(`root@178.105.115.150`; fallback `homelab-ts` via Tailscale). Conventions live in
`AGENTS.md` — read it before touching anything.

## Workflow

1. **Inspect before acting.** `docker ps -a`, then `docker inspect` the failing
   container (mounts, exit code, health log). Never blind-restart.
2. **Fix the cause, not the symptom.** Exited containers are usually broken
   mounts or wiped volumes (see Mistakes). A bare `docker start` just replays
   the same `Exited 127`.
3. **Verify after every change:** status, tail of logs, and a real connection
   test (`nc -zv`, `pg_isready`, HTTP code).

## Quick Reference

```bash
ssh homelab 'docker ps -a --format "table {{.Names}}\t{{.Status}}"'
ssh homelab 'docker inspect <name> --format "{{json .Mounts}}"'
ssh homelab 'docker logs --tail 20 <name>'
ssh homelab 'iptables -L DOCKER-USER -n -v --line-numbers'
# DB ports 27017/5432 are blocked from the internet via DOCKER-USER;
# localhost, tailscale0, and inter-container (br+/docker0/veth+) are allowed.
# Rules persist via iptables-persistent — re-save after changes:
ssh homelab 'netfilter-persistent save'
```

## Rules

- Compose filename is `docker-compose.yaml`; pin image versions, never `:latest`.
- `mongodb` / `postgres-homelab` are Dockhand-managed orphans (projects
  `mongodb` / `postgres-lab-db`). Editing outside Dockhand causes drift —
  pick one manager per stack.
- Missing `_data` under `/var/lib/docker/volumes/` means **data is gone**;
  recreating the dir starts a fresh empty DB. Warn before doing it.

## Common Mistakes

| Mistake | Reality |
|---|---|
| `docker start` on `Exited 127` without inspecting | Mount/volume error repeats; read `.State.Error` first |
| Bind-mounting a file whose source is missing | Docker auto-creates a **directory** (the `init-db.sh` case) — replace with a file |
| Removing `ports:` from a DB and assuming it is hidden | `docker-proxy` bypasses UFW; enforce in `DOCKER-USER` chain |
| Treating `(unhealthy)` as app failure | Often the `runc` exec bug after long uptime; app is fine, host needs reboot |
| Editing `dozzle/compose.yaml` vs `docker-compose.yaml` interchangeably | They diverge (`:latest`/public vs pinned/localhost) — confirm which one |
