# ==========================================================
# Input Variables
# Configure in terraform.tfvars (gitignored, see example)
# ==========================================================

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Deployment environment (dev / staging / prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name prefix used in resource names"
  type        = string
  default     = "grocerymate"
}

variable "ec2_instance_type" {
  description = "EC2 instance type (Free Tier eligible: t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
  default     = "hello-world-key"
}

variable "app_port" {
  description = "TCP port the Flask app listens on"
  type        = number
  default     = 5000
}

variable "db_instance_class" {
  description = "RDS DB instance class (Free Tier: db.t3.micro or db.t4g.micro)"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Initial database name in RDS"
  type        = string
  default     = "grocerymate_db"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for RDS (set via tfvars or env var)"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (default: anywhere for schoolwork)"
  type        = string
  default     = "0.0.0.0/0"
}
