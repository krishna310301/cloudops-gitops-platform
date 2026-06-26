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
  environment = "prod"
  name_prefix = "cloudops-gitops-prod"
  tags = {
    Project     = "CloudOps GitOps Platform"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = local.name_prefix
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
  vpc_id             = "phase-2-placeholder"
  private_subnet_ids = []
  tags               = local.tags
}

module "iam" {
  source            = "../../modules/iam"
  github_repository = var.github_repository
  cluster_name      = module.eks.cluster_name
  tags              = local.tags
}
