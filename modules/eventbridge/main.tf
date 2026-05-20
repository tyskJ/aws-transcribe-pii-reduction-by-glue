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
  input_transformer {
    input_paths = {
      src_bucket = "$.detail.bucket.name"
      object_key = "$.detail.object.key"
    }
    input_template = <<EOF
{
  "transcribe_src_bucket": <src_bucket>,
  "transcribe_dst_bucket": "${var.transcribe_dst_bucket_name}",
  "glue_src_bucket": "${var.glue_src_bucket_name}",
  "glue_dst_bucket": "${var.glue_dst_bucket_name}",
  "output_bucket": "${var.output_bucket_name}",
  "glue_role_arn": "${var.glue_databrew_role_arn}",
  "glue_recipe_name": "${var.glue_databrew_recipe_name}",
  "glue_recipe_version": "${var.glue_databrew_recipe_version}",
  "object_key": <object_key>
}
    EOF
  }
  role_arn = var.eventbridge_rule_role_arn
}