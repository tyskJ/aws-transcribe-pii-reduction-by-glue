/************************************************************
Step Functions Role
************************************************************/
resource "aws_iam_role" "step_functions" {
  name = "iam-role-step-functions-role"
  tags = {
    Name = "iam-role-step-functions-role"
  }
  description = "Allows Step Functions to access AWS resources on your behalf."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions" {
  for_each = {
    cwlogs_vended_delivery = aws_iam_policy.cwlogs_vended_delivery.arn
  }
  role       = aws_iam_role.step_functions.name
  policy_arn = each.value
}

/************************************************************
EventBridge Rule Role
************************************************************/
resource "aws_iam_role" "eventbridge_rule" {
  name = "iam-role-eventbridge-rule"
  tags = {
    Name = "iam-role-eventbridge-rule"
  }
  description = "Allows CloudWatch Events to invoke targets and perform actions in built-in targets on your behalf."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_rule" {
  for_each = {
    sf_statemachine = aws_iam_policy.sf_statemachine_ops.arn
  }
  role       = aws_iam_role.eventbridge_rule.name
  policy_arn = each.value
}