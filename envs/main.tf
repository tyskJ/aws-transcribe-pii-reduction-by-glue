/************************************************************
S3
************************************************************/
module "s3" {
  source = "../modules/s3"

  account_id    = local.account_id
  region        = local.region_name
  create_object = false
}