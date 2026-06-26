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

output "github_actions_policy_arn" {
  description = "IAM policy ARN for CI image push and EKS describe permissions."
  value       = module.iam.github_actions_policy_arn
}

output "kubectl_update_command" {
  description = "Command to configure kubectl for this EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
