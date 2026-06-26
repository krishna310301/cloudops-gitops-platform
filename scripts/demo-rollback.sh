#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALUES_FILE="$PROJECT_ROOT/environments/$ENVIRONMENT/values.yaml"

case "$ENVIRONMENT" in
  dev|staging|prod) ;;
  *)
    echo "Usage: $0 [dev|staging|prod]" >&2
    exit 1
    ;;
esac

cat <<EOF
Rollback demo for $ENVIRONMENT

1. Create a branch:
   git checkout -b demo/$ENVIRONMENT-bad-readiness

2. Edit:
   $VALUES_FILE

3. Change:
   failureMode:
     enabled: false

   to:
   failureMode:
     enabled: true

4. Commit and let Argo CD sync. The app should become Degraded because /healthz returns 503.

5. Recover through Git:
   git revert HEAD

6. Let Argo CD sync again. The app should return to Healthy and Synced.

Watch:
   kubectl -n argocd get application cloudops-demo-$ENVIRONMENT -w
   kubectl -n cloudops-$ENVIRONMENT get pods -w
EOF
