/************************************************************
CloudWatch Logs
************************************************************/
### Step Functions StateMachine
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

### Lambda
resource "aws_cloudwatch_log_group" "lambda_converter_logs" {
  name                        = "/aws/lambda/transcribe-json-to-csv"
  log_group_class             = "STANDARD"
  retention_in_days           = 7
  deletion_protection_enabled = false
  skip_destroy                = false
  tags = {
    Name = "/aws/lambda/transcribe-json-to-csv"
  }
}

resource "aws_cloudwatch_log_group" "lambda_createwav_logs" {
  name                        = "/aws/lambda/create-wav"
  log_group_class             = "STANDARD"
  retention_in_days           = 7
  deletion_protection_enabled = false
  skip_destroy                = false
  tags = {
    Name = "/aws/lambda/create-wav"
  }
}