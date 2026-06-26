# Rollback Demo

This demo proves failed delivery recovery through Git.

## Failure Options

Use one of these failure modes:

- Set an invalid image tag in the target environment.
- Set `failureMode.enabled=true` to make the readiness probe fail.

The readiness failure path is better for local demos because it does not depend on registry access.

## Demo Steps

Run:

```bash
./scripts/demo-rollback.sh staging
```

Manual equivalent:

1. Edit `environments/staging/values.yaml`.
2. Set:

   ```yaml
   failureMode:
     enabled: true
   ```

3. Commit the change and let Argo CD sync.
4. Confirm the application becomes Degraded.
5. Revert the Git change.
6. Let Argo CD sync the previous healthy desired state.

## Evidence To Capture

- Argo CD `cloudops-demo-staging` before failure: Synced and Healthy
- Failed rollout: Degraded
- Git revert commit or rollback PR
- Application recovered: Synced and Healthy
- `/healthz` returning healthy after recovery

## Interview Talking Point

Git rollback is preferred for this project because it preserves the source-of-truth model. Argo CD UI rollback can be useful in emergencies, but if the Git repo still declares the bad state, the system can drift back into failure.
