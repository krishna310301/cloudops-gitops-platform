variable "name_prefix" {
  description = "Name prefix for the AWS Budget."
  type        = string
}

variable "limit_amount" {
  description = "Monthly budget limit in USD."
  type        = string
}

variable "alert_threshold_percent" {
  description = "Forecasted spend percentage that triggers the optional budget alert."
  type        = number
  default     = 80
}

variable "alert_email" {
  description = "Optional email address for budget alerts. Leave empty to create the budget without notifications."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to the budget."
  type        = map(string)
  default     = {}
}
