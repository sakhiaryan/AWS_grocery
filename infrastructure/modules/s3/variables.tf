variable "bucket_name" {
  type = string
}
variable "versioning" {
  type = bool
  default = false
}
variable "force_destroy" {
  type = bool
  default = true
}
variable "tags" {
  type = map(string)
  default = {}
}