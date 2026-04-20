"""
GroceryMate AWS Architecture  rendered with official AWS Architecture Icons.

This script uses the `diagrams` Python library, which embeds the exact same
PNG icons that AWS publishes on https://aws.amazon.com/architecture/icons/.

Layout mirrors a classic AWS draw.io architecture diagram:
  - Internet (globe) at the top
  - VPC box with Public + Private subnet rows
  - ALB in public, Auto Scaling Group with 2 EC2 (Docker) in public
  - RDS in private
  - S3, Lambda + EventBridge, CloudWatch, IAM outside the VPC

Run:  python3.11 docs/architecture.py
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, Lambda, EC2AutoScaling
from diagrams.aws.database import RDS
from diagrams.aws.network import ALB, Route53, InternetGateway
from diagrams.aws.storage import S3
from diagrams.aws.security import IdentityAndAccessManagementIam as IAM
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import Eventbridge
from diagrams.aws.general import InternetAlt1
from diagrams.onprem.container import Docker

GRAPH = {
    "fontsize": "22",
    "fontname": "Arial",
    "bgcolor": "transparent",
    "pad": "0.8",
    "splines": "spline",
    "nodesep": "1.0",
    "ranksep": "1.2",
    "labelloc": "t",
}
NODE = {"fontsize": "14", "fontname": "Arial"}
EDGE = {"fontsize": "12", "fontname": "Arial"}

with Diagram(
    "GroceryMate  AWS Architecture",
    filename="docs/architecture",
    outformat=["png","pdf","svg"],
    show=False,
    direction="TB",
    graph_attr=GRAPH,
    node_attr=NODE,
    edge_attr=EDGE,
):
    internet = InternetAlt1("Internet")
    route53 = Route53("Route 53\n(optional DNS)")

    with Cluster("Amazon Cloud (AWS)  eu-north-1", graph_attr={"bgcolor": "#F2F5F7", "style": "rounded", "penwidth": "2"}):

        with Cluster("Virtual Private Cloud (VPC)  10.0.0.0/16", graph_attr={"bgcolor": "#E6F2FA", "style": "rounded", "penwidth": "2"}):

            with Cluster("Public Subnets (AZ a + b)", graph_attr={"bgcolor": "#EAF5E9", "style": "rounded", "penwidth": "2"}):
                igw = InternetGateway("Internet\nGateway")
                alb = ALB("Application\nLoad Balancer")
                with Cluster("Auto Scaling Group", graph_attr={"bgcolor": "#FFF3E0", "style": "dashed,rounded", "penwidth": "2"}):
                    ec2_a = EC2("EC2 Instance\nAZ-a")
                    ec2_b = EC2("EC2 Instance\nAZ-b")
                    docker_a = Docker("docker")
                    docker_b = Docker("docker")
                    ec2_a - Edge(style="invis") - docker_a
                    ec2_b - Edge(style="invis") - docker_b

            with Cluster("Private Subnets (AZ a + b)", graph_attr={"bgcolor": "#FCE8F3", "style": "rounded", "penwidth": "2"}):
                rds = RDS("RDS PostgreSQL\ndb.t4g.micro")

        s3 = S3("S3 Bucket\nAssets + Logs")
        lam = Lambda("Lambda\nHealth Check")
        eb = Eventbridge("EventBridge\n(5-min cron)")
        cw = Cloudwatch("CloudWatch\nMetrics + Alarms")
        iam = IAM("IAM Roles\n+ Policies")

    # Traffic flow
    internet >> Edge(label="HTTP/HTTPS", color="darkgreen", penwidth="2") >> route53
    internet >> Edge(color="darkgreen", penwidth="2") >> alb
    route53 >> alb
    alb >> Edge(label="forward :5000", color="darkgreen") >> [ec2_a, ec2_b]
    [ec2_a, ec2_b] >> Edge(label="SQL :5432", color="crimson") >> rds

    # Ops
    eb >> Edge(label="trigger") >> lam
    lam >> Edge(label="describe-target-health", style="dashed") >> alb
    lam >> Edge(label="put-metric-data", style="dashed") >> cw
    [ec2_a, ec2_b] >> Edge(style="dashed") >> s3
    ec2_a >> Edge(style="dotted") >> cw
    rds >> Edge(style="dotted") >> cw
