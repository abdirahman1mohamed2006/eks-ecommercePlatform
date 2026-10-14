output "worker_workload_role_arn" {
  description = "ARN of the IRSA role for the worker workload; annotate the service account with it."
  value       = aws_iam_role.worker_workload.arn
}

output "order_service_workload_role_arn" {
  description = "ARN of the IRSA role for the order service; annotate the service account with it."
  value       = aws_iam_role.order_service_workload.arn
}

output "payments_workload_role_arn" {
  description = "ARN of the IRSA role for the payments service; annotate the service account with it."
  value       = aws_iam_role.payments_workload.arn
}

output "shipping_workload_role_arn" {
  description = "ARN of the IRSA role for the shipping service; annotate the service account with it."
  value       = aws_iam_role.shipping_workload.arn
}

output "cert_manager_role_arn" {
  description = "ARN of the IRSA role for cert-manager; annotate the service account with it."
  value       = aws_iam_role.cert_manager_role.arn
}

output "external_dns_role_arn" {
  description = "ARN of the IRSA role for external-dns; annotate the service account with it."
  value       = aws_iam_role.external_dns_role.arn
}

