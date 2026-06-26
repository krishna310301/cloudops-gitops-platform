variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.30.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the VPC scaffold."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "github_repository" {
  description = "GitHub repository in owner/name format."
  type        = string
  default     = "krishna310301/cloudops-gitops-platform"
}
