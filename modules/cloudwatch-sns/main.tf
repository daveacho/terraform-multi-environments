# SNS Topic for Lambda error notifications
resource "aws_sns_topic" "influxdb_backup_alarms" {
  name = "${var.projectName}-${var.environment}-InfluxdbBackupAlarms"
}

# SNS Topic Subscription 
resource "aws_sns_topic_subscription" "backup_alarms_email" {
  topic_arn = aws_sns_topic.influxdb_backup_alarms.arn
  protocol  = "email"
  endpoint  = "david.achoja@dumarey.com"
}

# SNS Topic Policy to allow CloudWatch to publish
resource "aws_sns_topic_policy" "backup_alarms_policy" {
  arn = aws_sns_topic.influxdb_backup_alarms.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Allow_Publish_Alarms"
        Effect    = "Allow"
        Principal = { Service = "cloudwatch.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.influxdb_backup_alarms.arn
      }
    ]
  })
}

# CloudWatch Alarm for MonthlyBackup Lambda errors 
resource "aws_cloudwatch_metric_alarm" "influxdb_monthly_backup_errors" {
  alarm_name          = "${var.projectName}-${var.environment}-InfluxMonthlyBackupErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when InfluxdbMonthlyBackup Lambda has errors"
  alarm_actions       = [aws_sns_topic.influxdb_backup_alarms.arn]
  dimensions = {
    FunctionName = var.influxdb_monthly_backup_lambda_function_name
  }
}


# CloudWatch Alarm for DailyBackup Lambda errors
resource "aws_cloudwatch_metric_alarm" "influxdb_daily_backup_errors" {
  alarm_name          = "${var.projectName}-${var.environment}-DailyBackupErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when IncrementalBackup Lambda has errors"
  alarm_actions       = [aws_sns_topic.influxdb_backup_alarms.arn]
  dimensions = {
    FunctionName = var.influxdb_daily_backup_lambda_function_name
  }
}
