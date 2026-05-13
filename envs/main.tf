/************************************************************
S3
************************************************************/
module "s3" {
  source = "../modules/s3"

  account_id    = local.account_id
  region        = local.region_name
  create_object = false
}

/************************************************************
IAM
************************************************************/
module "iam" {
  source = "../modules/iam_role"
}

/************************************************************
CloudWatch
************************************************************/
module "cloudwatch" {
  source = "../modules/cloudwatch"
}

/************************************************************
Step Functions
************************************************************/
module "step_functions" {
  source = "../modules/step_functions"

  sfrole_arn = module.iam.arn_sfrole
  sflogs_arn = module.cloudwatch.arn_sflogs
}

/************************************************************
EventBridge
************************************************************/
module "eventbridge" {
  source = "../modules/eventbridge"

  transcribe_src_bucket_name = module.s3.name_transcribe_src_bucket
  sf_arn                     = module.step_functions.arn_sf
  eventbridge_rule_role_arn  = module.iam.arn_eventbridge_rule_role
}