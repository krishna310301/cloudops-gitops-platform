# Cost Control

The AWS path is intended for short validation runs. Apply the stack when validation output needs to be captured, then destroy it when the validation window is complete.

## Cost-Bearing Resources

The Terraform `dev` environment creates resources that can continue to generate AWS charges:

- EKS control plane
- Managed worker nodes
- ECR image storage
- CloudWatch log ingestion and retention

This project does not create NAT gateways, RDS databases, or load balancers by default.

## Before Apply

Before applying Terraform, confirm the AWS account, region, and planned resources:

```bash
AWS_REGION=us-east-2 ./scripts/aws-preflight.sh
terraform -chdir=terraform/envs/dev plan
```

Review the plan for:

- `aws_eks_cluster`
- `aws_eks_node_group`
- `aws_ecr_repository`
- `aws_iam_role`
- `aws_vpc`
- `aws_subnet`

Do not apply if you cannot clean up the environment after validation.

## Cleanup

Delete Argo CD and application resources before destroying the EKS foundation:

```bash
kubectl delete -f argocd/applications --ignore-not-found
kubectl delete -f argocd/projects --ignore-not-found
kubectl delete -f platform/rbac --ignore-not-found
kubectl delete -f platform/resourcequotas --ignore-not-found
kubectl delete -f platform/namespaces --ignore-not-found
kubectl delete namespace argocd --ignore-not-found
```

Then destroy the AWS foundation:

```bash
terraform -chdir=terraform/envs/dev destroy
```

## Cleanup Verification

After destroy, verify that the following are gone or no longer running:

- EKS cluster `cloudops-gitops-dev`
- Managed node group `cloudops-gitops-dev-nodes`
- EC2 worker nodes created by the node group
- ECR repository and images, unless a follow-up validation run needs them
- CloudWatch log groups created during validation
