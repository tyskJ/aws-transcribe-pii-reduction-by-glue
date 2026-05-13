/************************************************************
CloudWatch Vended Logs Policy
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