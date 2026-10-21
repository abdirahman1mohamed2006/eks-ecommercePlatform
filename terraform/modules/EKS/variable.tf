variable "private_subnet_ids" {
  description = "IDs of the private subnets for the EKS cluster and node group."
  type        = list(string)
}

variable "node_group_desired_size" {
  type    = number
  default = 2
}

variable "node_group_max_size" {
  type    = number
  default = 3
}

variable "node_group_min_size" {
  type    = number
  default = 1
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "aws_auth_roles" {
  type    = list(any)
  default = []
}

variable "aws_auth_users" {
  type    = list(any)
  default = []
}
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "eks-v2-cluster"
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role to use for the EKS cluster."
  type        = string
}

variable "node_group_role_arn" {
  description = "ARN of the IAM role to use for the EKS node group."
  type        = string
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)

  validation {
    condition     = length(var.api_allowed_cidrs) > 0 && !contains(var.api_allowed_cidrs, "0.0.0.0/0")
    error_message = "Provide at least one CIDR and do not use 0.0.0.0/0."
  }
}

variable "tags" {
  description = "Tags to apply to the EKS cluster and node group."
  type        = map(string)
  default = {
    Project     = "eks-v2"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}