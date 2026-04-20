# ============================================================
# SNS Topic - Email alerts for health issues
# ============================================================

resource "aws_sns_topic" "alerts" {
  name              = "${var.project_name}-alerts"
  display_name      = "GroceryMate Health Alerts"
  kms_master_key_id = "alias/aws/sns"
  tags              = merge(var.tags, { Name = "${var.project_name}-alerts" })
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
