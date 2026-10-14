output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by application service name."
  value = {
    for service, repository in module.ecr : service => repository.repository_url
  }
}

output "sqs_queue_url" {
  description = "URL of the application event queue."
  value       = module.sqs.queue_url
}

