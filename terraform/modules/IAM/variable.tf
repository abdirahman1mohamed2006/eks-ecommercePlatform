variable "cluster_name" {
  description = "Name of the EKS cluster, used to prefix role names."
  type        = string
  default     = "eks-v2-cluster"
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider (from the EKS module)."
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster (from the EKS module)."
  type        = string
}

variable "worker_namespace" {
  description = "Kubernetes namespace of the worker service account."
  type        = string
  default     = "default"
}

variable "worker_service_account_name" {
  description = "Kubernetes service account name used by the worker."
  type        = string
  default     = "worker"
}

variable "worker_sqs_queue_arns" {
  description = "ARNs of the SQS queues the worker may consume from."
  type        = list(string)
  default     = []
}

variable "order_service_namespace" {
  description = "Kubernetes namespace of the order service account."
  type        = string
  default     = "default"
}

variable "order_service_service_account_name" {
  description = "Kubernetes service account name used by the order service."
  type        = string
  default     = "order-service"
}

variable "order_service_sqs_queue_arns" {
  description = "ARNs of the SQS queues the order service may send to."
  type        = list(string)
  default     = []
}

variable "payments_namespace" {
  description = "Kubernetes namespace of the payments service account."
  type        = string
  default     = "default"
}

variable "payments_service_account_name" {
  description = "Kubernetes service account name used by the payments service."
  type        = string
  default     = "payments"
}

variable "payments_sqs_queue_arns" {
  description = "ARNs of the SQS queues the payments service may send to."
  type        = list(string)
  default     = []
}

variable "shipping_namespace" {
  description = "Kubernetes namespace of the shipping service account."
  type        = string
  default     = "default"
}

variable "shipping_service_account_name" {
  description = "Kubernetes service account name used by the shipping service."
  type        = string
  default     = "shipping"
}

variable "shipping_sqs_queue_arns" {
  description = "ARNs of the SQS queues the shipping service may send to."
  type        = list(string)
  default     = []
}

variable "route53_hosted_zone_arns" {
  description = "ARNs of the Route53 hosted zones cert-manager and external-dns may modify."
  type        = list(string)
  default     = []
}

variable "cert_manager_role_name" {
  description = "Name of the cert-manager IAM role."
  type        = string
  default     = "eks-v2-cert-manager-role"
}

variable "cert_manager_service_account_namespace" {
  description = "Kubernetes namespace of the cert-manager service account."
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_service_account_name" {
  description = "Kubernetes service account name used by cert-manager."
  type        = string
  default     = "cert-manager"
}

variable "external_dns_role_name" {
  description = "Name of the external-dns IAM role."
  type        = string
  default     = "eks-v2-external-dns-role"
}

variable "external_dns_service_account_namespace" {
  description = "Kubernetes namespace of the external-dns service account."
  type        = string
  default     = "external-dns"
}

variable "external_dns_service_account_name" {
  description = "Kubernetes service account name used by external-dns."
  type        = string
  default     = "external-dns"
}

variable "tags" {
  description = "Tags to apply to the IAM roles."
  type        = map(string)
  default = {
    Project     = "eks-v2"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}
