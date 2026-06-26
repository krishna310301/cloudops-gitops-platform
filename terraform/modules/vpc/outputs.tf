output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the EKS managed node group."
  value       = values(aws_subnet.public)[*].id
}

output "subnet_ids" {
  description = "Subnet IDs available for EKS."
  value       = values(aws_subnet.public)[*].id
}
