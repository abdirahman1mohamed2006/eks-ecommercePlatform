variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used by the Kubernetes and Helm providers"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Optional kubeconfig context to use. Leave empty to use the current context"
  type        = string
  default     = ""
}

variable "helm_repository_config_path" {
  description = "Path to Helm repository config file"
  type        = string
  default     = "~/.config/helm/repositories.yaml"
}

variable "helm_repository_cache_path" {
  description = "Path to Helm repository cache directory"
  type        = string
  default     = "~/.cache/helm/repository"
}