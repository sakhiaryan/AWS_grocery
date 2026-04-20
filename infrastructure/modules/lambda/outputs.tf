output "function_arn" { value = aws_lambda_function.health_check.arn }
output "function_name" { value = aws_lambda_function.health_check.function_name }
output "schedule_rule" { value = aws_cloudwatch_event_rule.every_5min.name }
