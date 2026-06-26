# AWS Deployment Path

This project has a local GitOps proof and an AWS deployment path. The AWS path uses one EKS cluster from `terraform/envs/dev`, then keeps `dev`, `staging`, and `prod` separated as Kubernetes namespaces inside that cluster.

That model is intentional for a portfolio build: it proves the EKS/ECR/IAM/VPC workflow without creating three cost-bearing EKS clusters.

## Preflight

Run the permission preflight before `terraform apply`:

```bash
AWS_REGION=us-east-2 ./scripts/aws-preflight.sh
```

The AWS identity must be able to create the foundation resources used by `terraform/envs/dev`:

- VPC networking: VPC, subnets, internet gateway, route table, route associations, security group, tags
- IAM: cluster role, node role, managed policy attachments, deployment policy, `iam:PassRole`
- EKS: cluster and managed node group
- ECR: repository, lifecycle policy, image push permissions

If preflight reports denied actions, attach a policy with those permissions or switch to an AWS profile that can create EKS infrastructure.

## Apply Dev Foundation

```bash
terraform -chdir=terraform/envs/dev init -upgrade
terraform -chdir=terraform/envs/dev plan -out=tfplan
terraform -chdir=terraform/envs/dev apply tfplan
```

Expected outputs:

```bash
terraform -chdir=terraform/envs/dev output -raw cluster_name
terraform -chdir=terraform/envs/dev output -raw ecr_repository_url
terraform -chdir=terraform/envs/dev output -raw kubectl_update_command
```

## Push Images to ECR

```bash
AWS_REGION=us-east-2
ECR_REPO="$(terraform -chdir=terraform/envs/dev output -raw ecr_repository_url)"
ECR_REGISTRY="${ECR_REPO%/*}"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker build -t cloudops-demo-app:0.1.0-dev ./app
docker tag cloudops-demo-app:0.1.0-dev "$ECR_REPO:0.1.0-dev"
docker tag cloudops-demo-app:0.1.0-dev "$ECR_REPO:0.1.0-staging"
docker tag cloudops-demo-app:0.1.0-dev "$ECR_REPO:0.1.0-prod"
docker push "$ECR_REPO:0.1.0-dev"
docker push "$ECR_REPO:0.1.0-staging"
docker push "$ECR_REPO:0.1.0-prod"
```

After the images exist in ECR, update `environments/*/values.yaml` to use the ECR repository URL, commit, and push to GitHub.

## Connect Argo CD on EKS

```bash
aws eks update-kubeconfig --region us-east-2 --name cloudops-gitops-dev
./scripts/install-argocd.sh

GIT_REPO_URL=https://github.com/krishna310301/cloudops-gitops-platform.git \
  PROJECT_ONLY=true ./scripts/local-bootstrap.sh

GIT_REPO_URL=https://github.com/krishna310301/cloudops-gitops-platform.git \
  APP_ENV=all ./scripts/local-bootstrap.sh
```

Then verify:

```bash
argocd app get cloudops-demo-dev
argocd app get cloudops-demo-staging
argocd app get cloudops-demo-prod
kubectl get pods -n cloudops-dev
kubectl get pods -n cloudops-staging
kubectl get pods -n cloudops-prod
```

## Evidence to Capture

- Terraform apply output showing the EKS cluster and ECR repository
- ECR repository with pushed `0.1.0-*` image tags
- EKS nodes ready
- Argo CD showing all three apps Synced and Healthy against the GitHub repo
- Drift demo on EKS: manual replica change, OutOfSync, then self-healed
- Rollback demo on EKS: failed health check, Degraded, Git revert, Healthy

## Destroy Boundary

EKS and EC2 nodes are cost-bearing. Destroy the stack after capturing evidence unless the cluster is still needed:

```bash
terraform -chdir=terraform/envs/dev destroy
```
