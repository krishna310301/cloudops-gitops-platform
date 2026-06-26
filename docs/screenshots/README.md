# Screenshot Evidence

Captured evidence:

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
   - Argo CD successfully resolving `$values/environments/.../values.yaml` for at least one Application.

Additional evidence:

- `failed-deploy-terminal-evidence.png`
- `rollback-terminal-evidence.png`

AWS evidence:

1. `aws-terraform-eks-evidence.png`
   - Terraform outputs and live EKS cluster status.

2. `aws-ecr-images-evidence.png`
   - ECR repository and pushed `0.1.0-*` image tags.

3. `aws-argocd-three-apps-synced.png`
   - Argo CD on EKS showing dev, staging, and prod as Synced and Healthy.

4. `aws-eks-workloads-evidence.png`
   - EKS nodes, Argo CD Applications, and running pods across all three namespaces.

5. `aws-namespace-boundaries-evidence.png`
   - Namespace, ResourceQuota, ServiceAccount, Role, and RoleBinding evidence on EKS.

6. `aws-drift-before-outofsync.png`
   - EKS drift demo showing manual scale to 3 replicas and Argo CD OutOfSync.

7. `aws-drift-after-self-heal.png`
   - EKS drift demo after Argo CD restored the Git-defined replica count.

8. `aws-rollback-failed-degraded.png`
   - EKS rollback demo showing the bad staging commit and Degraded health.

9. `aws-rollback-recovered.png`
   - EKS rollback demo after Git revert recovery.

10. `aws-rollback-terminal-evidence.png`
    - Argo CD event history showing Degraded and recovered health transitions.
