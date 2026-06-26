output "github_actions_policy_arn" {
  description = "IAM policy ARN that can be attached to a GitHub Actions OIDC role or CI deploy role."
  value       = aws_iam_policy.github_actions_deploy.arn
}
