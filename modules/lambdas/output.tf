output "influxdb_daily_backup_lambda_function_name" {
  value = aws_lambda_function.influxdb_daily_backup.function_name
}

output "influxdb_daily_backup_lambda_function_arn" {
  value = aws_lambda_function.influxdb_daily_backup.arn
}

output "influxdb_daily_backup_lambda" {
  value = aws_lambda_function.influxdb_daily_backup
}

output "influxdb_monthly_backup_lambda_function_name" {
  value = aws_lambda_function.influxdb_monthly_backup.function_name
}

output "influxdb_monthly_backup_lambda_function_arn" {
  value = aws_lambda_function.influxdb_monthly_backup.arn
}

output "influxdb_monthly_backup_lambda" {
  value = aws_lambda_function.influxdb_monthly_backup
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}