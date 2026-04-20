# ============================================================
# RDS Module - PostgreSQL in private subnets
# ============================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.project_name}-db-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier                = "${var.project_name}-rds"
  engine                    = "postgres"
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  allocated_storage         = 20
  storage_type              = "gp3"
  storage_encrypted         = true
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [var.rds_sg_id]
  publicly_accessible       = false
  backup_retention_period   = 7
  skip_final_snapshot       = true
  delete_automated_backups  = true
  deletion_protection       = false
  auto_minor_version_upgrade = true
  multi_az                  = false
  tags                      = merge(var.tags, { Name = "${var.project_name}-rds" })
}
