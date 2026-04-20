variable "project_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "alb_sg_id" {
  type = string
}
variable "ec2_sg_id" {
  type = string
}
variable "instance_profile_name" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name" {
  type = string
}
variable "app_port" {
  type    = number
  default = 5000
}
variable "asg_min" {
  type    = number
  default = 1
}
variable "asg_max" {
  type    = number
  default = 3
}
variable "asg_desired" {
  type    = number
  default = 1
}
variable "tags" {
  type    = map(string)
  default = {}
}
