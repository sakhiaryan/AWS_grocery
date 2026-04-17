# ==========================================================
# Outputs - values shown after `terraform apply`
# ==========================================================

output "ec2_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "ec2_ssh_command" {
  description = "Copy-paste this to SSH into the instance"
  value       = "ssh -i ${var.ec2_key_name}.pem ec2-user@${aws_instance.app_server.public_ip}"
}

output "app_url" {
  description = "URL to open the GroceryMate app in a browser"
  value       = "http://${aws_instance.app_server.public_ip}:${var.app_port}"
}

output "rds_endpoint" {
  description = "RDS connection endpoint (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "RDS hostname only (without port)"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.postgres.port
}

output "database_url" {
  description = "PostgreSQL connection string (password masked)"
  value       = "postgresql://${var.db_username}:***@${aws_db_instance.postgres.endpoint}/${var.db_name}"
  sensitive   = false
}
