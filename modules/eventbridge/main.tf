/************************************************************
Rule
************************************************************/
resource "aws_cloudwatch_event_rule" "transcribe_src_bucket_put_event" {
  name           = "transcribe-src-bucket-put-object-event-rule"
  description    = "Detect object put events to a Transcribe Src bucket"
  state          = "ENABLED"
  event_bus_name = "default"
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["${var.transcribe_src_bucket_name}"]
      }
      reason = ["PutObject"]
      object = {
        key = [{
          suffix = ".wav"
        }]
      }
    }
  })
  tags = {
    Name = "transcribe-src-bucket-put-object-event-rule"
  }
}

/************************************************************
Target
************************************************************/
resource "aws_cloudwatch_event_target" "transcribe_src_bucket_put_event_sf" {
  rule           = aws_cloudwatch_event_rule.transcribe_src_bucket_put_event.name
  event_bus_name = "default"
  target_id      = "target-statemachine"
  arn            = var.sf_arn
  role_arn       = var.eventbridge_rule_role_arn
}