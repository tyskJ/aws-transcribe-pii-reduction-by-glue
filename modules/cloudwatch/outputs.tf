output "arn_sf_loggroup" {
  value = aws_cloudwatch_log_group.sf_logs.arn
}

output "name_json_converter_lambda_loggroup" {
  value = aws_cloudwatch_log_group.lambda_json_converter_logs.tags_all.Name
}

output "name_createwav_lambda_loggroup" {
  value = aws_cloudwatch_log_group.lambda_createwav_logs.tags_all.Name
}

output "name_csv_converter_lambda_loggroup" {
  value = aws_cloudwatch_log_group.lambda_csv_converter_logs.tags_all.Name
}