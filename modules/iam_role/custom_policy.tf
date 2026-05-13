/************************************************************
CloudWatch Vended Logs Operation Policy
************************************************************/
resource "aws_iam_policy" "cwlogs_vended_delivery" {
  name = "iam-policy-cwlogs-vended-delivery"
  tags = {
    Name = "iam-policy-cwlogs-vended-delivery"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCwLogsVendedDelivery"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:CreateLogStream",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        Resource = ["*"]
      }
    ]
  })
}

/************************************************************
Step Functions State Machine Operation Policy
************************************************************/
resource "aws_iam_policy" "sf_statemachine_ops" {
  name = "iam-policy-sf-statemachine-ops"
  tags = {
    Name = "iam-policy-sf-statemachine-ops"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSfStateMachineOps"
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ],
        Resource = ["*"]
      }
    ]
  })
}