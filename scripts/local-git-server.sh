#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PARENT="$(dirname "$PROJECT_ROOT")"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to run the local git server." >&2
  exit 1
fi

if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
  cat >&2 <<EOF
This directory is not a standalone Git repository:
  $PROJECT_ROOT

Argo CD reads from Git, and git daemon serves Git repositories, not arbitrary
folders. Initialize and commit this project before using the local server:

  cd "$PROJECT_ROOT"
  git init
  git add .
  git commit -m "Initial CloudOps GitOps Platform"

If you push this project to GitHub instead, skip this script and set
GIT_REPO_URL to the GitHub repository URL when running local-bootstrap.sh.
EOF
  exit 1
fi

if ! git -C "$PROJECT_ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
  cat >&2 <<EOF
This Git repository has no commits yet:
  $PROJECT_ROOT

git daemon needs HEAD to resolve the repository. Create an initial commit first:

  cd "$PROJECT_ROOT"
  git add .
  git commit -m "Initial CloudOps GitOps Platform"
EOF
  exit 1
fi

required_paths=(
  "argocd/projects/cloudops-project.yaml"
  "argocd/applications/dev.yaml"
  "charts/cloudops-demo-app/Chart.yaml"
  "charts/cloudops-demo-app/templates/deployment.yaml"
  "environments/dev/values.yaml"
  "environments/local/dev/values.yaml"
)

missing_paths=()
for path in "${required_paths[@]}"; do
  if ! git -C "$PROJECT_ROOT" ls-files --error-unmatch "$path" >/dev/null 2>&1; then
    missing_paths+=("$path")
  fi
done

if (( ${#missing_paths[@]} > 0 )); then
  cat >&2 <<EOF
This Git repository has a commit, but required GitOps files are not tracked.

Missing from Git index:
$(printf '  - %s\n' "${missing_paths[@]}")

Add and commit the missing files before serving the repo:

  cd "$PROJECT_ROOT"
  git add .
  git commit -m "Add GitOps platform manifests"
EOF
  exit 1
fi

echo "Starting local git daemon for $PROJECT_NAME"
echo "Repo URL for kind/Docker Desktop: git://host.docker.internal:9418/$PROJECT_NAME"
echo "Repo URL for host access:        git://127.0.0.1:9418/$PROJECT_NAME"
echo
echo "Keep this process running while Argo CD syncs."

git daemon \
  --verbose \
  --reuseaddr \
  --export-all \
  --base-path="$PROJECT_PARENT" \
  "$PROJECT_ROOT"
