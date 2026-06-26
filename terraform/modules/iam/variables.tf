variable "github_repository" {
  description = "GitHub repository allowed to assume the deployment role."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for workload identity boundaries."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN for deployment policy scoping."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
