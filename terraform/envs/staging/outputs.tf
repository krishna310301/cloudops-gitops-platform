output "environment" {
  description = "Environment name."
  value       = local.environment
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.ecr.repository_url
}

output "budget_name" {
  description = "AWS Budget name for this environment."
  value       = var.enable_budget ? module.budget[0].budget_name : null
}

output "budget_limit_usd" {
  description = "Monthly AWS Budget limit in USD."
  value       = var.enable_budget ? module.budget[0].budget_limit_usd : null
}
