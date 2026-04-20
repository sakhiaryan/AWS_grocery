# Infrastructure  Terraform IaC

Modular Terraform configuration that provisions the entire GroceryMate
stack on AWS in one `terraform apply`.

## Module Tree

```
infrastructure/
 main.tf                # Root: wires all modules together
 variables.tf           # 16 configurable inputs
 outputs.tf             # ALB DNS, RDS endpoint, S3 bucket, 
 terraform.tfvars.example
 .gitignore
 modules/
     vpc/               # Custom VPC, 2 public + 2 private subnets, IGW, RT
     security/          # 3 SGs: ALB  EC2  RDS (least privilege chain)
     iam/               # EC2 instance profile (SSM + S3 read), Lambda role
     compute/           # ALB + Target Group + Launch Template + Auto Scaling Group
     rds/               # PostgreSQL 17 in private subnets, encrypted
     s3/                # Encrypted bucket with public access block
     lambda/            # Health-check Lambda + EventBridge cron (every 5 min)
```

## Architecture

```
Internet
   
   
   ALB (public subnets, 2 AZ)
   
   
   Auto Scaling Group   Launch Template (EC2 + user-data Docker bootstrap)
   
   
   RDS PostgreSQL (private subnets, multi-AZ ready)

   Lambda  EventBridge (5-min cron)
      
      
   CloudWatch (HealthyTargetCount metric)
```

See `../docs/architecture.png` for the AWS-icon diagram.

## Usage

```bash
cd infrastructure

# 1) Create tfvars from the template and fill in a real DB password
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars

# 2) Initialise providers (aws, archive, random)
terraform init

# 3) Preview changes
terraform plan

# 4) Apply (creates real resources!)
terraform apply

# 5) Destroy when done
terraform destroy
```

## Outputs After Apply

- `alb_dns_name`  public hostname of the Application Load Balancer
- `app_url`  clickable URL to open the app
- `rds_endpoint`  database `host:port`
- `s3_bucket`  bucket name for assets
- `lambda_function`  name of the health-check Lambda
- `vpc_id`  the custom VPC ID

## Known Limitation (Masterschool sandbox)

The Masterschool AWS sandbox attaches a Service Control Policy that
denies `rds:CreateDBInstance`. `terraform apply` succeeds for everything
except the RDS resource. The code is production-quality and will create
RDS in any AWS account where the service is permitted.
