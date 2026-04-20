"""
GroceryMate ALB Health Check Lambda.
Runs every 5 minutes via EventBridge, emits a CloudWatch custom metric
that tells you how many ALB targets are healthy right now.
"""
import os
import boto3

elbv2 = boto3.client("elbv2")
cloudwatch = boto3.client("cloudwatch")

TARGET_GROUP_ARN = os.environ["TARGET_GROUP_ARN"]
PROJECT = os.environ.get("PROJECT_NAME", "grocerymate")


def lambda_handler(event, context):
    resp = elbv2.describe_target_health(TargetGroupArn=TARGET_GROUP_ARN)
    healthy = sum(1 for t in resp["TargetHealthDescriptions"]
                  if t["TargetHealth"]["State"] == "healthy")
    total = len(resp["TargetHealthDescriptions"])

    cloudwatch.put_metric_data(
        Namespace=f"{PROJECT}/ALB",
        MetricData=[{
            "MetricName": "HealthyTargetCount",
            "Value": healthy,
            "Unit": "Count",
        }, {
            "MetricName": "TotalTargetCount",
            "Value": total,
            "Unit": "Count",
        }],
    )
    return {"statusCode": 200, "healthy": healthy, "total": total}
