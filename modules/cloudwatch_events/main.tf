# 18. EventBridge rule to trigger the lambda function monthly
resource "aws_cloudwatch_event_rule" "monthly_backup" {
  name                = "${var.projectName}-${var.environment}-monthly-influxdb-backup"
  description         = "rule to trigger lambda function to backup to s3 monthly"
  schedule_expression = "cron(0 3 3 * ? *)" # 03:00 AM UTC
  #schedule_expression = "cron(0 3 1 * ? *)" # 03:00 AM UTC, 1st of each month

  tags = {
    Name = "${var.projectName}-${var.environment}-monthly-influxdb-backup"
  }
}

# 19. Add the lambda function as a target for the eventbridge
resource "aws_cloudwatch_event_target" "monthly_target" {
  rule      = aws_cloudwatch_event_rule.monthly_backup.name
  arn       = var.influxdb_monthly_backup_lambda_function_arn
  target_id = "influxdb-backup-monthly-lambda"

  depends_on = [var.influxdb_monthly_backup_lambda]
}

# 20. Give eventbridge permission to trigger lambda function
resource "aws_lambda_permission" "allow_eventbridge_monthly" {
  statement_id  = "AllowExecutionFromEventBridgeMonthly"
  action        = "lambda:InvokeFunction"
  function_name = var.influxdb_monthly_backup_lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monthly_backup.arn

  depends_on = [ aws_cloudwatch_event_rule.monthly_backup, var.influxdb_monthly_backup_lambda ]
}

# 18. EventBridge rule to trigger the lambda function daily, exporting the last 24 hours of data
resource "aws_cloudwatch_event_rule" "daily_backup" {
  name                = "${var.projectName}-${var.environment}-daily-influxdb-backup"
  description         = "rule to trigger lambda function to backup daily to s3"
  schedule_expression = "cron(10 3 * * ? *)" # Run daily 03:10 AM UTC
  
  tags = {
    Name = "${var.projectName}-${var.environment}-daily-influxdb-backup"
  }
}

# 19. Add the lambda function as a target for the eventbridge
resource "aws_cloudwatch_event_target" "daily_target" {
  rule      = aws_cloudwatch_event_rule.daily_backup.name
  arn       = var.influxdb_daily_backup_lambda_function_arn
  target_id = "influxdb-backup-daily-lambda"

  depends_on = [ var.influxdb_daily_backup_lambda ]

}

# 20. Give eventbridge permission to trigger lambda function
resource "aws_lambda_permission" "allow_eventbridge_daily" {
  statement_id  = "AllowExecutionFromEventBridgeDaily"
  action        = "lambda:InvokeFunction"
  function_name = var.influxdb_daily_backup_lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_backup.arn

  depends_on = [ aws_cloudwatch_event_rule.daily_backup, var.influxdb_daily_backup_lambda ]
}
