output "queue_url" {
  description = "URL of the main queue."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "ARN of the main queue."
  value       = aws_sqs_queue.this.arn
}

output "dlq_url" {
  description = "URL of the dead letter queue."
  value       = aws_sqs_queue.deadletter.id
}

output "dlq_arn" {
  description = "ARN of the dead letter queue."
  value       = aws_sqs_queue.deadletter.arn
}
