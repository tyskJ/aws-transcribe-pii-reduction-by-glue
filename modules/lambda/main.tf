/************************************************************
Function
************************************************************/
resource "aws_lambda_function" "json_converter" {
  function_name    = reverse(split("/", var.json_converter_lambda_loggroup_name))[0]
  description      = "Transcribe Json File Converter"
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
    log_group             = var.json_converter_lambda_loggroup_name
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
  }
  tracing_config {
    mode = "PassThrough"
  }
  skip_destroy = false
  tags = {
    Name = reverse(split("/", var.json_converter_lambda_loggroup_name))[0]
  }
}

resource "aws_lambda_function" "createwav" {
  function_name    = reverse(split("/", var.createwav_lambda_loggroup_name))[0]
  description      = "Create WAV File include PII"
  runtime          = "python3.14"
  architectures    = ["x86_64"]
  filename         = data.archive_file.createwav.output_path
  source_code_hash = data.archive_file.createwav.output_base64sha256
  handler          = "create_include_pii_wav.lambda_handler"
  timeout          = 900
  memory_size      = 128
  ephemeral_storage {
    size = 512
  }
  role = var.lambda_role_arn
  logging_config {
    log_group             = var.createwav_lambda_loggroup_name
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
  }
  tracing_config {
    mode = "PassThrough"
  }
  skip_destroy = false
  tags = {
    Name = reverse(split("/", var.createwav_lambda_loggroup_name))[0]
  }
}