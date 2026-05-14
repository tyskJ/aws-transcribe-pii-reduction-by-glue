output "arn_sflogs" {
  value = aws_cloudwatch_log_group.sf_logs.arn
}

output "name_lambda_loggroup" {
  value = aws_cloudwatch_log_group.lambda_converter_logs.tags_all.Name
}