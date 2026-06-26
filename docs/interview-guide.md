# Interview Guide

Use this project to explain delivery control, not application complexity.

## Core Story

CloudOps GitOps Platform demonstrates how Kubernetes workloads can be delivered through Git as the source of truth.

The project proves:

- Argo CD reconciles Kubernetes state from Git.
- `dev`, `staging`, and `prod` are represented as separate namespace-scoped environments.
- Environment promotion is a Git change to Helm values.
- Manual cluster drift is detected and corrected.
- A failed deployment can be recovered through Git rollback.

## Accurate Claims

Safe:

> Built a GitOps delivery workflow with namespace-isolated dev/staging/prod environments using Argo CD Applications, Helm values, ResourceQuotas, scoped RBAC, and Git-based promotion.

Safe:

> Demonstrated drift correction by manually scaling a deployment and allowing Argo CD self-heal to restore the Git-defined replica count.

Safe:

> Demonstrated rollback by committing a failed staging configuration and recovering through a Git revert.

Avoid:

> Fully isolated production environments.

Avoid unless implemented later:

> Argo CD syncs each environment using least-privilege ServiceAccounts.

Avoid unless implemented later:

> Separate AWS accounts or separate EKS clusters per environment.

## Argo CD Over Flux

Flux would also be valid. Argo CD was chosen because it provides:

- UI-visible health and sync status
- application-level rollback and history
- clear drift/self-heal evidence
- AppProject boundaries
- easy screenshots for portfolio review

## Git Rollback Versus Argo CD UI Rollback

This project uses Git rollback because Git remains the source of truth.

Argo CD UI rollback can be useful during an emergency, but if the Git repo still declares the bad state, the system can converge back to failure. Git revert keeps the declared state and live state aligned.

## RBAC Boundary

The repo includes per-environment Roles, RoleBindings, and ServiceAccounts. These are real Kubernetes RBAC objects and differ by environment.

Current limitation:

- Argo CD sync still uses the Argo CD controller permissions.
- The environment ServiceAccounts model scoped operator/CI access, not Argo CD sync identity.

Future hardening:

- Implement and verify per-environment sync impersonation or reduced-permission cluster credentials.

## Environment Isolation

This project uses namespace isolation:

- separate namespace
- separate ResourceQuota
- separate Role and RoleBinding
- separate Argo CD Application
- separate Helm values

This is not the same as separate AWS account or cluster isolation.

## Resume Bullet Drafts

Use only after the repo and screenshots are published:

- Built a GitOps delivery platform for Kubernetes using Argo CD, Helm, and GitHub Actions, implementing namespace-isolated dev/staging/prod workflows with Git-based promotion and environment-specific Helm values.
- Demonstrated Argo CD drift correction by manually changing live replica state and validating automated self-healing back to the Git-defined desired state.
- Validated failed-deployment recovery by committing a bad staging readiness configuration, observing Argo CD Degraded health, and restoring service through a Git revert rollback.
