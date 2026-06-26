# Terraform AWS Infrastructure

This directory defines the AWS infrastructure for CloudOps GitOps Platform.

## Deployment Model

For the portfolio AWS demo, apply `envs/dev` only. The Kubernetes delivery environments remain namespace-isolated inside that single EKS cluster.

The `staging` and `prod` Terraform roots validate the reusable module contract, but applying all three would create three separate EKS clusters and is not required for this project story.

## Cost Boundary

This stack creates cost-bearing AWS resources, including EKS and EC2 worker nodes. Destroy the stack after capturing screenshots if it is not needed:

```bash
terraform -chdir=terraform/envs/dev destroy
```

## Permission Preflight

Run the AWS permission preflight before applying the dev root:

```bash
AWS_REGION=us-east-2 ./scripts/aws-preflight.sh
```

The apply identity needs permissions to create VPC networking, IAM roles/policies, an EKS cluster, a managed node group, an ECR repository, and to push images to ECR. The full deployment sequence is documented in [../docs/aws-deployment.md](../docs/aws-deployment.md).

## Intended Modules

- `modules/vpc`: VPC, public subnets, internet gateway, route table, EKS discovery tags
- `modules/eks`: EKS cluster, managed node group, cluster IAM role, node IAM role
- `modules/ecr`: ECR repository for the demo app image
- `modules/iam`: scoped deployment policy for ECR push and EKS cluster inspection

## Accurate Claim

Before apply:

> Terraform-defined AWS infrastructure for VPC, EKS, ECR, and IAM.

After successful apply and screenshots:

> Provisioned an AWS foundation with VPC, EKS, ECR, and IAM using Terraform, then deployed the GitOps workflow to EKS.

This has been validated for the `dev` Terraform root. The delivery environments are namespace-isolated inside one EKS cluster.
