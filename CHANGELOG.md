# Changelog

All notable changes to this project are documented here.
The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

- Polish the production architecture diagram with draw.io AWS icons.
- Add GitHub Actions workflow for automated `terraform plan` on PRs.

---

## [Week 8]  2026-04-20

### Added
- Comprehensive `README.md` with Mermaid architecture diagram, badges, tech stack, cost breakdown.
- `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE` (MIT).
- GitHub Actions workflow (`terraform-validate.yml`) that lints Terraform on every push.
- `docs/screenshots/` folder for visual documentation.

### Changed
- Repository restructured for professional open-source presentation.

---

## [Week 7]  S3 Integration

### Added
- S3 bucket `grocerymate-assets-sakhiaryan-2026` for storing application assets and logs.
- CLI-driven upload of project metadata (`README.txt`, `app-info.json`, `app-logs.txt`, `infrastructure.txt`).

---

## [Week 6]  Infrastructure as Code (Terraform)

### Added
- `infrastructure/` folder with full Terraform IaC setup:
  - `main.tf`, `variables.tf`, `outputs.tf`, `ec2.tf`, `security_groups.tf`, `rds.tf`
  - `terraform.tfvars.example`, `.gitignore`, `README.md`
- `terraform init` + `terraform validate` verified green.
- Declarative resources: EC2 t3.micro, two security groups (least privilege), RDS PostgreSQL subnet group and instance.

### Notes
- RDS creation is blocked by a Masterschool SCP (`rds:CreateDBInstance` denied), but the Terraform code is production-quality and validates successfully.

---

## [Week 5]  Database Layer

### Added
- PostgreSQL 15 container managed by Docker Compose (RDS workaround because of SCP deny).
- `docker-compose up` now starts `grocery-app` (Flask) and `grocery-db` (Postgres) together.

---

## [Week 4]  Containerisation

### Added
- `backend/Dockerfile`  multi-stage-friendly Python 3.11-slim image.
- `backend/.dockerignore`  excludes `venv/`, `__pycache__`, `.env`.
- Root-level `docker-compose.yml`  orchestrates app + DB, health-checked.

### Changed
- Replaced ad-hoc `python run.py` deployment on EC2 with a reproducible Docker image.

### Fixed
- macOS port-5000 conflict (AirPlay) documented in `README.md` Quick Start.

---

## [Week 3]  EC2 + Application Load Balancer

### Added
- EC2 `t3.micro` instance in `eu-north-1b` (hello-world-server, `i-0722f96943976acd1`).
- Security Group (`launch-wizard-1`) with SSH (22), HTTP (80), custom TCP (5000).
- Application Load Balancer `grocery-alb` across two AZs.
- Target Group `grocery-tg` (HTTP :5000) with healthy EC2 target.
- Manually deployed GroceryMate Flask app via `python run.py` with local PostgreSQL.

---

## [Week 2]  "Hello World" on EC2

### Added
- First EC2 instance launched.
- SSH connectivity verified via EC2 Instance Connect.
- Amazon Linux 2023 AMI, free-tier eligible.

---

## [Week 1]  GitHub Fork

### Added
- Forked upstream `AlejandroRomanIbanez/AWS_grocery` to `sakhiaryan/AWS_grocery`.
- Verified local clone works with `version2` branch.
