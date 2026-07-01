resource "aws_budgets_budget" "this" {
  name         = "${var.name_prefix}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.limit_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = var.alert_email == "" ? [] : [var.alert_email]
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = var.alert_threshold_percent
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = [notification.value]
    }
  }

  tags = var.tags
}
