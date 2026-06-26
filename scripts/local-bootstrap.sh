#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_REPO_URL="git://host.docker.internal:9418/$(basename "$PROJECT_ROOT")"
GIT_REPO_URL="${GIT_REPO_URL:-$DEFAULT_REPO_URL}"
APP_ENV="${APP_ENV:-all}"
PROJECT_ONLY="${PROJECT_ONLY:-false}"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Applying namespace boundaries..."
kubectl apply -f "$PROJECT_ROOT/platform/namespaces"
kubectl apply -f "$PROJECT_ROOT/platform/resourcequotas"
kubectl apply -f "$PROJECT_ROOT/platform/rbac"

echo "Rendering Argo CD manifests with repo URL: $GIT_REPO_URL"
for file in "$PROJECT_ROOT"/argocd/projects/*.yaml; do
  rendered="$TMP_DIR/$(basename "$file")"
  sed "s|REPO_URL_PLACEHOLDER|$GIT_REPO_URL|g" "$file" > "$rendered"
  kubectl apply -f "$rendered"
done

if [[ "$PROJECT_ONLY" == "true" ]]; then
  echo "PROJECT_ONLY=true, skipping Application manifests."
  exit 0
fi

case "$APP_ENV" in
  all)
    app_files=("$PROJECT_ROOT"/argocd/applications/*.yaml)
    ;;
  dev|staging|prod)
    app_files=("$PROJECT_ROOT/argocd/applications/$APP_ENV.yaml")
    ;;
  *)
    echo "APP_ENV must be one of: all, dev, staging, prod" >&2
    exit 1
    ;;
esac

for file in "${app_files[@]}"; do
  rendered="$TMP_DIR/$(basename "$file")"
  sed "s|REPO_URL_PLACEHOLDER|$GIT_REPO_URL|g" "$file" > "$rendered"
  kubectl apply -f "$rendered"
done

echo "Bootstrap complete."
echo "Check apps with: kubectl -n argocd get applications"
