terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  environment = "staging"
  name_prefix = "cloudops-gitops-staging"
  tags = {
    Project     = "CloudOps GitOps Platform"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = local.name_prefix
  eks_name           = local.name_prefix
  cidr_block         = var.vpc_cidr_block
  availability_zones = var.availability_zones
  tags               = local.tags
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "${local.name_prefix}-demo-app"
  tags            = local.tags
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = local.name_prefix
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  tags               = local.tags
}

module "iam" {
  source             = "../../modules/iam"
  github_repository  = var.github_repository
  cluster_name       = module.eks.cluster_name
  ecr_repository_arn = module.ecr.repository_arn
  tags               = local.tags
}

module "budget" {
  count = var.enable_budget ? 1 : 0

  source                  = "../../modules/budget"
  name_prefix             = local.name_prefix
  limit_amount            = var.monthly_budget_limit_usd
  alert_threshold_percent = var.budget_alert_threshold_percent
  alert_email             = var.budget_alert_email
  tags                    = local.tags
}
