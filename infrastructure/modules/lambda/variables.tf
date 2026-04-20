variable "project_name" {
  type = string
}
variable "role_arn" {
  type = string
}
variable "target_group_arn" {
  type = string
}
variable "schedule" {
  type = string
  default = "rate(5 minutes)"
}
variable "tags" {
  type = map(string)
  default = {}
}