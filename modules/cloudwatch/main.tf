/************************************************************
CloudWatch Logs
************************************************************/
resource "aws_cloudwatch_log_group" "sf_logs" {
  name                        = "/aws/vendedlogs/states/transcribe-glue-databrew-state-machine-Logs"
  log_group_class             = "STANDARD"
  retention_in_days           = 7
  deletion_protection_enabled = false
  skip_destroy                = false
  tags = {
    Name = "/aws/vendedlogs/states/transcribe-glue-databrew-state-machine-Logs"
  }
}