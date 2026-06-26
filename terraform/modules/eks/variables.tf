variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Use null to let AWS select the current default."
  type        = string
  default     = null
  nullable    = true
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster and managed node group."
  type        = list(string)
}

variable "node_instance_types" {
  description = "Managed node group instance types."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Worker node disk size in GiB."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
