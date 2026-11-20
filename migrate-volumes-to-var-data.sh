#!/usr/bin/env bash
# One-off: copy data from old Docker named volumes into /var/data/<service>.
# Stop the stack first (docker compose down). Safe to re-run: skips non-empty targets.
# Usage: sudo ./migrate-volumes-to-var-data.sh [--dry-run]
set -euo pipefail
DRY=${1:-}

# <old volume name (suffix match)> <target dir>
MAP='
postgres-db-volume airflow/postgres
alertmanager_data alertmanager
beszel_data beszel
ch_data clickhouse/data
ch_logs clickhouse/logs
dagster-postgres-data dagster
dozzle_data dozzle
emqx_data emqx/data
emqx_log emqx/log
emqx_etc emqx/etc
grafana_data grafana
jaeger_data jaeger
jenkins_home jenkins
jupyter-config jupyterlab/config
kafka-data kafka
loki_data loki
mongo-data mongodb/data
mongo-config mongodb/config
n8n_data n8n
netdatalib netdata/lib
netdatacache netdata/cache
ollama_models ollama
open-webui openwebui
postgres_data postgres
pgadmin_data pgadmin
prefect-postgres-data prefect
restic_cache restic
master_data seaweedfs/master
volume_data seaweedfs/volume
filer_data seaweedfs/filer
vault_data vault/data
vault_logs vault/logs
'
# NB: airflow's "postgres-db-volume" and postgres/ stack's "postgres_data" are different volumes.

while read -r vol target; do
  [ -z "$vol" ] && continue
  src=$(docker volume ls -q | grep -E "(^|_)${vol}$" || true)
  n=$(echo "$src" | grep -c . || true)
  if [ "$n" -ne 1 ]; then echo "SKIP $vol: $n matching volumes ($src)"; continue; fi
  dst=/var/data/$target
  if [ -d "$dst" ] && [ -n "$(ls -A "$dst")" ]; then echo "SKIP $vol: $dst not empty"; continue; fi
  echo "COPY $src -> $dst"
  [ "$DRY" = --dry-run ] && continue
  mkdir -p "$dst"
  docker run --rm -v "$src":/from:ro -v "$dst":/to alpine cp -a /from/. /to/
done <<< "$MAP"
