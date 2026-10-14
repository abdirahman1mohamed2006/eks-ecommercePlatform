variable "aws_region" {
	description = "AWS region where the Terraform state bucket will be created."
	type        = string
	default     = "eu-west-2"
}

variable "tf_state_bucket_name" {
	description = "Globally unique S3 bucket name for Terraform state."
	type        = string
	default     = "eks-v2-tfstate-samue-20261004"

	validation {
		condition     = length(var.tf_state_bucket_name) >= 3 && length(var.tf_state_bucket_name) <= 63 && can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.tf_state_bucket_name))
		error_message = "The state bucket name must be 3-63 characters, use lowercase letters, numbers, dots, or hyphens, and start and end with a letter or number."
	}
}

variable "tags" {
	description = "Tags applied to the Terraform state bucket."
	type        = map(string)
	default = {
		Project     = "eks-v2"
		Environment = "sandbox"
		ManagedBy   = "Terraform"
	}
}

variable "github_owner" {
	description = "GitHub user or organization that owns the deployment repository."
	type        = string
}

variable "github_repository" {
	description = "GitHub repository name allowed to assume the deploy role."
	type        = string
}

variable "github_branch" {
	description = "Branch allowed to assume the GitHub Actions deploy role."
	type        = string
	default     = "master"
}

variable "github_actions_policy_arns" {
	description = "Optional IAM policy ARNs to attach to the GitHub Actions role. Leave empty until you define least-privilege deployment permissions."
	type        = set(string)
	default     = []
}
