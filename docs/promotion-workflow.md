# Promotion Workflow

Promotion is PR-style and image-tag based.

The same container image tag moves from `dev` to `staging` to `prod`. The app is not rebuilt separately for each environment.

## Why This Model

This mirrors how platform teams commonly treat promotion:

- Build once.
- Verify in lower environments.
- Promote the immutable artifact.
- Use Git history for auditability.
- Roll back by reverting the environment change.

## Workflow

1. CI builds and tests the app image.
2. CI proposes or applies the image tag to `environments/dev/values.yaml`.
3. Argo CD syncs `dev`.
4. A promotion workflow opens a pull request to update `environments/staging/values.yaml` to the same tag.
5. After review and merge, Argo CD syncs `staging`.
6. The same process promotes the tag to `prod`.

## Interview-Safe Claim

Accurate:

> Promotion happens through reviewed Git changes to environment-specific Helm values.

Do not claim automated production deployment with enforced branch protection unless branch protection is configured in GitHub.

## Terraform Boundary

Terraform in this repo defines the AWS implementation. It is kept separate from the local proof so the GitOps workflow can be validated without provisioning cloud resources first.

Local proof scope:

- Keep module directories and variables clear.
- Include realistic resource boundaries.
- Avoid spending time debugging AWS provisioning.

AWS deployment scope:

- Complete Terraform resources.
- Run `terraform plan` and `terraform apply`.
- Capture EKS/ECR/IAM evidence.
