"""
GroceryMate Health-Check Lambda.

Triggered by EventBridge every 5 minutes, this function:
  1. Checks every EC2 instance in the region via `describe_instance_status`
     (pattern from "Chapter 08: Setting up EC2 health check alerts using
     Lambda, CloudWatch, and SNS").
  2. Checks the ALB target group health via `describe_target_health`.
  3. Publishes custom CloudWatch metrics for dashboards/alarms.
  4. Publishes an SNS message (which is delivered to the subscribed
     email address) if anything is unhealthy.

Env vars (set by Terraform):
  TARGET_GROUP_ARN  - ALB target group to monitor
  SNS_TOPIC_ARN     - SNS topic for email alerts (empty = disabled)
  PROJECT_NAME      - prefix for CloudWatch namespace and alert subjects
"""
import os
import boto3

ec2 = boto3.client("ec2")
elbv2 = boto3.client("elbv2")
cloudwatch = boto3.client("cloudwatch")
sns = boto3.client("sns")

TARGET_GROUP_ARN = os.environ.get("TARGET_GROUP_ARN", "")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN", "")
PROJECT = os.environ.get("PROJECT_NAME", "grocerymate")


def check_ec2_instances():
    """Return (unhealthy, total, issue_lines)."""
    total, unhealthy, lines = 0, 0, []
    resp = ec2.describe_instances()
    for res in resp.get("Reservations", []):
        for inst in res.get("Instances", []):
            iid = inst["InstanceId"]
            state = inst["State"]["Name"]
            total += 1

            if state == "terminated":
                continue  # ignore fully terminated

            status = ec2.describe_instance_status(InstanceIds=[iid])
            if not status.get("InstanceStatuses"):
                if state != "running":
                    unhealthy += 1
                    lines.append(f"- {iid}: state={state}")
                continue

            s = status["InstanceStatuses"][0]
            inst_check = s["InstanceStatus"]["Status"]
            sys_check = s["SystemStatus"]["Status"]

            if state != "running" or inst_check != "ok" or sys_check != "ok":
                unhealthy += 1
                lines.append(
                    f"- {iid}: state={state} "
                    f"instance_check={inst_check} system_check={sys_check}"
                )
    return unhealthy, total, lines


def check_alb_targets():
    """Return (unhealthy, total)."""
    if not TARGET_GROUP_ARN:
        return 0, 0
    resp = elbv2.describe_target_health(TargetGroupArn=TARGET_GROUP_ARN)
    total = len(resp["TargetHealthDescriptions"])
    healthy = sum(
        1 for t in resp["TargetHealthDescriptions"]
        if t["TargetHealth"]["State"] == "healthy"
    )
    return total - healthy, total


def publish_metrics(ec2_bad, ec2_total, alb_bad, alb_total):
    cloudwatch.put_metric_data(
        Namespace=f"{PROJECT}/Health",
        MetricData=[
            {"MetricName": "EC2Unhealthy", "Value": ec2_bad,   "Unit": "Count"},
            {"MetricName": "EC2Total",     "Value": ec2_total, "Unit": "Count"},
            {"MetricName": "ALBUnhealthy", "Value": alb_bad,   "Unit": "Count"},
            {"MetricName": "ALBTargets",   "Value": alb_total, "Unit": "Count"},
        ],
    )


def publish_alert(ec2_bad, ec2_total, alb_bad, alb_total, ec2_lines):
    if not SNS_TOPIC_ARN:
        return
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"[{PROJECT}] Health alert  {ec2_bad + alb_bad} issue(s)",
        Message=(
            f"GroceryMate health check found problems:\n\n"
            f"  EC2 instances: {ec2_bad}/{ec2_total} unhealthy\n"
            f"  ALB targets:   {alb_bad}/{alb_total} unhealthy\n\n"
            f"Details:\n" + ("\n".join(ec2_lines) if ec2_lines else "  (ALB targets only)")
            + "\n\n"
            f"Investigate in the AWS Console.\n"
        ),
    )


def lambda_handler(event, context):
    ec2_bad, ec2_total, ec2_lines = check_ec2_instances()
    alb_bad, alb_total = check_alb_targets()

    publish_metrics(ec2_bad, ec2_total, alb_bad, alb_total)

    if ec2_bad > 0 or alb_bad > 0:
        publish_alert(ec2_bad, ec2_total, alb_bad, alb_total, ec2_lines)

    return {
        "statusCode": 200,
        "ec2": {"unhealthy": ec2_bad, "total": ec2_total},
        "alb": {"unhealthy": alb_bad, "total": alb_total},
    }
