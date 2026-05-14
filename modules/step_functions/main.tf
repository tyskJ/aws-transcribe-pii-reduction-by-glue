/************************************************************
State Machine
************************************************************/
resource "aws_sfn_state_machine" "this" {
  name     = "transcribe-glue-databrew-state-machine"
  type     = "STANDARD"
  role_arn = var.sfrole_arn
  definition = templatefile("${path.module}/config/transcribe-glue-databrew-state-machine.json", {
    converter_lambda_arn = var.converter_lambda_arn
  })
  logging_configuration {
    include_execution_data = true
    level                  = "ERROR"
    log_destination        = "${var.sflogs_arn}:*"
  }
  tracing_configuration {
    enabled = false
  }
  publish = true
  encryption_configuration {
    type = "AWS_OWNED_KEY"
  }
  tags = {
    Name = "transcribe-glue-databrew-state-machine"
  }
}