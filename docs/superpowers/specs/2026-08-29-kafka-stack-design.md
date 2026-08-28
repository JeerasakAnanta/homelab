# Kafka stack — design

**Date:** 2026-08-29
**Status:** Approved
**Use case:** Learning / experimenting with Kafka — a single broker plus a web UI for inspecting topics and messages.

## Overview

Add a new standalone Docker Compose stack under `kafka/`, following the repo convention
(one service directory, pinned image versions, its own bridge network, README + `.gitignore`
updated in the same change).

## Services

| service | image | role |
|---|---|---|
| `kafka` | `apache/kafka:3.9.1` | single broker, KRaft mode (no Zookeeper) |
| `redpanda-console` | `redpandadata/console:v2.8.4` | web UI for topics / messages / consumer groups |

Both images pinned explicitly (no `:latest`), per repo convention.

## Networking / listeners

- Network: `kafka_net` (bridge), defined in this stack only — matches the per-stack
  own-network pattern documented in `CLAUDE.md`.
- Broker listeners:
  - `CONTROLLER` → `0.0.0.0:9093` — internal KRaft quorum, not published.
  - `INTERNAL` → advertised as `kafka:29092` — `redpanda-console` connects here over `kafka_net`.
  - `EXTERNAL` → advertised as `${KAFKA_ADVERTISED_HOST:-localhost}:9092`, container listens on `0.0.0.0:9092`, published `9092:9092`.
- Connecting from the Docker host: `localhost:9092`.
- Connecting from another machine on the LAN: set `KAFKA_ADVERTISED_HOST=<host-ip>` in `.env`.

## Ports (host)

| purpose | port |
|---|---|
| Kafka broker (EXTERNAL listener) | `9092` |
| redpanda-console UI | `8085` |

No conflict with existing services in the README ports table (9092 and 8085 are unused;
8080 is deliberately avoided).

## Config / persistence

- `.env.example` committed; `.env` gitignored. Keys:
  - `KAFKA_ADVERTISED_HOST` (default `localhost`)
  - `KAFKA_CONSOLE_PORT` (default `8085`)
  - `KAFKA_CLUSTER_ID` (default provided — a fixed base64 UUID)
- Named volume `kafka-data` for the broker log directory (`/var/lib/kafka/data`),
  same approach as `prefect-postgres-data`. No bind mount, so no new `.gitignore`
  path is required beyond the per-stack `.env` line.
- KRaft single-node env config on the `kafka` service:
  - `KAFKA_NODE_ID=1`
  - `KAFKA_PROCESS_ROLES=broker,controller`
  - `KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka:9093`
  - `KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER`
  - `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT`
  - `KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL`
  - `KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1`
  - `KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1`
  - `KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1`
  - `KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0`
  - `CLUSTER_ID=${KAFKA_CLUSTER_ID}`

## Health checks

- `kafka`: `kafka-topics.sh --bootstrap-server localhost:9092 --list`, with a
  `start_period` generous enough for KRaft format + startup.
- `redpanda-console`: `depends_on: kafka: { condition: service_healthy }`;
  `KAFKA_BROKERS=kafka:29092` in its environment.

## Documentation updates (same commit)

- `README.md`:
  - service list / catalog — add Kafka.
  - mermaid architecture diagram — add `Kafka` and `Redpanda Console` nodes under
    Standalone / Direct Port Access, with the `9092` and `8085` user edges.
  - ports table — add `Kafka` (`9092`) and `Redpanda Console` (`8085`) rows, and a
    note that `9092` advertised host is configured via `.env`.
- `.gitignore`: add `kafka/.env` line, matching the existing per-stack entries
  (`prefect/.env`, `dagster/.env`, …).

## Out of scope (YAGNI)

- Multi-broker cluster / replication.
- Kafka Connect, Schema Registry, ksqlDB.
- TLS / SASL auth.
- Wiring Kafka into other homelab stacks (n8n, EMQX, log-generator).
- Root-level unified compose file.
