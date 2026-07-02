# Observability

`v1.1` adds GitOps-managed observability to the delivery platform. Argo CD owns the monitoring stack the same way it owns the app environments.

## Scope

Included:

- `cloudops-observability` namespace
- ResourceQuota and scoped reader RBAC for the observability namespace
- Argo CD AppProject for observability
- Argo CD Application for `kube-prometheus-stack`
- Prometheus, Grafana, kube-state-metrics, and node-exporter
- Demo app `/metrics` endpoint
- Helm-managed ServiceMonitor for `dev`, `staging`, and `prod`
- One Grafana dashboard for workload health, CPU, memory, replicas, request rate, and app health

Not included:

- Loki
- Tempo
- Alertmanager routing
- Slack or PagerDuty notifications
- Long-term metrics retention

Those are useful, but they belong in a later version or in the SRE Platform project.

## GitOps Model

The observability stack is defined in:

```text
argocd/projects/cloudops-observability-project.yaml
argocd/applications/observability.yaml
environments/observability/kube-prometheus-stack-values.yaml
platform/observability/grafana-dashboard.yaml
platform/namespaces/observability.yaml
platform/resourcequotas/observability.yaml
platform/rbac/observability.yaml
```

The Argo CD Application uses multiple sources:

- Prometheus community Helm repo for `kube-prometheus-stack`
- This Git repository for Helm values
- This Git repository for the Grafana dashboard ConfigMap

The app chart exposes a ServiceMonitor only when `serviceMonitor.enabled=true`. The AWS environment values enable it because the v1.1 path includes Prometheus Operator CRDs. Local values leave it disabled so local app validation can run without the observability stack.

The EKS validation values disable kube-system control-plane scrape stubs for CoreDNS, kube-proxy, etcd, scheduler, and controller-manager. Those endpoints are not the focus of this project, and keeping them off lets the observability AppProject stay scoped to the observability namespace.

## Install Order

For a clean cluster, apply the platform boundaries and sync observability before syncing the app environments:

```bash
GIT_REPO_URL=https://github.com/krishna310301/cloudops-gitops-platform.git PROJECT_ONLY=true ./scripts/local-bootstrap.sh
GIT_REPO_URL=https://github.com/krishna310301/cloudops-gitops-platform.git APP_ENV=observability ./scripts/local-bootstrap.sh
argocd app sync cloudops-observability
argocd app wait cloudops-observability --health --sync --timeout 600
GIT_REPO_URL=https://github.com/krishna310301/cloudops-gitops-platform.git APP_ENV=all ./scripts/local-bootstrap.sh
```

If the app environments sync before the Prometheus Operator CRDs are ready, Argo CD may show the ServiceMonitor resource as temporarily failed. Sync again after `cloudops-observability` is Healthy.

## App Metrics

The demo app exposes Prometheus text metrics at `/metrics`:

- `cloudops_demo_requests_total`
- `cloudops_demo_health_state`
- `cloudops_demo_build_info`

The ServiceMonitor scrapes the app services in `cloudops-dev`, `cloudops-staging`, and `cloudops-prod`.

## Grafana Dashboard

The dashboard ConfigMap is labeled for the Grafana sidecar:

```yaml
grafana_dashboard: "1"
```

The dashboard focuses on one operational view:

- Ready pods by environment
- CPU usage by environment
- Memory usage by environment
- Available deployment replicas
- Demo app request rate
- Demo app health state

Access Grafana during validation:

```bash
kubectl -n cloudops-observability port-forward svc/cloudops-observability-grafana 3000:80
```

For a short validation run, use the chart-created admin credentials from the Grafana secret. For any long-running environment, replace this with an external secret flow instead of storing credentials in Git.

## Validation Output To Capture

Capture these after the v1.1 AWS run:

- Argo CD showing `cloudops-observability` as Synced and Healthy
- Prometheus targets showing app ServiceMonitor targets
- Grafana dashboard with dev/staging/prod workload data
- `/metrics` output from one app pod or service
- Terraform output showing the AWS Budget name and limit
