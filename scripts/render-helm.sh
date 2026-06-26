#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALUES_ROOT="${VALUES_ROOT:-environments}"
OUT_DIR="$PROJECT_ROOT/tmp/rendered"
mkdir -p "$OUT_DIR"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required for render validation." >&2
  exit 1
fi

for env in dev staging prod; do
  release="cloudops-demo-$env"
  namespace="cloudops-$env"
  values="$PROJECT_ROOT/$VALUES_ROOT/$env/values.yaml"
  output="$OUT_DIR/$env.yaml"

  echo "Rendering $release into $output"
  helm template "$release" "$PROJECT_ROOT/charts/cloudops-demo-app" \
    --namespace "$namespace" \
    -f "$values" > "$output"
done

echo "Rendered manifests in $OUT_DIR"
