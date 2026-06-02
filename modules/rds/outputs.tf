output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_port" {
  value = module.rds.db_instance_port
}

output "secret_arn" {
  value = aws_secretsmanager_secret.rds_secret.arn
}