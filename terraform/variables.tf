variable "aws_region" {
  description = "AWS region for the platform."
  type        = string
  default     = "eu-west-2"
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint, e.g. [\"203.0.113.7/32\"]."
  type        = list(string)
  default     = ["78.145.36.186/32"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "eks-v2-cluster"
}

variable "node_group_desired_size" {
  type    = number
  default = 2
}

variable "node_group_min_size" {
  type    = number
  default = 1
}

variable "node_group_max_size" {
  type    = number
  default = 3
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "sqs_queue_name" {
  description = "Name of the application event queue."
  type        = string
  default     = "order-events"
}

variable "route53_zone_name" {
  description = "Existing Route 53 hosted zone name."
  type        = string
  default     = "abdirahman.forum"
}

variable "kubernetes_namespace" {
  description = "Namespace containing the workload service accounts."
  type        = string
  default     = "default"
}

variable "helm_release_name" {
  description = "Helm release name used to name workload service accounts."
  type        = string
  default     = "platform"
}

variable "service_names" {
  description = "Application services that each receive a dedicated ECR repository."
  type        = set(string)
  default = [
    "api-gateway",
    "dashboard-api",
    "inventory-service",
    "notification-service",
    "order-service",
    "payment-service",
    "scheduler",
    "shipping-service",
    "worker",
  ]
}