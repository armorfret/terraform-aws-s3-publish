variable "logging_bucket" {
  description = "S3 bucket to use for bucket logging on the publish-bucket"
  type        = string
}

variable "publish_bucket" {
  description = "S3 bucket for publishing content"
  type        = string
}

variable "make_bucket" {
  description = "Set to 0 if bucket already exists to skip creation of publish-bucket"
  type        = string
  default     = "1"
}

