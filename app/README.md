# Demo App

The demo app is intentionally small. It exists to prove GitOps behavior, not application complexity.

Endpoints:

- `/` returns app identity and environment.
- `/healthz` returns healthy unless failure mode is enabled.
- `/version` returns version, image tag, environment, and hostname.

Environment variables:

- `APP_NAME`
- `APP_ENV`
- `APP_VERSION`
- `IMAGE_TAG`
- `FAILURE_MODE`
