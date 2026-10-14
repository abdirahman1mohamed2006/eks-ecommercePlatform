output "repository_url" {
  description = "URL of the ECR repository, used when tagging and pushing images."
  value       = aws_ecr_repository.eksv2.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.eksv2.arn
}

output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.eksv2.name
}

output "registry_id" {
  description = "AWS account ID that owns the registry."
  value       = aws_ecr_repository.eksv2.registry_id
}
