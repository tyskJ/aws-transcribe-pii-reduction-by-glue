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