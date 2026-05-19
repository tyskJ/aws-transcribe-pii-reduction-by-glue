/************************************************************
S3
************************************************************/
module "s3" {
  source = "../modules/s3"

  account_id = local.account_id
  region     = local.region_name
}

/************************************************************
IAM
************************************************************/
module "iam" {
  source = "../modules/iam_role"

  partition                 = local.partition_name
  region                    = local.region_name
  account_id                = local.account_id
  transcribe_src_bucket_arn = module.s3.arn_transcribe_src_bucket
  transcribe_dst_bucket_arn = module.s3.arn_transcribe_dst_bucket
  glue_src_bucket_arn       = module.s3.arn_glue_src_bucket
}

/************************************************************
CloudWatch
************************************************************/
module "cloudwatch" {
  source = "../modules/cloudwatch"
}

/************************************************************
Lambda
************************************************************/
module "lambda" {
  source = "../modules/lambda"

  lambda_role_arn                     = module.iam.arn_lambda
  json_converter_lambda_loggroup_name = module.cloudwatch.name_json_converter_lambda_loggroup
  createwav_lambda_loggroup_name      = module.cloudwatch.name_createwav_lambda_loggroup
}

/************************************************************
Step Functions
************************************************************/
module "step_functions" {
  source = "../modules/step_functions"

  sfrole_arn                = module.iam.arn_sfrole
  sflogs_arn                = module.cloudwatch.arn_sf_loggroup
  json_converter_lambda_arn = module.lambda.arn_json_converter_lambda
}

/************************************************************
EventBridge
************************************************************/
module "eventbridge" {
  source = "../modules/eventbridge"

  transcribe_src_bucket_name = module.s3.name_transcribe_src_bucket
  transcribe_dst_bucket_name = module.s3.name_transcribe_dst_bucket
  glue_src_bucket_name       = module.s3.name_glue_src_bucket
  sf_arn                     = module.step_functions.arn_sf
  eventbridge_rule_role_arn  = module.iam.arn_eventbridge_rule_role
}