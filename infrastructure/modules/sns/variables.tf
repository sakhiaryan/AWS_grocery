variable "project_name" {
  type = string
}
variable "alert_email" {
  type        = string
  default     = ""
  description = "Email address for health alerts. Leave empty to skip subscription."
}
variable "tags" {
  type    = map(string)
  default = {}
}
