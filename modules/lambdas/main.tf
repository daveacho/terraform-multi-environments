#creating lambda layer
resource "aws_lambda_layer_version" "influxdb_cli_layer" {
  filename   = "${path.module}/influxdb-cli-layer.zip"
  layer_name = "${var.projectName}-${var.environment}-influxdb-cli"

  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64"]
}

# 8. IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.projectName}-${var.environment}-lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

}

#policy for lambda to access S3 and Cloudwatch
resource "aws_iam_role_policy" "lambda_backup_s3_policy" {
  name = "${var.projectName}-${var.environment}-influxdb-lambda-backup-s3-policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:ListBucket", "s3:GetObject"]
        Resource = [
          "${var.s3_bucket_arn}",
          "${var.s3_bucket_arn}/*" 
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [
          "${var.secret_manager_source_arn}",
          "${var.secret_manager_destination_arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda Function for monthly backup  to s3
resource "aws_lambda_function" "influxdb_monthly_backup" {
  filename         = "${path.module}/influxdb_monthly_backup.zip"
  function_name    = "${var.projectName}-${var.environment}-influxdb-monthly-backup"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "influxdb_monthly_backup.lambda_handler"
  runtime          = "python3.13"
  timeout          = 900
  memory_size      = 1024
  source_code_hash = filebase64sha256("${path.module}/influxdb_monthly_backup.zip")
  layers           = [aws_lambda_layer_version.influxdb_cli_layer.arn]

  ephemeral_storage {
    size = 8192 # Increase to 8 GB (adjust as needed)
  }

  environment {
    variables = {
      INFLUXDB_URL    = var.influxdb_url
      INFLUXDB_TOKEN  = var.secret_manager_source_arn
      S3_BUCKET       = var.s3_bucket_name
    }
  }

  tags = {
    Name = "${var.projectName}-${var.environment}-influxdb-monthly-backup"
  }

}

# Lambda Function for daily backup to s3
resource "aws_lambda_function" "influxdb_daily_backup" {
  filename         = "${path.module}/influxdb_daily_backup.zip"
  function_name    = "${var.projectName}-${var.environment}-influxdb-daily-backup"
  role             =  aws_iam_role.lambda_execution_role.arn
  handler          = "influxdb_daily_backup.lambda_handler"
  runtime          = "python3.13"
  timeout          = 900
  memory_size      = 512                                                
  source_code_hash = filebase64sha256("${path.module}/influxdb_daily_backup.zip")
  layers           = [aws_lambda_layer_version.influxdb_cli_layer.arn]

  ephemeral_storage {
    size = 2048 # Increase to 2 GB (adjust as needed)
  }

  environment {
    variables = {
      INFLUXDB_URL    = var.influxdb_url
      INFLUXDB_ORG    = var.organisation_name
      INFLUXDB_TOKEN  = var.secret_manager_source_arn
      S3_BUCKET       = var.s3_bucket_name
      INFLUXDB_BUCKET_CONFIG = jsonencode([
        {
          "name" : "asset_bucket",
          "measurements" : ["cloud_telemetry", "telemetry"]
        },
        {
          "name" : "cloud_bucket",
          "measurements" : ["savings"]
        }
      ])
    }
  }

  tags = {
    Name = "${var.projectName}-${var.environment}-influxdb-daily-backup"
  }

}

# Lambda Function to restore monthly backup to a new influxdb instance
resource "aws_lambda_function" "influxdb_monthly_restore" {
  filename         = "${path.module}/influxdb_monthly_restore.zip"
  function_name    = "${var.projectName}-${var.environment}-influxdb-monthly-restore"
  role             =  aws_iam_role.lambda_execution_role.arn
  handler          = "influxdb_monthly_restore.lambda_handler"
  runtime          = "python3.13"
  timeout          = 900
  memory_size      = 1024
  source_code_hash = filebase64sha256("${path.module}/influxdb_monthly_restore.zip")
  layers           = [aws_lambda_layer_version.influxdb_cli_layer.arn]

  ephemeral_storage {
    size = 8192
  }

  environment {
    variables = {
      INFLUXDB_URL    = var.destination_influxdb_url
      INFLUXDB_ORG    = var.organisation_name                                          #source organisation
      INFLUXDB_NEW_ORG = var.destination_org                                            #target organisation
      INFLUXDB_TOKEN  = var.secret_manager_destination_arn
      S3_BUCKET       = var.s3_bucket_name
    }
  }

  tags = {
    Name = "${var.projectName}-${var.environment}-influxdb-monthly-restore"
  }

}

# Lambda Function to restore daily backup to influxdb
resource "aws_lambda_function" "influxdb_daily_restore" {
  filename         = "${path.module}/influxdb_daily_restore.zip"
  function_name    = "${var.projectName}-${var.environment}-influxdb-daily-restore"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "influxdb_daily_restore.lambda_handler"
  runtime          = "python3.9"
  timeout          = 600
  memory_size      = 2048                        # very memory intensive process
  source_code_hash = filebase64sha256("${path.module}/influxdb_daily_restore.zip")
  layers           = [aws_lambda_layer_version.influxdb_cli_layer.arn]

  ephemeral_storage {
    size = 8192
  }

  environment {
    variables = {
      INFLUXDB_URL   = var.destination_influxdb_url
      INFLUXDB_ORG   = var.destination_org                #target organisation                                                                 
      INFLUXDB_TOKEN = var.secret_manager_destination_arn
      S3_BUCKET      = var.s3_bucket_name
    }
  }

  tags = {
    Name = "${var.projectName}-${var.environment}-influxdb-daily-restore"
  }

}


