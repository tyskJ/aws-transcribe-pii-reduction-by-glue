output "arn_sfrole" {
  value = aws_iam_role.step_functions.arn
}

output "arn_eventbridge_rule_role" {
  value = aws_iam_role.eventbridge_rule.arn
}