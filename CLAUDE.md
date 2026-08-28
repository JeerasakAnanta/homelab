# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal home lab: a collection of ~25 independent Docker Compose stacks (monitoring, CI/CD, automation/AI, storage, dev tools, security), each living in its own top-level directory. There is no application code to build or test — changes here are Docker Compose / config edits. See `README.md` for the full service catalog, ports, and mermaid architecture diagram.

## Commands

Each service is started independently from its own directory:

```bash
cd <service> && docker-compose up -d      # most services use docker-compose.yaml/.yml
cd <service> && docker compose -f compose.yaml up -d   # dozzle, nginx, vaultwarden, vscodeserver use compose.yaml
```

There is no root-level `docker-compose.homelab.yml` or unified stack file currently in the repo, despite the README describing one — treat each service directory as standalone unless the user is actively adding that unification.

Validate a compose file without starting it:

```bash
cd <service> && docker compose config -q
```

For services with a `.env.example` (`n8n/`, `seaweedFS/`, `sonarqube/`), copy it to `.env` before starting: `cp .env.example .env`.

## Architecture notes

**No shared network convention — check before editing.** Despite `traefik/README.md` documenting a single `proxy` network that all Traefik-routed services should join, in practice each stack defines its *own* bridge network with a different name (`traefik` → `proxy`, `kuma`/`glance`/`homepage` → `homelab`, `ollama` → `llm_net`, `seaweedFS` → `seaweed_net`, `sonarqube` → `sonarnet`, `jenkins` → `jenkins_network`, `nginx` → external `homelab_net`). Several stacks (`coolify`, `n8n`, `dockge`, `dozzle`, `vaultwarden`) declare no network at all. When wiring a new service to Traefik or another stack, check the actual `networks:` block in that service's compose file rather than assuming a shared network exists — don't silently "fix" this inconsistency as part of an unrelated change.

**Traefik routing pattern**: Services proxied through Traefik (see `coolify/docker-compose.yaml` for the reference example) use path-prefix routing off a single hostname (`api-homelab.jeerasakananta.dev`) via labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<name>.rule=Host(`api-homelab.jeerasakananta.dev`) && PathPrefix(`/<name>`)"
  - "traefik.http.routers.<name>.entrypoints=websecure"
  - "traefik.http.routers.<name>.tls.certresolver=cloudflare"
  - "traefik.http.middlewares.<name>-strip.stripprefix.prefixes=/<name>"
  - "traefik.http.routers.<name>.middlewares=<name>-strip"
```

Most other services are reached directly on their own port instead (see the Ports table in `README.md`); several ports overlap by default (n8n, Open WebUI, Jenkins internal all default near 8080) so check the target compose file before running two of them together.

**Per-service config directories**: config lives alongside each compose file, not in a shared location — e.g. `glance/config/`, `traefik/config/dynamic.yml` + `traefik.yml`, `prometheus/prometheus.yml`, `netdata/netdataconfig/`. Bind-mounted data directories (`*-data/`, `vaultwarden/vw-data`, `homeassistant/config`, `sonarqube/data/`, etc.) and all secrets (`.env`, `*.pem`, `*.key`, `traefik/acme.json`) are gitignored — check `.gitignore` before adding new persistent paths for a service.

## Conventions

- Commit messages follow Conventional Commits (`feat:`, `fix:`, `build(scope):`), matching `git log`.
- Compose files pin image versions explicitly rather than using `:latest` (see `dozzle/docker-compose.yaml` comments for the rationale) — follow this when adding or bumping a service image.
- When adding a new service, update both `README.md` (service list, mermaid diagram, ports table) and `.gitignore` (data dirs / secrets for that service) as part of the change — this repo's history shows both are expected to move together with a new stack.

## Agent skills

### Issue tracker

Issues and specs live as GitHub issues in `JeerasakAnanta/homelab`, managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical triage roles, each label string equal to its name. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root (created lazily). See `docs/agents/domain.md`.
