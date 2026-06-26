# Screenshot Checklist

Capture these after the local proof works:

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
