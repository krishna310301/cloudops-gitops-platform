#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
NAMESPACE="cloudops-$ENVIRONMENT"
DEPLOYMENT="cloudops-demo-$ENVIRONMENT"

case "$ENVIRONMENT" in
  dev|staging|prod) ;;
  *)
    echo "Usage: $0 [dev|staging|prod]" >&2
    exit 1
    ;;
esac

echo "Current desired deployment state:"
kubectl -n "$NAMESPACE" get deployment "$DEPLOYMENT"

echo "Creating manual drift by scaling $DEPLOYMENT to 3 replicas..."
kubectl -n "$NAMESPACE" scale deployment "$DEPLOYMENT" --replicas=3
kubectl -n "$NAMESPACE" get deployment "$DEPLOYMENT"

echo
echo "Argo CD should mark the app OutOfSync and self-heal it back to Git state."
echo "Watch with:"
echo "  kubectl -n argocd get application $DEPLOYMENT -w"
echo "  kubectl -n $NAMESPACE get deployment $DEPLOYMENT -w"
