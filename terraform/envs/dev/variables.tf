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

variable "enable_budget" {
  description = "Create an AWS Budget for the validation environment."
  type        = bool
  default     = true
}

variable "monthly_budget_limit_usd" {
  description = "Monthly AWS Budget amount for this validation environment."
  type        = string
  default     = "25"
}

variable "budget_alert_threshold_percent" {
  description = "Forecasted spend percentage that triggers the optional budget alert."
  type        = number
  default     = 80
}

variable "budget_alert_email" {
  description = "Optional email address for AWS Budget alerts. Leave empty to avoid storing an email address in Terraform variables."
  type        = string
  default     = ""
}
