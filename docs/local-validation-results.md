# Local Validation Results

Local validation ran against a kind cluster before the AWS run. The goal was to test the GitOps behavior first, without spending time or money on EKS while the manifests were still changing.

Validation date: June 25, 2026 local time / June 26, 2026 UTC.

## Runtime

- Local cluster: `kind-cloudops-gitops`
- Argo CD: `v3.4.4`
- Git source: `git://host.docker.internal:9418/cloudops-gitops-platform`
- Demo app image: local `cloudops-demo-app` image loaded into kind
- Current local re-run values root: `environments/local`

## Verified Outcomes

### Three Applications Synced And Healthy

Argo CD synced three Applications:

- `cloudops-demo-dev`
- `cloudops-demo-staging`
- `cloudops-demo-prod`

Output:

![Argo CD three apps synced](screenshots/argocd-three-apps-synced.png)

### Multi-Source Values Resolution

The `dev` Application uses Argo CD multi-source configuration:

- chart source: `charts/cloudops-demo-app`
- values source ref: `values`
- values file at validation time: `$values/environments/dev/values.yaml`
- current local re-run value file: `$values/environments/local/dev/values.yaml`

The running app returned `environment=dev` and `image_tag=0.1.0-dev`, which confirmed that Argo CD read the environment values file.

Output:

![Argo CD values source](screenshots/argocd-values-source.png)

### Namespace Boundaries

The local cluster has separate namespaces, ResourceQuotas, Roles, RoleBindings, and ServiceAccounts for `dev`, `staging`, and `prod`.

Output:

![Namespace boundaries](screenshots/namespace-boundaries.png)

### Drift Detection And Self-Healing

Manual drift was introduced by scaling `cloudops-demo-dev` from 1 replica to 3 replicas.

Argo CD detected the drift as `OutOfSync` and restored the deployment to the Git-defined replica count.

Output:

![Drift before self-heal](screenshots/drift-before-outofsync.png)

![Drift after self-heal](screenshots/drift-after-self-heal.png)

### Failed Deployment And Git Rollback

A bad staging configuration enabled `failureMode=true`. The readiness probe failed, and Argo CD marked staging as `Degraded`.

Output:

![Failed deployment degraded](screenshots/failed-deploy-degraded.png)

![Failed deployment terminal output](screenshots/failed-deploy-terminal-output.png)

A Git revert restored the previous desired state. Argo CD synced that revision and brought staging back to `Synced` and `Healthy`.

Output:

![Rollback recovered](screenshots/rollback-recovered.png)

![Rollback terminal output](screenshots/rollback-terminal-output.png)

## Commands Used For Final Checks

```bash
python3 -m unittest discover -s app/tests -v
helm lint charts/cloudops-demo-app -f environments/dev/values.yaml
helm lint charts/cloudops-demo-app -f environments/staging/values.yaml
helm lint charts/cloudops-demo-app -f environments/prod/values.yaml
./scripts/render-helm.sh
VALUES_ROOT=environments/local ./scripts/render-helm.sh
bash -n scripts/*.sh
terraform -chdir=terraform fmt -check -recursive
```
