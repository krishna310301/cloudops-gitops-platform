variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the VPC."
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Use null to let AWS select the current default."
  type        = string
  default     = null
  nullable    = true
}

variable "github_repository" {
  description = "GitHub repository in owner/name format."
  type        = string
  default     = "krishna310301/cloudops-gitops-platform"
}
