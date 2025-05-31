#!/usr/bin/env bash
set -euo pipefail

CLUSTER=${1:-pg-cluster}
NS=${2:-cloudnativepg}
RESTORE_NS="restore-${CLUSTER}"

echo "[backup] Requesting immediate backup for cluster $CLUSTER"
kubectl cnpg backup create --cluster "$CLUSTER" --namespace "$NS"

echo "[backup] Waiting for backup object to become successful…"
until kubectl get backup -n "$NS" \
  -l "postgresql.cnpg.io/cluster=$CLUSTER" \
  -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q "completed"; do
  sleep 20
done
BACKUP_NAME=$(kubectl get backup -n "$NS" -l "postgresql.cnpg.io/cluster=$CLUSTER" -o jsonpath='{.items[0].metadata.name}')

echo "[restore] Restoring backup $BACKUP_NAME to namespace $RESTORE_NS"
kubectl create ns "$RESTORE_NS" || true
kubectl cnpg backup restore "$BACKUP_NAME" --target latest --namespace "$RESTORE_NS"
