# GroceryMate Infrastructure (Terraform)

Infrastructure as Code for the GroceryMate application.
Deploys an EC2 host running the Dockerized Flask app, plus
a managed PostgreSQL RDS database, with firewall rules.

## Architecture

    Internet --> EC2 SG (22, 80, 5000)
                    |
                 EC2 Instance (t3.micro)
                 Docker + docker-compose
                 GroceryMate Flask App
                    |
                 RDS SG (5432, from EC2 SG only)
                    |
                 RDS PostgreSQL (db.t4g.micro)

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Provider config, VPC/subnet/AMI data sources |
| `variables.tf` | All configurable input variables |
| `ec2.tf` | EC2 instance + user-data bootstrap |
| `security_groups.tf` | EC2 SG and RDS SG (least privilege) |
| `rds.tf` | RDS DB subnet group and PostgreSQL instance |
| `outputs.tf` | Public IP, RDS endpoint, SSH command, app URL |
| `terraform.tfvars.example` | Template for local tfvars |
| `.gitignore` | Prevents state and secrets from being committed |

## Prerequisites

1. Terraform >= 1.5 installed
2. AWS CLI configured OR AWS SSO session active
3. An existing EC2 key pair (default: `hello-world-key`)

## Usage

```bash
cd infrastructure

# 1. Copy example tfvars and fill in a real password
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars - set db_password

# 2. Initialize Terraform (downloads AWS provider)
terraform init

# 3. Validate syntax
terraform validate

# 4. Preview changes
terraform plan

# 5. Apply (creates real AWS resources - costs may apply)
terraform apply

# When you are finished:
terraform destroy
```

## Outputs After Apply

- `ec2_public_ip` - IPv4 to SSH into
- `app_url` - browser URL for GroceryMate
- `rds_endpoint` - database host:port
- `database_url` - full PostgreSQL connection string

## Security Notes

- `terraform.tfvars` contains the DB password - gitignored by design.
- RDS security group only accepts traffic from the EC2 security group.
- EBS and RDS storage are encrypted at rest.
- SSH is open to 0.0.0.0/0 for coursework - in production restrict to
  your IP.

## Known Limitation

The Masterschool AWS sandbox has a Service Control Policy (SCP)
that denies `rds:CreateDBInstance`. Running `terraform apply`
will succeed for EC2 + security groups but fail on the RDS
resource. The code is production-quality and will work in any
AWS account where RDS is permitted.
