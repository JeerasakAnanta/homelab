#!/bin/sh
# Backup script for Restic
# Usage: /scripts/backup.sh

set -eu

echo "=== Starting backup at $(date) ==="

# Define backup paths (must match docker-compose volumes)
BACKUP_PATHS="/data/home-game /data/homelab /data/etc /data/docker-volumes"

# Run backup
restic backup $BACKUP_PATHS \
  --tag "auto-$(date +%Y%m%d-%H%M%S)" \
  --tag "hostname-$(hostname)" \
  --exclude-caches \
  --exclude-file /config/restic-exclude.txt \
  --compression auto \
  --verbose

echo "=== Backup completed at $(date) ==="

# Print stats
restic stats --mode raw-data