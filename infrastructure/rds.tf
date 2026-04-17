# ==========================================================
# RDS PostgreSQL - managed relational database service
# Free Tier: 750 h/month db.t3.micro or db.t4g.micro
# ==========================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.project_name}-rds"
  engine            = "postgres"
  engine_version    = "17.6"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Backups - 7 day retention, no final snapshot for schoolwork
  backup_retention_period  = 7
  skip_final_snapshot      = true
  delete_automated_backups = true
  deletion_protection      = false

  # Minor version upgrades automatically, but not major
  auto_minor_version_upgrade = true

  # Free Tier: Single-AZ only
  multi_az = false

  tags = {
    Name = "${var.project_name}-rds"
    Role = "database"
  }
}
