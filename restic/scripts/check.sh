#!/bin/sh
# Check script - verify repository integrity

set -eu

echo "=== Starting repository check at $(date) ==="

# Full check (reads all data) - run weekly
restic check --read-data --verbose

echo "=== Check completed at $(date) ==="