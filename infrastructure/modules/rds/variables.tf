variable "project_name" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "rds_sg_id" {
  type = string
}
variable "engine_version" {
  type = string
  default = "17.6"
}
variable "instance_class" {
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
variable "tags" {
  type = map(string)
  default = {}
}