/************************************************************
Function
************************************************************/
resource "aws_lambda_function" "converter" {
  function_name    = "transcribe-json-to-csv"
  description      = "Transcribe Json File To CSV File"
  runtime          = "python3.14"
  architectures    = ["x86_64"]
  filename         = data.archive_file.converter.output_path
  source_code_hash = data.archive_file.converter.output_base64sha256
  handler          = "transcribe_json_to_csv.lambda_handler"
  timeout          = 900
  memory_size      = 128
  ephemeral_storage {
    size = 512
  }
  role = var.lambda_role_arn
  logging_config {
    log_group             = var.converter_lambda_loggroup_name
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
  }
  tracing_config {
    mode = "PassThrough"
  }
  skip_destroy = false
  tags = {
    Name = "transcribe-json-to-csv"
  }
}