#!/usr/bin/env bash
set -euo pipefail

PRIMARY=$(kubectl get pods -l role=cnpg-primary -o jsonpath='{.items[0].metadata.name}')
echo "[failover] Force-deleting primary pod $PRIMARY"
T0=$(date +%s)
kubectl delete pod "$PRIMARY" --grace-period=0 --force

echo -n "[failover] Awaiting new primary "
until kubectl get pods -l role=cnpg-primary -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running; do
  echo -n "."
  sleep 5
done
T2=$(date +%s)
echo
echo "[failover] Recovery finished in $((T2 - T0)) s"
