#!/usr/bin/env bash
set -euo pipefail

SCALE=${1:-50}     # scale factor
CLIENTS=${2:-32}   # number of connections
DURATION=${3:-600} # seconds
DB="postgres"      # target DB inside cluster
POD=$(kubectl get pods -l role=cnpg-primary -o jsonpath='{.items[0].metadata.name}')

echo "[pgbench] Warm-up for 180 s…"
kubectl exec "$POD" -- pgbench -i -s "$SCALE" "$DB"
sleep 180

echo "[pgbench] Running benchmark: ${SCALE}/${CLIENTS}/${DURATION}"
kubectl exec "$POD" -- pgbench -c "$CLIENTS" -T "$DURATION" -P 30 "$DB" | tee /tmp/pgbench-"$(date +%s)".log
