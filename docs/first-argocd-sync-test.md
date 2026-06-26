# First Argo CD Sync Test

This is the first live test to run after Docker and a local Kubernetes runtime are available.

The goal is narrow: prove Argo CD can resolve the multi-source `$values/...` reference and sync the `dev` Application. Do not apply all three Applications until `dev` works.

## Prerequisites

- Docker is running.
- A local cluster exists through `kind`, `minikube`, or Docker Desktop Kubernetes.
- `kubectl` points at the local cluster.
- Argo CD is installed with `./scripts/install-argocd.sh`.
- Argo CD CLI is installed if you want the best error messages.
- This project directory is a standalone Git repo with at least one commit, or it has been pushed to GitHub.

Check the Argo CD version:

```bash
argocd version --client
kubectl -n argocd get deployment argocd-server -o jsonpath='{.spec.template.spec.containers[0].image}'
echo
```

Multi-source Applications require Argo CD 2.6+.

## Step 1: Serve The Repo

If testing through the local git daemon, initialize and commit the project first:

```bash
git init
git add .
git commit -m "Initial CloudOps GitOps Platform scaffold"
```

The project currently needs to be served as its own repository root because the Argo CD Applications use repo-root paths such as `charts/cloudops-demo-app` and `environments/dev/values.yaml`.

For a `kind` demo, build and load the local image before syncing:

```bash
./scripts/build-load-local-images.sh
```

In terminal 1:

```bash
./scripts/local-git-server.sh
```

Expected repo URL for a cluster running in Docker:

```text
git://host.docker.internal:9418/cloudops-gitops-platform
```

If your cluster cannot resolve `host.docker.internal`, push to GitHub and use that GitHub URL instead.

## Step 2: Confirm Placeholder Replacement

Render the manifests that will be applied:

```bash
GIT_REPO_URL=git://host.docker.internal:9418/cloudops-gitops-platform \
  ./scripts/render-argocd.sh
```

Confirm the same URL appears in:

- `AppProject.spec.sourceRepos`
- `Application.spec.sources[0].repoURL`
- `Application.spec.sources[1].repoURL`

If these do not match exactly, Argo CD may reject the Application with a project repo-permission error.

## Step 3: Apply Project And Platform Boundaries

Apply only the AppProject and Kubernetes namespace boundaries first:

```bash
GIT_REPO_URL=git://host.docker.internal:9418/cloudops-gitops-platform \
  PROJECT_ONLY=true \
  ./scripts/local-bootstrap.sh
```

This applies:

- `argocd/projects/cloudops-project.yaml`
- `platform/namespaces`
- `platform/resourcequotas`
- `platform/rbac`

## Step 4: Apply Dev Only

Apply only the `dev` Application:

```bash
GIT_REPO_URL=git://host.docker.internal:9418/cloudops-gitops-platform \
  APP_ENV=dev \
  ./scripts/local-bootstrap.sh
```

Do not apply `staging` or `prod` until this succeeds.

## Step 5: Inspect The Real Error Path

Use Argo CD for detailed errors:

```bash
argocd app get cloudops-demo-dev
```

Also watch the Kubernetes object:

```bash
kubectl -n argocd get application cloudops-demo-dev -w
```

Common failure categories:

- repo not permitted in project: AppProject `sourceRepos` does not match Application `repoURL`.
- values file not found: `$values/environments/dev/values.yaml` is not resolving.
- repo unreachable: the cluster cannot reach the git daemon or GitHub URL.
- image pull failure: the app image tag is not available to the cluster.

## Step 6: Confirm Values Are Used

After `cloudops-demo-dev` is Synced and Healthy:

```bash
kubectl -n cloudops-dev port-forward svc/cloudops-demo-dev 8081:80
```

In another terminal:

```bash
curl http://localhost:8081/version
```

Expected:

```json
{
  "environment": "dev",
  "image_tag": "0.1.0-dev"
}
```

The exact JSON includes more fields, but `environment` and `image_tag` prove the multi-source values file was read.

## After Dev Passes

Apply the remaining Applications:

```bash
GIT_REPO_URL=git://host.docker.internal:9418/cloudops-gitops-platform \
  APP_ENV=staging \
  ./scripts/local-bootstrap.sh

GIT_REPO_URL=git://host.docker.internal:9418/cloudops-gitops-platform \
  APP_ENV=prod \
  ./scripts/local-bootstrap.sh
```

Then capture the screenshots listed in [screenshots/README.md](screenshots/README.md).
