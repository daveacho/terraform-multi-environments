module "lambdas" {
  source                         = "../../modules/lambdas"
  projectName                    = var.projectName
  environment                    = var.environment
  influxdb_url                   = var.influxdb_url
  organisation_name              = var.organisation
  secret_manager_destination_arn = module.secret_manager.secret_manager_destination_arn
  secret_manager_source_arn      = module.secret_manager.secret_manager_source_arn
  s3_bucket_name                 = module.s3.s3_bucket_name
  s3_bucket_arn                  = module.s3.s3_bucket_arn
  destination_org                = var.destination_org
  destination_token              = var.destination_token
  destination_influxdb_url       = var.destination_influxdb_url

}

module "cloudwatch_event" {
  source                                       = "../../modules/cloudwatch_events"
  projectName                                  = var.projectName
  environment                                  = var.environment
  influxdb_monthly_backup_lambda_function_arn  = module.lambdas.influxdb_monthly_backup_lambda_function_arn
  influxdb_monthly_backup_lambda_function_name = module.lambdas.influxdb_monthly_backup_lambda_function_name
  influxdb_monthly_backup_lambda               = module.lambdas.influxdb_monthly_backup_lambda
  influxdb_daily_backup_lambda_function_arn    = module.lambdas.influxdb_daily_backup_lambda_function_arn
  influxdb_daily_backup_lambda_function_name   = module.lambdas.influxdb_daily_backup_lambda_function_name
  influxdb_daily_backup_lambda                 = module.lambdas.influxdb_daily_backup_lambda

}


module "cloudwatch-sns" {
  source                                       = "../../modules/cloudwatch-sns"
  projectName                                  = var.projectName
  environment                                  = var.environment
  influxdb_daily_backup_lambda_function_name   = module.lambdas.influxdb_daily_backup_lambda_function_name
  influxdb_monthly_backup_lambda_function_name = module.lambdas.influxdb_monthly_backup_lambda_function_name

}


module "s3" {
  source                    = "../../modules/s3"
  projectName               = var.projectName
  environment               = var.environment
  lambda_execution_role_arn = module.lambdas.lambda_execution_role_arn
}

module "secret_manager" {
  source            = "../../modules/secret_manager"
  projectName       = var.projectName
  environment       = var.environment
  source_token      = var.source_token
  destination_token = var.destination_token

}

