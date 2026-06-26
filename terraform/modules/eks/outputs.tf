output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "node_role_arn" {
  description = "EKS node role ARN."
  value       = aws_iam_role.node.arn
}

output "cluster_role_arn" {
  description = "EKS control-plane role ARN."
  value       = aws_iam_role.cluster.arn
}
