# Drift Detection Demo

This demo proves that Git, not manual cluster state, defines the desired environment.

## Setup

Ensure the `dev` Application is Synced and Healthy in Argo CD.

Expected desired state:

- Namespace: `cloudops-dev`
- Deployment: `cloudops-demo-dev`
- Replicas: `1`

## Demo Steps

Run:

```bash
./scripts/demo-drift.sh dev
```

Manual equivalent:

```bash
kubectl -n cloudops-dev scale deployment cloudops-demo-dev --replicas=3
kubectl -n cloudops-dev get deployment cloudops-demo-dev
```

Argo CD should detect that live state no longer matches Git. With self-heal enabled, it should reconcile the deployment back to the replica count declared in `environments/dev/values.yaml`.

## Evidence To Capture

- Argo CD `cloudops-demo-dev` Application before drift: Synced and Healthy
- Application after manual scale: OutOfSync
- Application after self-heal: Synced and Healthy again
- `kubectl get deployment` showing replicas restored to Git-defined count

## Interview Talking Point

Manual cluster changes are treated as drift. Argo CD compares the live Kubernetes object against the rendered Git state and reconciles the difference.
