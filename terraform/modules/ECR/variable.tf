variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
  default     = "eks-v2"
}

variable "image_tag_mutability" {
  description = "Tag mutability: MUTABLE or IMMUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Scan images for vulnerabilities when pushed."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the repository."
  type        = map(string)
  default = {
    Project     = "eks-v2"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}
