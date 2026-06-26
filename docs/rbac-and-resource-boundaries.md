# RBAC And Resource Boundaries

The project uses namespace isolation, not separate clusters or AWS accounts.

## Boundaries Implemented

Each environment gets:

- A dedicated namespace
- A ResourceQuota
- A Role
- A RoleBinding
- A workload ServiceAccount
- A separate Argo CD Application

## Why Quotas Matter

Without quotas, namespace isolation is mostly an organizational boundary. With quotas, each environment has explicit CPU, memory, and object limits, reducing the chance that a noisy lower environment consumes shared cluster capacity.

## Why RBAC Matters

The Role and RoleBinding create an access boundary for environment-scoped changes. This is intentionally minimal, but it follows a production operating principle: environments should not all share one broad access path.

## Argo CD Sync Identity Boundary

In the current build, these `cloudops-*-deployer` ServiceAccounts are not the active Argo CD sync identity. Argo CD syncs through its controller permissions after the Application manifests are applied.

That means the RBAC is real, but its current role is to model and enable scoped manual/operator or CI-style namespace access. It should not be described as constraining Argo CD's reconciliation loop yet.

Future hardening option:

- Wire and verify Argo CD per-environment sync impersonation or a reduced-permission cluster credential model.
- Keep `resource.respectRBAC` and controller discovery behavior in mind if reducing controller permissions.
- Record validation that the `dev`, `staging`, and `prod` Applications can sync only within their intended namespaces.

## Boundary Language

Accurate:

> namespace-isolated dev/staging/prod environments with ResourceQuotas and scoped RBAC boundaries

Inaccurate:

> fully isolated production environments

unless separate clusters or accounts are implemented.

Also avoid:

> Argo CD syncs each environment using least-privilege ServiceAccounts

unless that sync path is implemented and tested.
