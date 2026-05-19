output "arn_sfrole" {
  value = aws_iam_role.step_functions.arn
}

output "arn_eventbridge_rule_role" {
  value = aws_iam_role.eventbridge_rule.arn
}

output "arn_lambda" {
  value = aws_iam_role.lambda.arn
}

output "arn_glue_databrew_role" {
  value = aws_iam_role.glue_databrew.arn
}