# Terraform AWS Scaffold

This directory is a phase-2 scaffold for the AWS implementation of CloudOps GitOps Platform.

Local proof boundary:

- Keep the module contracts clear.
- Validate Terraform syntax.
- Do not spend local GitOps build time debugging AWS provisioning.

AWS deployment phase:

- Complete resources for VPC, EKS, ECR, and IAM.
- Run `terraform plan` with reviewed variables.
- Apply only when ready to capture EKS/ECR/Argo CD evidence.
- Destroy cost-bearing resources after screenshots are captured.

## Intended Modules

- `modules/vpc`: VPC, subnets, route tables, NAT gateway structure
- `modules/eks`: EKS cluster, managed node group, add-ons, OIDC provider
- `modules/ecr`: ECR repository for the demo app image
- `modules/iam`: IRSA and GitHub Actions OIDC roles

## Accurate Claim

Until resources are completed and applied, describe this as:

> EKS-ready Terraform scaffold for VPC, EKS, ECR, and IAM module boundaries.

Do not describe it as provisioned AWS infrastructure until it has been applied and verified.
