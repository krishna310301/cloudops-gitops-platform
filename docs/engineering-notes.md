# Engineering Notes

This document records implementation boundaries, design tradeoffs, and operational behavior for the GitOps workflow.

## Scope

The repository implements one EKS-backed delivery platform with three namespace-scoped environments:

- `cloudops-dev`
- `cloudops-staging`
- `cloudops-prod`

The environments share one cluster. Isolation is provided through namespaces, ResourceQuotas, Roles, RoleBindings, ServiceAccounts, separate Argo CD Applications, and separate Helm values.

## GitOps Contract

Git is the desired-state source for workload delivery.

- Argo CD watches the repository.
- Helm renders the application manifests.
- Environment-specific values select replica counts, image tags, resource requests, limits, and failure-mode settings.
- Promotion is represented as a Git change to the target environment values file.
- Rollback is represented as a Git revert, keeping live state aligned with declared state.

## Argo CD Over Flux

Flux would also be a valid controller for this workflow. Argo CD is used because it provides application-level health, sync status, history, AppProjects, and self-heal behavior through a clear API and UI.

## Git Rollback Versus Argo CD UI Rollback

This repository uses Git rollback for the validation scenario. Argo CD UI rollback can be useful during an incident, but if the repository still declares the failed state, reconciliation can move the cluster back toward that failed state. A Git revert updates the source of truth.

## RBAC Boundary

The repo includes per-environment Roles, RoleBindings, and ServiceAccounts. These are real Kubernetes RBAC objects and differ by environment.

Current limitation:

- Argo CD sync uses the Argo CD controller permissions.
- The environment ServiceAccounts model scoped operator or CI access. They are not the active Argo CD sync identity.

Possible hardening:

- Configure and verify per-environment sync impersonation or reduced-permission cluster credentials.
- Validate that each Application can sync only inside its intended namespace.

## Environment Isolation Boundary

This project uses namespace isolation. It does not provide the same blast-radius reduction as separate AWS accounts or separate EKS clusters.

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
