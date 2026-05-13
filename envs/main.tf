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
  source = "../modules/event_bridge"
}