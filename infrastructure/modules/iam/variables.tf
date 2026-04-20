variable "project_name" {
  type = string
}
variable "s3_bucket_arn" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "sns_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN that Lambda may publish to. Empty = no permission."
}
