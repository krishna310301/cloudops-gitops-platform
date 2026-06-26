#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-cloudops-gitops}"
IMAGE_NAME="${IMAGE_NAME:-cloudops-demo-app}"

docker build -t "$IMAGE_NAME:0.1.0-dev" ./app
docker tag "$IMAGE_NAME:0.1.0-dev" "$IMAGE_NAME:0.1.0-staging"
docker tag "$IMAGE_NAME:0.1.0-dev" "$IMAGE_NAME:0.1.0-prod"

kind load docker-image "$IMAGE_NAME:0.1.0-dev" --name "$CLUSTER_NAME"
kind load docker-image "$IMAGE_NAME:0.1.0-staging" --name "$CLUSTER_NAME"
kind load docker-image "$IMAGE_NAME:0.1.0-prod" --name "$CLUSTER_NAME"

echo "Loaded local images into kind cluster: $CLUSTER_NAME"
