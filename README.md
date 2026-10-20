# 🧪 Homelab

This repository contains the configuration and documentation for my home lab setup, featuring monitoring, visualization, automation, CI/CD, storage, data engineering, AI/ML, and developer tooling services running on Docker containers.

## 🏗️ Architecture

```mermaid
graph TD
    User([User / Internet])

    subgraph Host [Docker Host ubuntu-lab]
        Traefik[Traefik Proxy<br/>80/443/8080<br/>network: proxy]
        Nginx[Nginx<br/>80/443<br/>network: homelab_net (ext)]

        subgraph ProxiedViaTraefik [Proxied via Traefik]
            Coolify[Coolify<br/>/coolify]
            Dozzle[Dozzle<br/>/logs]
        end

        subgraph DirectAccess [Direct Port Access]
            Glance[Glance<br/>8080]
            Kuma[Uptime Kuma<br/>3001]
            Grafana[Grafana<br/>3080]
            Netdata[Netdata<br/>19999 (host net)]
            Prometheus[Prometheus<br/>9090]
            Homepage[Homepage<br/>3030]
            Beszel[Beszel Hub<br/>8090]
            Dockge[Dockge<br/>5001]
            Jenkins[Jenkins<br/>8888/50000]
            SonarQube[SonarQube<br/>9000]
            n8n[n8n<br/>5678]
            Dagster[Dagster<br/>3070]
            Prefect[Prefect<br/>4200]
            Kafka[Kafka Broker<br/>9092]
            RedpandaConsole[Redpanda Console<br/>8085]
            OpenWebUI[Open WebUI<br/>8080]
            Ollama[Ollama<br/>11434 (internal)]
            EMQX[EMQX<br/>1883/8083/18083]
            Vaultwarden[Vaultwarden<br/>configurable]
            VSCodeServer[code-server<br/>8443]
            Excalidraw[Excalidraw<br/>3000]
            SeaweedFS[SeaweedFS<br/>9333/8080/8888/8333]
            Syncthing[Syncthing<br/>8384/22000/21027]
            HomeAssistant[Home Assistant<br/>host net]
            Postgres[Postgres<br/>configurable]
            ClickHouse[ClickHouse<br/>8123/9000]
            MongoDB[MongoDB<br/>27017]
            MongoExpress[Mongo Express<br/>8081]
            Airflow[Airflow<br/>8088]
            JupyterLab[JupyterLab<br/>8888]
            NginxProxyMgr[Nginx Proxy Mgr<br/>80/81/443]
            Harbor[Harbor<br/>TBD]
            LogGenerator[Log Generator<br/>no ports]
            Loki[Loki<br/>3100]
            Promtail[Promtail<br/>9080]
            Alertmanager[Alertmanager<br/>9093]
            Jaeger[Jaeger<br/>16686/4317/4318]
        end

        subgraph Observability [Observability Stack]
            Loki
            Promtail
            Alertmanager
            Jaeger
        end

        subgraph SecurityInfra [Security & Infra]
            Vault[Vault<br/>8200]
            Restic[Restic<br/>cron]
        end

        subgraph Databases [Databases]
            Postgres
            ClickHouse
            MongoDB
            SonarQubeDB[(SonarQube PG)]
            PrefectPG[(Prefect PG)]
            DagsterPG[(Dagster PG)]
            AirflowPG[(Airflow PG)]
        end
    end

    User -->|80/443| Traefik
    User -->|80/443| Nginx
    User -->|8080| Glance
    User -->|3001| Kuma
    User -->|3080| Grafana
    User -->|19999| Netdata
    User -->|9090| Prometheus
    User -->|3030| Homepage
    User -->|8090| Beszel
    User -->|5001| Dockge
    User -->|8888| Jenkins
    User -->|9000| SonarQube
    User -->|5678| n8n
    User -->|3070| Dagster
    User -->|4200| Prefect
    User -->|9092| Kafka
    User -->|8085| RedpandaConsole
    User -->|8080| OpenWebUI
    User -->|1883| EMQX
    User -->|8443| VSCodeServer
    User -->|3000| Excalidraw
    User -->|8384| Syncthing
    User -->|8088| Airflow
    User -->|8888| JupyterLab
    User -->|81| NginxProxyMgr
    User -->|80/443| NginxProxyMgr
    User -->|8080| Dozzle
    User -->|3100| Loki
    User -->|9093| Alertmanager
    User -->|16686| Jaeger
    User -->|8200| Vault
    Traefik -->|/logs| Dozzle
    Traefik -->|/coolify| Coolify
```

> **Network Note:** Each stack defines its own bridge network (`proxy`, `homelab`, `llm_net`, `seaweed_net`, `sonarnet`, `jenkins_network`, `dagster_net`, `prefect_net`, `kafka_net`, `loki_net`, `alertmanager_net`, `jaeger_net`, `vault_net`, `restic_net`, external `homelab_net`). There is no shared network convention — check each compose file before wiring services together.

## 📦 Services

### Monitoring & Observability

#### 1. Glance Dashboard
Web-based dashboard providing an overview of the home lab environment.
- **Port**: `${GLANCE_PORT:-8080}` (default 8080, configurable via `.env`)
- **Features**: Service status monitoring, Docker container widget
- **Location**: [glance/](glance/)

#### 2. Grafana
Open-source analytics and interactive visualization platform.
- **Port**: 3080
- **Config**: Environment variables in `docker-compose.yaml` (admin user/pass, domain, root URL)
- **Location**: [grafana/](grafana/)

#### 3. Netdata
Real-time performance and health monitoring.
- **Network**: Host network mode (port 19999)
- **Config**: `netdata/netdataconfig/`
- **Location**: [netdata/](netdata/)

#### 4. Prometheus
Monitoring system and time-series database.
- **Port**: 9090
- **Config**: `prometheus/prometheus.yml`
- **Location**: [prometheus/](prometheus/)

#### 5. Uptime Kuma
Self-hosted monitoring tool (like Uptime Robot).
- **Port**: `${KUMA_PORT:-3001}` (configurable via `.env`)
- **URL**: `https://kuma.jeerasakananta.dev` (direct, not via Traefik path)
- **Network**: `homelab` bridge
- **Location**: [kuma/](kuma/)

#### 6. Dozzle
Real-time log viewer for Docker containers.
- **Port**: `0.0.0.0:${DOZZLE_PORT:-8080}` (bound to all interfaces, reachable over Tailscale)
- **Auth**: Simple auth provider (`DOZZLE_AUTH_PROVIDER=simple`) — create users via web UI on first launch
- **Version**: Pinned to `amir20/dozzle:v11.0.1` (never `:latest`)
- **Resources**: CPU 0.5/0.1 limit/reservation, Memory 256M/64M
- **Location**: [dozzle/](dozzle/)

#### 7. Homepage
Modern, self-hosted dashboard/start page for all services.
- **Port**: 3030 (maps to container 3000)
- **Network**: `homelab` bridge
- **Integrations**: Proxmox, Grafana via env vars
- **Location**: [homepage/](homepage/)

#### 8. Beszel
Lightweight server resource monitoring hub with per-host agent (alternative to Netdata).
- **Port**: `0.0.0.0:${BESZEL_PORT:-8090}` (Hub UI)
- **Agent**: Runs in `host` network mode for real network stats
- **Setup**: Copy `beszel/.env.example` to `beszel/.env` and fill `BESZEL_TOKEN`/`BESZEL_KEY` from Hub's "Add System" dialog
- **Location**: [beszel/](beszel/)

#### 9. Loki + Promtail
Centralized log aggregation stack. Loki stores and queries logs; Promtail ships logs from containers, systemd journal, and host files.
- **Ports**: Loki `3100` (HTTP/gRPC), Promtail `9080` (metrics)
- **Network**: `loki_net` bridge
- **Retention**: 7 days (168h), boltdb-shipper filesystem storage
- **Scrape targets**: Docker containers (JSON logs), systemd journal, `/var/log/*`
- **Query**: LogQL via Grafana (add Loki datasource at `http://loki:3100`)
- **Location**: [loki/](loki/)

#### 10. Alertmanager
Alert routing, deduplication, and notification for Prometheus/Grafana alerts.
- **Port**: `9093`
- **Network**: `alertmanager_net` bridge
- **Receivers**: Telegram (primary), Webhook (critical alerts)
- **Templates**: `alertmanager/templates/telegram.tmpl`
- **Config**: `alertmanager/config/alertmanager.yml` (copy `.env.example` for tokens)
- **Location**: [alertmanager/](alertmanager/)

#### 11. Jaeger
Distributed tracing (all-in-one) for request flow visualization across services.
- **Ports**: `16686` (UI), `4317/4318` (OTLP gRPC/HTTP), `14268` (Collector HTTP), `6831/6832` (Agent UDP)
- **Network**: `jaeger_net` bridge
- **Storage**: Badger (embedded, file-based)
- **Instrumentation**: Add OpenTelemetry SDK to services, export to `http://jaeger:4318/v1/traces`
- **Location**: [jaeger/](jaeger/)

### Platform & CI/CD

#### 9. Coolify
Open-source, self-hostable Heroku/Netlify/Vercel alternative.
- **URL**: `https://api-homelab.jeerasakananta.dev/coolify` (via Traefik with stripprefix middleware)
- **Network**: External `homelab_net`
- **Location**: [coolify/](coolify/)

#### 10. Dockge
Fancy, easy-to-use Docker Compose stack manager.
- **Port**: 5001
- **Location**: [dockge/](dockge/)

#### 11. Jenkins
Automation server for CI/CD pipelines.
- **Ports**: 8888 (UI), 50000 (agent connections)
- **Network**: `jenkins_network` bridge
- **Mode**: Privileged, runs as root with Docker socket access
- **Location**: [jenkins/](jenkins/)

#### 12. SonarQube
Static code analysis platform for code quality and security scanning.
- **Port**: `0.0.0.0:${SONAR_PORT:-9000}` (bound to all interfaces, reachable over Tailscale)
- **Network**: `sonarnet` bridge (internal), with dedicated Postgres (`sonarqube-db`)
- **Resources**: 4G mem_limit for SonarQube, 1G for DB
- **Location**: [sonarqube/](sonarqube/)

#### 13. Nginx Proxy Manager
Web UI for managing Nginx proxy hosts, SSL certificates, and access lists.
- **Ports**: 80, 81 (admin UI), 443
- **Network**: External `homelab_net`
- **Data**: `./data` and `./letsencrypt` bind mounts
- **Location**: [nginx-proxy-manager/](nginx-proxy-manager/)

### Automation & AI

#### 14. n8n
Workflow automation tool.
- **Port**: 5678
- **Config**: `n8n/.env` (copy from `.env.example`)
- **Domain**: `https://n8n.jeerasakananta.dev`
- **Location**: [n8n/](n8n/)

#### 15. Ollama
Local LLM runtime.
- **Port**: Internal only (exposes 11434 on `llm_net` bridge, no host port binding)
- **Config**: `OLLAMA_KEEP_ALIVE=24h`, `OLLAMA_NUM_PARALLEL=4`, `OLLAMA_MAX_LOADED_MODELS=2`
- **GPU**: Optional NVIDIA GPU support via deploy reservations
- **Location**: [ollama/](ollama/)

#### 16. Open WebUI
Web UI for interacting with local LLMs (via Ollama).
- **Port**: 8080
- **Version**: `ghcr.io/open-webui/open-webui:v0.11.3`
- **Location**: [openwebui/](openwebui/)

#### 17. EMQX
MQTT broker for IoT and messaging.
- **Ports**: 1883 (MQTT), 8883 (MQTT SSL), 8083 (MQTT WS), 8084 (MQTT WSS), 18083 (Dashboard UI)
- **Location**: [emqx/](emqx/)

#### 18. Home Assistant
Home automation platform.
- **Network**: Host network mode
- **Location**: [homeassistant/](homeassistant/)

#### 19. Airflow
Apache Airflow (LocalExecutor) — webserver + scheduler + Postgres metadata DB.
- **Port**: `${AIRFLOW_WEB_PORT:-8088}` (8080 already used in this lab)
- **First run**: `cp .env.example .env` → `mkdir -p dags logs plugins config` → `chown -R 50000:0 dirs` → `docker compose up airflow-init` → `docker compose up -d`
- **Location**: [airflow/](airflow/)

#### 20. JupyterLab
JupyterLab data science notebook server.
- **Port**: 8888
- **Image**: `jupyter/scipy-notebook:latest`
- **Auth**: Token from `${JUPYTER_TOKEN:-changeme}`
- **Resources**: 4 CPU, 8G memory limit
- **GPU**: Optional NVIDIA support (commented)
- **Location**: [jupyterlab/](jupyterlab/)

#### 21. Log Generator
Fake log container for testing log pipelines (Dozzle, Loki, etc.).
- **Ports**: None (outputs to Docker json-file logging driver)
- **Features**: Random log levels (INFO/WARN/ERROR/DEBUG) and messages every 1-3 seconds
- **Logging**: Limited to 5MB × 2 files
- **Location**: [log-generator/](log-generator/)

### Data Engineering & Orchestration

#### 22. Dagster
Data orchestrator (asset-based pipelines): webserver + daemon + gRPC code location, with Postgres for run/event/schedule storage.
- **Port**: `${DAGSTER_WEB_PORT:-3070}` (3000 taken by Excalidraw)
- **Network**: `dagster_net` bridge
- **Config**: `dagster/dagster.yaml` (instance), `dagster/workspace.yaml` (code location), `dagster/code/` (bind-mounted user code)
- **First run**: `cp .env.example .env` → `docker compose build` → `docker compose up -d`
- **Location**: [dagster/](dagster/)

#### 23. Prefect
Workflow orchestrator (Python-native flows): Prefect 3 server (UI + API) with Postgres backing, plus a container that serves example flows via `.serve()`.
- **Port**: `${PREFECT_WEB_PORT:-4200}`
- **Network**: `prefect_net` bridge
- **Config**: `prefect/flows/` (bind-mounted flow code)
- **First run**: `cp .env.example .env` → `docker compose up -d`
- **Location**: [prefect/](prefect/)

#### 24. Kafka
Single-broker Kafka (KRaft mode — no Zookeeper) plus Redpanda Console as web UI.
- **Ports**: 9092 (broker/bootstrap), 8085 (Redpanda Console)
- **Network**: `kafka_net` bridge
- **Config**: `.env` — `KAFKA_ADVERTISED_HOST` (set to host LAN IP for off-host clients), `KAFKA_CONSOLE_PORT`, `KAFKA_CLUSTER_ID`
- **First run**: `cp .env.example .env` → `docker compose up -d`
- **Location**: [kafka/](kafka/)

### Storage & Data

#### 25. SeaweedFS
Distributed object/file storage system with S3-compatible API.
- **Master**: `${MASTER_PORT}` (default 9333) — cluster status & topology
- **Volume**: `${VOLUME_PORT}` (default 8080) — internal, rarely accessed directly
- **Filer**: `${FILER_PORT}` (default 8888) — web file browser
- **S3 API**: `${S3_PORT}` (default 8333) — S3-compatible clients (aws-cli, rclone, SDKs)
- **Network**: `seaweed_net` bridge
- **Config**: `seaweedfs/.env` (copy from `.env.example`) and `seaweedfs/s3.json` (copy from `s3.json.example`) — `s3.json` is gitignored
- **Location**: [seaweedfs/](seaweedfs/) (see [seaweedfs/README.md](seaweedfs/README.md) for usage examples)

#### 26. Postgres (Shared)
Shared PostgreSQL database instance for misc services.
- **Port**: `${DB_PORT}` (configured via `.env`)
- **Network**: External `homelab_net`
- **Init**: Mounts `init-db.sh` into `/docker-entrypoint-initdb.d` (runs only on first volume init)
- **Location**: [postgres/](postgres/)

#### 27. ClickHouse
Column-oriented OLAP database.
- **Ports**: 8123 (HTTP), 9000 (Native TCP), 9004 (MySQL protocol), 9005 (PostgreSQL protocol)
- **Defaults**: User `admin`, password `admin`, database `default`
- **Ulimits**: nofile 262144
- **Location**: [clickhouse/](clickhouse/)

#### 28. MongoDB
Document database with Mongo Express web UI.
- **Ports**: 27017 (MongoDB), 8081 (Mongo Express)
- **Auth**: Enabled via `MONGO_INITDB_ROOT_USERNAME/PASSWORD`
- **UI Auth**: Separate `MONGO_EXPRESS_USER/PASSWORD`
- **Init Scripts**: `./init-scripts/` mounted to `/docker-entrypoint-initdb.d`
- **Location**: [mongodb/](mongodb/)

#### 29. Syncthing
Continuous peer-to-peer file synchronization between devices.
- **Ports**: `${GUI_BIND:-0.0.0.0}:${GUI_PORT:-8384}` (Web UI, bound to all interfaces), `${SYNC_PORT:-22000}` (TCP+UDP sync), `${DISCOVERY_PORT:-21027}` (UDP local discovery)
- **User**: Runs as UID:GID 1000:1000 — host `./config` and `./data` must be owned by 1000 before first start
- **Resources**: CPU 1.0/0.1 limit/reservation, Memory 512M/128M
- **Healthcheck**: `curl -fkLsS -m 5 http://127.0.0.1:8384/rest/noauth/health`
- **Location**: [syncthing/](syncthing/)

### Developer Tools

#### 30. code-server (VS Code Server)
Browser-based VS Code development environment.
- **Port**: 8443
- **Config**: Environment variables (`PUID`, `PGID`, `TZ`, `CODE_SERVER_PASSWORD`)
- **Volumes**: `./config` → `/config`, `./project-files` → `/config/workspace`
- **Resources**: 4G memory limit
- **Location**: [vscodeserver/](vscodeserver/)

#### 31. Excalidraw
Self-hosted virtual whiteboard for sketching diagrams.
- **Port**: 3000 (maps to container 80)
- **Image**: `excalidraw/excalidraw:latest`
- **Location**: [excalidraw/](excalidraw/)

### Security

#### 32. Vaultwarden
Lightweight, self-hosted Bitwarden-compatible password manager server.
- **Ports**: `${APP_PORT}` (web), `${WEBSOCKET_PORT}` (live sync)
- **Config**: `DOMAIN`, `SIGNUPS_ALLOWED`, `ADMIN_TOKEN` via env vars
- **Data**: `./vw-data` bind mount
- **Location**: [vaultwarden/](vaultwarden/)

#### 33. HashiCorp Vault
Secrets management with dynamic secrets, encryption as a service, and lease/renewal.
- **Port**: `8200`
- **Network**: `vault_net` bridge
- **Mode**: Dev (in-memory, auto-unsealed) — for production use raft + auto-unseal
- **UI**: Enabled at `http://<host>:8200`
- **Init script**: `vault/init/vault-init.sh` (enables KV v2, database secrets engine, policies)
- **Root token**: `${VAULT_ROOT_TOKEN:-root}` (change for production!)
- **Location**: [vault/](vault/)

#### 34. Restic
Automated backup to S3-compatible storage (SeaweedFS, MinIO, AWS S3).
- **Schedule**: Daily backup 2 AM, weekly prune Sunday 4 AM, weekly check Sunday 6 AM
- **Backend**: S3-compatible (configured via `S3_ENDPOINT`, `S3_BUCKET`)
- **Retention**: 7 daily, 4 weekly, 6 monthly, 1 yearly snapshots
- **Paths backed up**: `/home/game`, `/home/game/2_Areas/1_homelab`, `/etc`, `/var/lib/docker/volumes`
- **Excludes**: `restic/config/restic-exclude.txt` (caches, build artifacts, media, VMs)
- **Encryption**: AES-256 via `RESTIC_PASSWORD` (KEEP SAFE!)
- **Cron runner**: `restic-cron` container with dcron
- **Location**: [restic/](restic/)

### Networking & Reverse Proxy

#### 33. Traefik
Modern HTTP reverse proxy and load balancer for Docker containers.
- **Ports**: 80, 443, 8080 (API/dashboard)
- **Network**: `proxy` bridge
- **Config**: `traefik/traefik.yml` (static), `traefik/config/dynamic.yml` (middlewares & TLS)
- **Certs**: `traefik/acme.json` (Let's Encrypt) — gitignored, create with `chmod 600`
- **Location**: [traefik/](traefik/)

#### 34. Nginx
Reverse proxy / web server terminating TLS on ports 80/443.
- **Ports**: 80, 443
- **Config**: `nginx/conf.d/` (server blocks), `nginx/certs/` (TLS certs), `nginx/logs/`
- **Network**: External `homelab_net`
- **Location**: [nginx/](nginx/)

#### 35. Harbor
Container registry (Harbor).
- **Config**: `docker-compose.yaml` present (needs configuration)
- **Location**: [harbor/](harbor/)

## 🔌 Ports Overview

| Service | Port (Host) | Container Port | Network | Notes |
|---------|-------------|----------------|---------|-------|
| Traefik | 80, 443, 8080 | 80, 443, 8080 | proxy | Reverse proxy entrypoint |
| Nginx | 80, 443 | 80, 443 | homelab_net (ext) | Alternative TLS termination |
| Nginx Proxy Mgr | 80, 81, 443 | 80, 81, 443 | homelab_net (ext) | Admin UI on 81 |
| Glance | 8080 | 8080 | homelab | `${GLANCE_PORT:-8080}` |
| Grafana | 3080 | 3000 | — | |
| Netdata | 19999 | 19999 | host | Host network mode |
| Prometheus | 9090 | 9090 | — | |
| Uptime Kuma | 3001 | 3001 | homelab | `${KUMA_PORT:-3001}`, direct domain |
| Dozzle | 8080 | 8080 | — | `0.0.0.0`, simple auth |
| Homepage | 3030 | 3000 | homelab | |
| Beszel Hub | 8090 | 8090 | — | `0.0.0.0`, agent on host net |
| Coolify | — | — | homelab_net (ext) | Via Traefik `/coolify` |
| Dockge | 5001 | 5001 | — | |
| Jenkins | 8888, 50000 | 8080, 50000 | jenkins_network | Privileged |
| SonarQube | 9000 | 9000 | sonarnet | `0.0.0.0`, dedicated PG |
| n8n | 5678 | 5678 | — | Domain: n8n.jeerasakananta.dev |
| Dagster | 3070 | 3000 | dagster_net | `${DAGSTER_WEB_PORT:-3070}` |
| Prefect | 4200 | 4200 | prefect_net | `${PREFECT_WEB_PORT:-4200}` |
| Kafka Broker | 9092 | 9092 | kafka_net | KRaft mode |
| Redpanda Console | 8085 | 8080 | kafka_net | `${KAFKA_CONSOLE_PORT:-8085}` |
| Ollama | — | 11434 | llm_net | Internal only (expose) |
| Open WebUI | 8080 | 8080 | — | |
| EMQX | 1883, 8883, 8083, 8084, 18083 | same | — | MQTT + Dashboard |
| Home Assistant | host | — | host | Host network mode |
| SeaweedFS Master | 9333 | 9333 | seaweed_net | `${MASTER_PORT}` |
| SeaweedFS Volume | 8080 | 8080 | seaweed_net | `${VOLUME_PORT}` |
| SeaweedFS Filer | 8888 | 8888 | seaweed_net | `${FILER_PORT}` |
| SeaweedFS S3 | 8333 | 8333 | seaweed_net | `${S3_PORT}` |
| Postgres | `${DB_PORT}` | 5432 | homelab_net (ext) | Via `.env` |
| ClickHouse | 8123, 9000, 9004, 9005 | same | — | HTTP, Native, MySQL, PG |
| MongoDB | 27017 | 27017 | — | Auth enabled |
| Mongo Express | 8081 | 8081 | — | Separate auth |
| Airflow | 8088 | 8080 | — | `${AIRFLOW_WEB_PORT:-8088}` |
| JupyterLab | 8888 | 8888 | — | Token auth |
| Syncthing | 8384, 22000, 21027 | 8384, 22000, 21027 | — | `0.0.0.0` GUI bind |
| code-server | 8443 | 8443 | — | |
| Excalidraw | 3000 | 80 | — | |
| Vaultwarden | `${APP_PORT}`, `${WEBSOCKET_PORT}` | 80, 3012 | — | Via `.env` |
| Harbor | TBD | TBD | — | Needs config |
| Loki | 3100 | 3100 | loki_net | HTTP/gRPC API |
| Promtail | 9080 | 9080 | loki_net | Metrics endpoint |
| Alertmanager | 9093 | 9093 | alertmanager_net | Alert routing UI |
| Jaeger | 16686, 4317, 4318, 14268, 6831/6832 | same | jaeger_net | UI, OTLP, Collector, Agent |
| Vault | 8200 | 8200 | vault_net | Dev mode, UI enabled |
| Restic | — | — | restic_net | Cron-based, no HTTP ports |

> **⚠️ Port Conflicts:** Multiple services default to 8080 (Glance, Dozzle, Open WebUI, SeaweedFS Volume, JupyterLab, Jenkins internal). Check each `docker-compose.yaml` before running simultaneously on the same host network. Use `.env` overrides where provided.

## 🔧 Requirements

- Docker Engine
- Docker Compose (v2, `docker compose` plugin)
- cloudflared Tunnel (for public HTTPS via Traefik/Coolify)
- Tailscale (for private tailnet access to 0.0.0.0-bound services)
- `iptables-persistent` / `netfilter-persistent` (for DB port blocking via DOCKER-USER chain)

## 🚀 Setup

### 1. Clone the repository
```bash
git clone https://github.com/JeerasakAnanta/homelab.git
cd homelab
```

### 2. Core Infrastructure (start first)
```bash
# External networks (create once)
docker network create homelab_net
docker network create proxy

# Traefik (certs: touch acme.json && chmod 600 acme.json)
cd traefik && docker compose up -d

# Nginx (alternative entrypoint)
cd ../nginx && docker compose up -d

# Shared Postgres (for services using homelab_net)
cd ../postgres && cp .env.example .env  # edit first
docker compose up -d
```

### 3. Monitoring Stack
```bash
# Glance
cd ../glance && cp .env.example .env  # edit GLANCE_PORT if needed
docker compose up -d

# Grafana
cd ../grafana && cp .env.example .env  # edit GF_* vars
docker compose up -d

# Prometheus
cd ../prometheus && docker compose up -d

# Netdata
cd ../netdata && docker compose up -d

# Uptime Kuma
cd ../kuma && cp .env.example .env  # edit KUMA_PORT if needed
docker compose up -d

# Dozzle
cd ../dozzle && cp .env.example .env  # edit DOZZLE_PORT if needed
docker compose up -d

# Homepage
cd ../homepage && cp .env.example .env  # edit Proxmox/Grafana creds
docker compose up -d

# Beszel
cd ../beszel && cp .env.example .env  # fill BESZEL_TOKEN/KEY from Hub UI
docker compose up -d

# Loki + Promtail
cd ../loki && docker compose up -d

# Alertmanager
cd ../alertmanager && cp .env.example .env  # fill TELEGRAM_BOT_TOKEN, CHAT_ID
docker compose up -d

# Jaeger
cd ../jaeger && docker compose up -d
```

### 4. Platform & CI/CD
```bash
# Coolify (needs Traefik + homelab_net)
cd ../coolify && docker compose up -d

# Dockge
cd ../dockge && docker compose up -d

# Jenkins
cd ../jenkins && docker compose up -d

# SonarQube
cd ../sonarqube && cp .env.example .env  # edit SONAR_* vars
docker compose up -d

# Nginx Proxy Manager
cd ../nginx-proxy-manager && docker compose up -d
```

### 5. Automation & AI
```bash
# n8n
cd ../n8n && cp .env.example .env
docker compose up -d

# Ollama (internal only, for Open WebUI)
cd ../ollama && docker compose up -d

# Open WebUI
cd ../openwebui && docker compose up -d

# EMQX
cd ../emqx && docker compose up -d

# Home Assistant
cd ../homeassistant && docker compose up -d

# Airflow
cd ../airflow && cp .env.example .env  # set FERNET key, admin password
mkdir -p dags logs plugins config
docker run --rm -v "$PWD:/mnt" alpine chown -R 50000:0 /mnt/dags /mnt/logs /mnt/plugins /mnt/config
docker compose up airflow-init
docker compose up -d

# JupyterLab
cd ../jupyterlab && cp .env.example .env  # set JUPYTER_TOKEN
docker compose up -d
```

### 6. Data Engineering
```bash
# Dagster
cd ../dagster && cp .env.example .env
docker compose build
docker compose up -d

# Prefect
cd ../prefect && cp .env.example .env
docker compose up -d

# Kafka
cd ../kafka && cp .env.example .env  # set KAFKA_ADVERTISED_HOST for LAN access
docker compose up -d
```

### 7. Storage & Databases
```bash
# SeaweedFS
cd ../seaweedfs && cp .env.example .env && cp s3.json.example s3.json  # edit both
docker compose up -d

# ClickHouse
cd ../clickhouse && docker compose up -d

# MongoDB
cd ../mongodb && cp .env.example .env  # set MONGO_* vars
docker compose up -d

# Syncthing
cd ../syncthing
mkdir -p config data
sudo chown -R 1000:1000 config data  # required for UID 1000 container
docker compose up -d
```

### 8. Developer Tools & Security
```bash
# code-server
cd ../vscodeserver && cp .env.example .env  # set PUID, PGID, TZ, CODE_SERVER_PASSWORD
docker compose up -d

# Excalidraw
cd ../excalidraw && docker compose up -d

# Vaultwarden
cd ../vaultwarden && cp .env.example .env  # set DOMAIN, APP_PORT, WEBSOCKET_PORT, ADMIN_TOKEN, SIGNUPS_ALLOWED
docker compose up -d

# HashiCorp Vault
cd ../vault && cp .env.example .env  # set VAULT_ROOT_TOKEN
docker compose up -d
docker compose exec vault /vault/init/vault-init.sh

# Restic (backup)
cd ../restic && cp .env.example .env  # set S3_ENDPOINT, S3_BUCKET, AWS creds, RESTIC_PASSWORD
docker compose up -d
```

## ⚙️ Configuration

Each service has its own configuration directory:

| Service | Config Location | Notes |
|---------|----------------|-------|
| Glance | `glance/config/`, `glance/assets/` | Dashboard YAML files |
| Grafana | `grafana/docker-compose.yaml` env vars | Admin creds, domain, root URL |
| Netdata | `netdata/netdataconfig/` | Netdata config files |
| Prometheus | `prometheus/prometheus.yml` | Scrape targets, rules |
| Beszel | `beszel/.env` | Copy from `.env.example`, fill token/key |
| SeaweedFS | `seaweedfs/.env`, `seaweedfs/s3.json` | Copy from examples, `s3.json` gitignored |
| Traefik | `traefik/traefik.yml`, `traefik/config/dynamic.yml`, `traefik/acme.json` | Static/dynamic config, certs (chmod 600) |
| Nginx | `nginx/conf.d/`, `nginx/certs/`, `nginx/logs/` | Server blocks, TLS certs, logs |
| Postgres | `postgres/.env` | DB name, user, password, port |
| n8n | `n8n/.env` | Copy from `.env.example` |
| SonarQube | `sonarqube/.env` | Copy from `.env.example` |
| Vaultwarden | `vaultwarden/.env` (or inline env) | DOMAIN, ports, ADMIN_TOKEN, SIGNUPS_ALLOWED |
| code-server | `vscodeserver/.env` | PUID, PGID, TZ, CODE_SERVER_PASSWORD |
| Airflow | `airflow/.env` | FERNET key, admin password, extra pip reqs |
| JupyterLab | `jupyterlab/.env` | JUPYTER_TOKEN |
| Homepage | `homepage/.env` | Proxmox, Grafana credentials |
| Prefect | `prefect/.env` | Postgres creds, web port |
| Dagster | `dagster/.env` | Postgres creds, web port |
| Kafka | `kafka/.env` | ADVERTISED_HOST, console port, cluster ID |
| MongoDB | `mongodb/.env` | Root user/pass, express user/pass, init DB |
| Uptime Kuma | `kuma/.env` | KUMA_VERSION, KUMA_PORT |
| Dozzle | `dozzle/.env` | DOZZLE_PORT |
| Syncthing | `syncthing/.env` | GUI_BIND, GUI_PORT, SYNC_PORT, DISCOVERY_PORT, TZ |
| ClickHouse | Inline in compose | Default admin/admin, change for production |
| Loki | `loki/config/` | `loki-local-config.yaml`, `promtail-config.yaml` |
| Alertmanager | `alertmanager/config/`, `alertmanager/templates/` | `alertmanager.yml`, telegram template |
| Jaeger | Inline in compose | Badger storage, OTLP enabled |
| Vault | `vault/config/vault.hcl`, `vault/init/vault-init.sh` | Dev mode config, init script |
| Restic | `restic/config/restic-exclude.txt`, `restic/scripts/` | Exclude patterns, backup/prune/check scripts |

## 📝 Notes

- **Pin image versions explicitly** — never use `:latest` (see `dozzle/docker-compose.yaml` comments for rationale)
- **Exceptions (known `:latest` usage)**: `jupyterlab` (`jupyter/scipy-notebook:latest`), `vscodeserver` (`lscr.io/linuxserver/code-server:latest`), `harbor` (actually Homarr `ghcr.io/homarr-labs/homarr:latest`), `excalidraw` (`excalidraw/excalidraw:latest`) — these upstream images don't publish stable version tags; pin when possible
- **Adding a service**: Update `README.md` (catalog, mermaid diagram, ports table) AND `.gitignore` (data dirs / secrets) together — history shows both move with a new stack
- **Secrets and persistent data are gitignored**: `.env`, `*.pem`, `*.key`, `traefik/acme.json`, `vaultwarden/vw-data`, `homeassistant/config`, `sonarqube/data/`, `seaweedfs/s3.json`, etc. Never commit them
- **Commit messages** follow Conventional Commits (`feat:`, `fix:`, `build(scope):`)
- **DB ports (27017, 5432) are blocked from the internet** via the `DOCKER-USER` iptables chain (localhost, tailscale0, inter-container allowed; persisted with `iptables-persistent`). `docker-proxy` bypasses UFW, so removing `ports:` alone does not hide a DB — re-save rules after changes (`netfilter-persistent save`)
- **Postgres init scripts** (`init-db.sh` mounted to `/docker-entrypoint-initdb.d`) only run on **first volume initialization**, not on restart
- **Missing `_data` under `/var/lib/docker/volumes/` means data is gone** — recreating it starts a fresh empty DB. Warn before doing it
- **`(unhealthy)` after long uptime** is often the `runc` exec bug (`fork/exec /proc/self/fd/6`), not app failure — host reboot clears it
- **If a file bind-mount source is missing**, Docker auto-creates a **directory** (seen with `postgres-lab-db/init-db.sh`) — replace with a file
- **Stale/Undocumented directories**: `log-generator/` (fake-log container for log testing), `harbor/` (has compose but needs config), `data/` (empty), `ansible/`, `docs/`, `.agents/`, `.claude/`, `.hermes/` — not all documented in this README

## 🔗 Quick Links (when running)

| Service | URL |
|---------|-----|
| Traefik Dashboard | `http://traefik.localhost:8080` (or via domain) |
| Glance | `http://<host>:8080` |
| Grafana | `http://<host>:3080` |
| Netdata | `http://<host>:19999` |
| Prometheus | `http://<host>:9090` |
| Uptime Kuma | `https://kuma.jeerasakananta.dev` |
| Dozzle | `https://dozzle.jeerasakananta.dev` (or `http://<host>:8080`) |
| Homepage | `http://<host>:3030` |
| Beszel | `https://beszel.jeerasakananta.dev` |
| Coolify | `https://api-homelab.jeerasakananta.dev/coolify` |
| Dockge | `http://<host>:5001` |
| Jenkins | `http://<host>:8888` |
| SonarQube | `http://<host>:9000` |
| n8n | `https://n8n.jeerasakananta.dev` |
| Open WebUI | `http://<host>:8080` |
| EMQX Dashboard | `http://<host>:18083` |
| SeaweedFS Filer | `http://<host>:8888` |
| Mongo Express | `http://<host>:8081` |
| Airflow | `http://<host>:8088` |
| JupyterLab | `http://<host>:8888` |
| Nginx Proxy Manager | `http://<host>:81` |
| code-server | `https://<host>:8443` |
| Excalidraw | `http://<host>:3000` |
| Vaultwarden | `https://<DOMAIN>` |
| Dagster | `http://<host>:3070` |
| Prefect | `http://<host>:4200` |
| Redpanda Console | `http://<host>:8085` |
| Loki | `http://<host>:3100` |
| Alertmanager | `http://<host>:9093` |
| Jaeger | `http://<host>:16686` |
| Vault | `http://<host>:8200` |