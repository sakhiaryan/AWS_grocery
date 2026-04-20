output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}
output "app_url" {
  description = "URL to open the GroceryMate app"
  value       = "http://${module.compute.alb_dns_name}"
}
output "rds_endpoint" {
  description = "RDS connection endpoint (host:port)"
  value       = module.rds.endpoint
}
output "s3_bucket" {
  description = "S3 bucket used for app assets"
  value       = module.s3.bucket_id
}
output "lambda_function" {
  description = "Health-check Lambda function name"
  value       = module.lambda.function_name
}
output "vpc_id" {
  description = "ID of the custom VPC"
  value       = module.vpc.vpc_id
}

output "sns_topic_arn" {
  description = "SNS topic receiving health alerts"
  value       = module.sns.topic_arn
}
