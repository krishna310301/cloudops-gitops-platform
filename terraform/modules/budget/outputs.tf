output "budget_name" {
  description = "AWS Budget name."
  value       = aws_budgets_budget.this.name
}

output "budget_limit_usd" {
  description = "Monthly budget limit in USD."
  value       = aws_budgets_budget.this.limit_amount
}
