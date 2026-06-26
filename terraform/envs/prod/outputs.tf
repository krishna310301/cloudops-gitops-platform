output "environment" {
  description = "Environment name."
  value       = local.environment
}

output "cluster_name" {
  description = "Planned EKS cluster name."
  value       = module.eks.cluster_name
}
