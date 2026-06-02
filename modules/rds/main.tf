terraform {
  backend "s3" {}
}

resource "aws_security_group" "rds_sg" {

  name = "rds-security-group"

  description = "Security group for RDS"

  vpc_id = var.vpc_id

  ingress {

    from_port = 3306
    to_port   = 3306

    protocol = "tcp"

    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Secrets Manager Secret
resource "aws_secretsmanager_secret" "rds_secret" {

  name = "devops-rds-secret"
}

# Secret Values
resource "aws_secretsmanager_secret_version" "rds_secret_value" {

  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({

    username = "admin"

    password = "YourStrongPassword123!"
  })
}

# Decode Secret JSON
locals {

  db_credentials = jsondecode(
    aws_secretsmanager_secret_version.rds_secret_value.secret_string
  )
}

module "rds" {

  source = "terraform-aws-modules/rds/aws"

  identifier = "devops-mariadb"

  engine = "mariadb"

  engine_version = "10.11"

  family = "mariadb10.11"

  major_engine_version = "10.11"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  max_allocated_storage = 20

  db_name = "employee_db"

  username = local.db_credentials.username

  port = 3306

  publicly_accessible = false

  skip_final_snapshot = true

  deletion_protection = false

  multi_az = false

  backup_retention_period = 0

  monitoring_interval = 0

  performance_insights_enabled = false

  storage_encrypted = false

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  subnet_ids = [
    var.private_subnet_1,
    var.private_subnet_2
  ]
}