resource "aws_secretsmanager_secret" "influxdb_backup_token_source" {
  name                    = "${var.projectName}-${var.environment}-InfluxdbSourceRootToken"
  description = "The token created for the first user in the InfluxDB setup process"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "influxdb_backup_token_version_source" {
  secret_id     = aws_secretsmanager_secret.influxdb_backup_token_source.id
  secret_string = var.source_token                               #source Root token
}

resource "aws_secretsmanager_secret" "influxdb_backup_token_destination" {
  name                    = "${var.projectName}-${var.environment}-InfluxdbDestinationRootToken"
  description = "the token created for the first user in the InfluxDB setup process"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "influxdb_backup_token_version_destination" {
  secret_id     = aws_secretsmanager_secret.influxdb_backup_token_destination.id
  secret_string = var.destination_token                           #destination Root token
}

