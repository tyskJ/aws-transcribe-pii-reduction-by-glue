output "arn_sflogs" {
  value = aws_cloudwatch_log_group.sf_logs.arn
}

output "name_converter_lambda_loggroup" {
  value = aws_cloudwatch_log_group.lambda_converter_logs.tags_all.Name
}

output "name_createwav_lambda_loggroup" {
  value = aws_cloudwatch_log_group.lambda_createwav_logs.tags_all.Name 
}