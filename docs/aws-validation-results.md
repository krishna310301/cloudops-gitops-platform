# AWS Validation Results

AWS validation ran after the local GitOps loop worked. The run used one EKS cluster, ECR images, Argo CD, and the public GitHub repository.

Validation date: June 25, 2026 local time / June 26, 2026 UTC.

v1.1 validation date: July 1, 2026 local time / July 2, 2026 UTC.

## Runtime

- AWS account: `196750375574`
- Region: `us-east-2`
- EKS cluster: `cloudops-gitops-dev`
- Kubernetes version: `1.36`
- Node group: `cloudops-gitops-dev-nodes`
- Worker nodes: 2 Amazon Linux 2023 managed nodes
- ECR repository: `196750375574.dkr.ecr.us-east-2.amazonaws.com/cloudops-gitops-dev-demo-app`
- Git source: `https://github.com/krishna310301/cloudops-gitops-platform.git`
- Argo CD: `v3.4.4`
- AWS Budget: `cloudops-gitops-dev-monthly-budget`, `$25` monthly limit

## Verified Outcomes

### Terraform AWS Foundation

Terraform applied the `terraform/envs/dev` root and created 20 AWS resources for the v1.1 validation environment:

- VPC, public subnets, internet gateway, route table, and route associations
- ECR repository with lifecycle policy
- EKS control plane and managed node group
- EKS cluster role, node role, managed policy attachments, and deployment policy
- EKS control-plane security group
- AWS Budget for the short-lived validation environment

Output:

![AWS Terraform and EKS validation output](screenshots/aws-terraform-eks-validation.png)

v1.1 output:

![AWS v1.1 foundation, ECR tags, and budget](screenshots/aws-v1-1-aws-budget-ecr-validation.png)

### ECR Image Publishing

The demo app image was rebuilt for `linux/amd64` and pushed to ECR with environment tags:

- `0.1.0-dev`
- `0.1.0-staging`
- `0.1.0-prod`

Output:

![AWS ECR images validation output](screenshots/aws-ecr-images-validation.png)

### EKS GitOps Sync

Argo CD ran on EKS and synced the public GitHub repository. The three Applications reached `Synced` and `Healthy`:

- `cloudops-demo-dev`
- `cloudops-demo-staging`
- `cloudops-demo-prod`

Output:

![AWS Argo CD apps synced](screenshots/aws-argocd-three-apps-synced.png)

![AWS EKS workloads validation output](screenshots/aws-eks-workloads-validation.png)

For v1.1, Argo CD also synced the observability stack. All four Applications reached `Synced` and `Healthy`:

- `cloudops-demo-dev`
- `cloudops-demo-staging`
- `cloudops-demo-prod`
- `cloudops-observability`

Output:

![AWS v1.1 Argo CD four apps synced](screenshots/aws-v1-1-argocd-four-apps-synced.png)

![AWS v1.1 Kubernetes observability validation](screenshots/aws-v1-1-kubernetes-observability-validation.png)

### GitOps-Managed Observability On EKS

The v1.1 run deployed `kube-prometheus-stack` through Argo CD into `cloudops-observability`.

Validated:

- Prometheus, Grafana, kube-state-metrics, and node-exporter pods running
- App ServiceMonitors created in `cloudops-dev`, `cloudops-staging`, and `cloudops-prod`
- Prometheus scraping app `/metrics` targets
- Grafana dashboard showing dev/staging/prod workload health, CPU, memory, replicas, request rate, and app health
- Demo app metrics showing healthy state across all three environments

Output:

![AWS v1.1 Prometheus app targets](screenshots/aws-v1-1-prometheus-app-targets.png)

![AWS v1.1 Grafana workload dashboard](screenshots/aws-v1-1-grafana-workload-dashboard.png)

![AWS v1.1 app metrics validation](screenshots/aws-v1-1-app-metrics-validation.png)

### Namespace Boundaries On EKS

The EKS cluster used separate namespace-scoped boundaries for `dev`, `staging`, and `prod`:

- Namespaces
- ResourceQuotas
- Roles and RoleBindings
- ServiceAccounts

Output:

![AWS namespace boundaries validation output](screenshots/aws-namespace-boundaries-validation.png)

### Drift Detection And Self-Healing On EKS

Manual drift was introduced by scaling `cloudops-demo-dev` from 1 replica to 3 replicas.

Argo CD detected the live-state mismatch as `OutOfSync` and restored the deployment to the Git-defined replica count.

Output:

![AWS drift before self-heal](screenshots/aws-drift-before-outofsync.png)

![AWS drift after self-heal](screenshots/aws-drift-after-self-heal.png)

### Failed Deployment And Git Rollback On EKS

A bad staging commit enabled `failureMode=true`. Readiness checks failed, and Argo CD marked staging as `Degraded`.

A Git revert restored the previous desired state. Argo CD synced the reverted revision and brought staging back to `Synced` and `Healthy`.

Output:

![AWS rollback failed degraded](screenshots/aws-rollback-failed-degraded.png)

![AWS rollback recovered](screenshots/aws-rollback-recovered.png)

![AWS rollback terminal output](screenshots/aws-rollback-terminal-output.png)

### Cost Guardrail And Teardown

The v1.1 run included an AWS Budget for the short-lived validation environment. After validation, Terraform destroyed all 20 managed resources.

Independent cleanup checks confirmed:

- Terraform state was empty
- EKS cluster lookup returned `ResourceNotFoundException`
- ECR repository lookup returned `RepositoryNotFoundException`
- AWS Budget lookup returned `NotFoundException`
- Project tag sweep returned no resources

During teardown, AWS left one unattached Kubernetes ENI from a terminated worker node and one EKS-created cluster security group. Both were verified, removed, and Terraform then completed VPC deletion.

Output:

![AWS v1.1 destroy validation](screenshots/aws-v1-1-destroy-validation.png)

## Important Implementation Note

The first ECR push from a local Apple Silicon machine produced an ARM image manifest. EKS nodes were AMD64, so pods failed with:

```text
no match for platform in manifest
```

The fix was to rebuild and push the image with:

```bash
docker buildx build --platform linux/amd64 \
  -t "$ECR_REPO:0.1.0-dev" \
  -t "$ECR_REPO:0.1.0-staging" \
  -t "$ECR_REPO:0.1.0-prod" \
  --push ./app
```

That is documented in the AWS deployment runbook because it is a realistic local-to-EKS issue.

## Current Boundary

Implemented:

> Provisioned an AWS EKS/ECR/VPC/IAM foundation with Terraform and deployed a GitOps workflow to EKS using Argo CD, Helm, and GitHub as the source of truth.

Implemented:

> Implemented namespace-isolated `dev`, `staging`, and `prod` delivery environments inside one EKS cluster.

Implemented in v1.1:

> Extended the platform with Argo CD-managed Prometheus/Grafana observability and a Terraform-managed AWS Budget for the short-lived validation environment.

Not implemented:

> Three separate EKS clusters, separate AWS accounts, or Argo CD syncing through least-privilege per-environment ServiceAccounts.
