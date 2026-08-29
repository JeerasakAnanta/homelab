# AGENTS.md

Personal home lab: ~25 independent Docker Compose stacks, one per top-level directory. No application code to build or test — all work is compose/config edits. `README.md` has the service catalog, ports, and architecture diagram. `CLAUDE.md` (repo root) is the Claude Code counterpart and agrees with this file.

## Commands

- Start a service: `cd <service> && docker compose -f <actual-filename> up -d`
- Validate without starting: `cd <service> && docker compose config -q`
- Compose filename: canonical is `docker-compose.yaml` (all stacks now use `.yaml`; `.yml` unified in 2026-08). Exceptions:
  - `compose.yaml`: nginx, vaultwarden, vscodeserver (legacy short name — prefer `docker-compose.yaml` for new stacks)
  - Trap: `dozzle/` has BOTH `compose.yaml` (`:latest`, exposes 8080 publicly) and `docker-compose.yaml` (pinned `v10.6.14`, localhost-only, hardened). They diverge — confirm which one the user means before editing.
- `.env.example` exists for `airflow/`, `beszel/`, `dagster/`, `homepage/`, `kafka/`, `n8n/`, `prefect/`, `seaweedfs/`, `sonarqube/` — copy to `.env` first. Other stacks use inline env vars in the compose file.
- Postgres mounts `init-db.sh` into `/docker-entrypoint-initdb.d`; edits only take effect on first volume init, not restart.

## Architecture gotchas

- **No shared network convention.** Each stack defines its own bridge network (`proxy`, `homelab`, `llm_net`, `seaweed_net`, `sonarnet`, `jenkins_network`, external `homelab_net`), and several declare none. Check the actual `networks:` block before wiring a new service to Traefik or another stack; don't silently unify.
- Traefik routing: labels live in each service's own compose file — path-prefix on `api-homelab.jeerasakananta.dev` with a stripprefix middleware (see `coolify/docker-compose.yaml`).
- Default ports overlap (8080: n8n, Open WebUI, SeaweedFS volume, dozzle localhost). Check the target compose file before running two services together.

## Conventions

- Pin image versions explicitly; never `:latest` (see `dozzle/docker-compose.yaml` comments).
- Adding a service: update `README.md` (catalog, mermaid diagram, ports table) AND `.gitignore` (data dirs / secrets) together — history shows both move with a new stack.
- Secrets and persistent data are gitignored (`.env`, `*.pem`, `*.key`, `traefik/acme.json`, `vaultwarden/vw-data`, `homeassistant/config`, `sonarqube/data/`). Never commit them.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `build(scope):`).

## Staleness

- `log-generator/` (fake-log container for log testing) and empty `harbor/`, `data/` exist but are not documented in `README.md` or `CLAUDE.md`.
