#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_REPO_URL="git://host.docker.internal:9418/$(basename "$PROJECT_ROOT")"
GIT_REPO_URL="${GIT_REPO_URL:-$DEFAULT_REPO_URL}"
VALUES_ROOT="${VALUES_ROOT:-environments}"
OUT_DIR="$PROJECT_ROOT/tmp/argocd-rendered"

mkdir -p "$OUT_DIR"

for file in "$PROJECT_ROOT"/argocd/projects/*.yaml "$PROJECT_ROOT"/argocd/applications/*.yaml; do
  rendered="$OUT_DIR/$(basename "$file")"
  sed \
    -e "s|REPO_URL_PLACEHOLDER|$GIT_REPO_URL|g" \
    -e "s|VALUES_ROOT_PLACEHOLDER|$VALUES_ROOT|g" \
    "$file" > "$rendered"
  echo "$rendered"
done

echo
echo "Rendered Argo CD manifests with repo URL: $GIT_REPO_URL"
echo "Rendered Argo CD value files from: $VALUES_ROOT"
echo "Check repo URLs with:"
echo "  rg \"$GIT_REPO_URL\" $OUT_DIR"
