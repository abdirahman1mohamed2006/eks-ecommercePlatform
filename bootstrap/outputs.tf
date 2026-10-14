output "github_actions_deploy_role_arn" {
	description = "Role ARN to store as the AWS_DEPLOY_ROLE_ARN GitHub Actions secret."
	value       = aws_iam_role.github_actions_deploy.arn
}