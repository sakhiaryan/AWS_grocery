variable "aws_region" {
  type = string
  default = "eu-north-1"
}
variable "environment" {
  type = string
  default = "dev"
}
variable "project_name" {
  type = string
  default = "grocerymate"
}
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "ec2_instance_type" {
  type = string
  default = "t3.micro"
}
variable "ec2_key_name" {
  type = string
  default = "hello-world-key"
}
variable "app_port" {
  type = number
  default = 5000
}
variable "asg_min" {
  type = number
  default = 1
}
variable "asg_max" {
  type = number
  default = 3
}
variable "asg_desired" {
  type = number
  default = 1
}
variable "db_instance_class" {
  type = string
  default = "db.t4g.micro"
}
variable "db_name" {
  type = string
  default = "grocerymate_db"
}
variable "db_username" {
  type = string
  default = "postgres"
}
variable "db_password" {
  type = string
  sensitive = true
}
variable "allowed_ssh_cidr" {
  type = string
  default = "0.0.0.0/0"
}
variable "s3_bucket_name" {
  type = string
  default = ""
  description = "Leave empty for auto-generated unique name"
}
variable "alert_email" {
  type        = string
  default     = ""
  description = "Email address that will receive health alerts via SNS. Leave empty to disable."
}
