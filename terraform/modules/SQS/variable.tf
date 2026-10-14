variable "queue_name" {
  description = "Name of the main queue; the DLQ is named with a -dlq suffix."
  type        = string
  default     = "eks-v2-queue"
}

variable "delay_seconds" {
  description = "Delay before new messages become visible."
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size in bytes."
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "How long the main queue retains messages."
  type        = number
  default     = 86400
}

variable "dlq_message_retention_seconds" {
  description = "How long the DLQ retains messages; keep it longer than the main queue."
  type        = number
  default     = 1209600
}

variable "receive_wait_time_seconds" {
  description = "Long-polling wait time for receive calls."
  type        = number
  default     = 10
}

variable "visibility_timeout_seconds" {
  description = "Time a received message stays hidden from other consumers."
  type        = number
  default     = 30
}

variable "max_receive_count" {
  description = "Receive attempts before a message moves to the DLQ."
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags to apply to the queues."
  type        = map(string)
  default = {
    Project     = "eks-v2"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}
