# Validation Output

Local run:

1. `argocd-three-apps-synced.png`
   - Argo CD showing dev, staging, and prod Applications as Synced and Healthy.

2. `drift-before-outofsync.png`
   - Manual replica change visible in Kubernetes or Argo CD.

3. `drift-after-self-heal.png`
   - Argo CD restored the Git-defined replica count.

4. `failed-deploy-degraded.png`
   - Failed readiness probe or bad image causing Degraded health.

5. `rollback-recovered.png`
   - Git rollback restored Healthy and Synced state.

6. `namespace-boundaries.png`
   - Namespaces, ResourceQuotas, and RBAC objects visible with `kubectl`.

7. `argocd-values-source.png`
   - Argo CD resolving `$values/environments/.../values.yaml` for at least one Application.

Additional terminal output:

- `failed-deploy-terminal-output.png`
- `rollback-terminal-output.png`

AWS run:

1. `aws-terraform-eks-validation.png`
   - Terraform outputs and live EKS cluster status.

2. `aws-ecr-images-validation.png`
   - ECR repository and pushed `0.1.0-*` image tags.

3. `aws-argocd-three-apps-synced.png`
   - Argo CD on EKS showing dev, staging, and prod as Synced and Healthy.

4. `aws-eks-workloads-validation.png`
   - EKS nodes, Argo CD Applications, and running pods across all three namespaces.

5. `aws-namespace-boundaries-validation.png`
   - Namespace, ResourceQuota, ServiceAccount, Role, and RoleBinding output on EKS.

6. `aws-drift-before-outofsync.png`
   - EKS drift scenario showing manual scale to 3 replicas and Argo CD OutOfSync.

7. `aws-drift-after-self-heal.png`
   - EKS drift scenario after Argo CD restored the Git-defined replica count.

8. `aws-rollback-failed-degraded.png`
   - EKS rollback scenario showing the bad staging commit and Degraded health.

9. `aws-rollback-recovered.png`
   - EKS rollback scenario after Git revert recovery.

10. `aws-rollback-terminal-output.png`
    - Argo CD event history showing Degraded and recovered health transitions.

AWS v1.1 run:

1. `aws-v1-1-argocd-four-apps-synced.png`
   - Argo CD showing dev, staging, prod, and observability Applications as Synced and Healthy.

2. `aws-v1-1-kubernetes-observability-validation.png`
   - EKS nodes, observability pods, app pods, and app ServiceMonitors.

3. `aws-v1-1-prometheus-app-targets.png`
   - Prometheus target page showing app ServiceMonitor targets as Up.

4. `aws-v1-1-grafana-workload-dashboard.png`
   - Grafana dashboard for workload health, CPU, memory, replicas, request rate, and app health.

5. `aws-v1-1-app-metrics-validation.png`
   - Demo app `/metrics` output and Prometheus query output across dev, staging, and prod.

6. `aws-v1-1-aws-budget-ecr-validation.png`
   - Terraform outputs, ECR image tags, and AWS Budget output.

7. `aws-v1-1-destroy-validation.png`
   - Terraform destroy completion, empty state, and AWS not-found checks after teardown.
