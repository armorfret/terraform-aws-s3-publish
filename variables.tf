variable "logging_bucket" {
  description = "S3 bucket to use for bucket logging on the publish-bucket"
  type        = string
}

variable "publish_bucket" {
  description = "S3 bucket for publishing content"
  type        = string
}

variable "kms_key_arn" {
  description = "Use custom KMS key for vault bucket"
  type        = string
  default     = ""
}

variable "use_kms" {
  description = "Use KMS instead of AES SSE"
  type        = bool
  default     = false
}

variable "make_bucket" {
  description = "Create publish-bucket (set to false if bucket has been created external to module)"
  type        = bool
  default     = true
}

