output "topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "ARN of the alert SNS topic"
}
output "topic_name" {
  value = aws_sns_topic.alerts.name
}
