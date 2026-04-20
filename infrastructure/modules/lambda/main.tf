# ============================================================
# Lambda + EventBridge - periodic ALB health check
# ============================================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "health_check" {
  function_name    = "${var.project_name}-health-check"
  role             = var.role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      TARGET_GROUP_ARN = var.target_group_arn
      PROJECT_NAME     = var.project_name
      SNS_TOPIC_ARN    = var.sns_topic_arn
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "every_5min" {
  name                = "${var.project_name}-health-check-schedule"
  description         = "Trigger ALB health-check Lambda every 5 minutes"
  schedule_expression = var.schedule
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_5min.name
  target_id = "lambda"
  arn       = aws_lambda_function.health_check.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_5min.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.health_check.function_name}"
  retention_in_days = 14
  tags              = var.tags
}
