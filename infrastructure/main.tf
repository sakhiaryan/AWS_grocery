# ==========================================================
# GroceryMate Infrastructure as Code
# Author: Aryan Sakhi-Alhosseini
# Week 6 - Masterschool Data Engineering Track
# ==========================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "GroceryMate"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = "sakhiaryan"
    }
  }
}

# Read the existing default VPC (we use AWS-default VPC)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Amazon Linux 2023 AMI (we query it instead of hardcoding)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
