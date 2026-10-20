#!/bin/sh
# Prune script - remove old snapshots per retention policy

set -eu

echo "=== Starting prune at $(date) ==="

# Retention policy:
# Keep last 7 daily, 4 weekly, 6 monthly, 1 yearly
restic forget \
  --keep-last 7 \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --keep-yearly 1 \
  --prune \
  --verbose

echo "=== Prune completed at $(date) ==="