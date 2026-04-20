"""
GroceryMate AWS Architecture Diagram Generator
Uses the `diagrams` Python library with real AWS Architecture Icons.
Run:  python3.11 docs/architecture.py
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, ElasticContainerService
from diagrams.aws.database import RDS
from diagrams.aws.network import ALB, VPC, InternetGateway, Route53, PublicSubnet, PrivateSubnet
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import Eventbridge
from diagrams.aws.compute import Lambda
from diagrams.onprem.client import Users
from diagrams.onprem.container import Docker
from diagrams.onprem.database import PostgreSQL

GRAPH_ATTR = {
    "fontsize": "18",
    "bgcolor": "transparent",
    "pad": "0.6",
    "splines": "spline",
    "nodesep": "0.7",
    "ranksep": "0.9",
}

with Diagram(
    "GroceryMate on AWS",
    filename="docs/architecture",
    outformat="png",
    show=False,
    graph_attr=GRAPH_ATTR,
    direction="TB",
):
    users = Users("End Users")
    dns = Route53("Route 53\nDNS (optional)")

    with Cluster("AWS Cloud  eu-north-1 (Stockholm)"):
        with Cluster("Default VPC"):
            igw = InternetGateway("Internet\nGateway")

            with Cluster("Public Subnets (AZ a + b)"):
                alb = ALB("Application\nLoad Balancer")
                with Cluster("EC2 t3.micro + Docker"):
                    ec2 = EC2("grocery-app\nFlask :5000")
                    db_local = PostgreSQL("grocery-db\nPostgres 15")

            with Cluster("Private Subnets"):
                rds = RDS("RDS PostgreSQL\ndb.t4g.micro")

        s3 = S3("S3 Bucket\nAssets + Logs")
        lam = Lambda("Health Check\nLambda")
        eb = Eventbridge("EventBridge\nCron rule")
        cw = Cloudwatch("CloudWatch\nMetrics + Alarms")
        iam = IAM("IAM Roles\n+ Policies")

    users >> Edge(label="HTTPS") >> dns >> alb
    users >> Edge(label="direct") >> alb
    alb >> Edge(label="HTTP :5000", color="darkgreen") >> ec2
    ec2 >> db_local
    ec2 >> Edge(label="optional", style="dashed", color="blue") >> rds
    ec2 >> Edge(label="PUT / GET", style="dashed") >> s3

    eb >> lam
    lam >> Edge(label="health probe", style="dashed") >> alb
    lam >> cw
    ec2 >> cw
    rds >> cw
