output "secret_manager_source_arn" {
  value = aws_secretsmanager_secret.influxdb_backup_token_source.arn
}

output "secret_manager_destination_arn" {
  value = aws_secretsmanager_secret.influxdb_backup_token_destination.arn
}