# Engineering Notes

These notes cover the boundaries, tradeoffs, and runtime behavior behind the GitOps workflow.

## Scope

The repo runs one EKS-backed delivery platform with three namespace-scoped environments:

- `cloudops-dev`
- `cloudops-staging`
- `cloudops-prod`

The environments share one cluster. Namespaces, ResourceQuotas, Roles, RoleBindings, ServiceAccounts, separate Argo CD Applications, and separate Helm values provide the separation.

## GitOps Contract

Git is the desired-state source for workload delivery.

- Argo CD watches the repository.
- Helm renders the application manifests.
- Environment-specific values select replica counts, image tags, resource requests, limits, and failure-mode settings.
- Promotion changes the target environment values file in Git.
- Rollback uses a Git revert so live state stays aligned with declared state.

## Argo CD Over Flux

Flux would also work for this workflow. This repo uses Argo CD because it exposes application health, sync status, revision history, AppProjects, and self-heal behavior through a clear API and UI.

## Git Rollback Versus Argo CD UI Rollback

This repo uses Git rollback for the validation scenario. Argo CD UI rollback can help during an incident, but the cluster can reconcile back to the failed state if Git still declares it. A Git revert changes the source of truth.

## RBAC Boundary

The repo includes per-environment Roles, RoleBindings, and ServiceAccounts. These are real Kubernetes RBAC objects and differ by environment.

Current limitation:

- Argo CD sync uses the Argo CD controller permissions.
- The environment ServiceAccounts model scoped operator or CI access. They are not the active Argo CD sync identity.

Possible hardening:

- Configure and verify per-environment sync impersonation or reduced-permission cluster credentials.
- Validate that each Application can sync only inside its intended namespace.

## Environment Isolation Boundary

This repo uses namespace isolation. Separate AWS accounts or separate EKS clusters would reduce blast radius further.

Accurate language:

> namespace-isolated dev/staging/prod environments inside one EKS cluster

Inaccurate language:

> three isolated production environments

## Local And AWS Values

The default `environments/{dev,staging,prod}` values point at the ECR repository used by the AWS deployment.

For local kind or minikube runs, use:

```bash
VALUES_ROOT=environments/local ./scripts/render-helm.sh
VALUES_ROOT=environments/local ./scripts/render-argocd.sh
VALUES_ROOT=environments/local ./scripts/local-bootstrap.sh
```

The local values root keeps local image names separate from the EKS/ECR desired state.
