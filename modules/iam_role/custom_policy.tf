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
        Resource = [
          "arn:${var.partition}:states:${var.region}:${var.account_id}:stateMachine:*"
        ]
      }
    ]
  })
}

/************************************************************
Transcribe Operation Policy
************************************************************/
resource "aws_iam_policy" "transcribe_ops" {
  name = "iam-policy-transcribe-ops"
  tags = {
    Name = "iam-policy-transcribe-ops"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowStartTranscribeJob"
        Effect = "Allow"
        Action = [
          "transcribe:StartTranscriptionJob"
        ],
        Resource = ["*"]
      },
      {
        Sid    = "AllowGetTranscribeJob"
        Effect = "Allow"
        Action = [
          "transcribe:GetTranscriptionJob"
        ],
        Resource = [
          "arn:${var.partition}:transcribe:${var.region}:${var.account_id}:transcription-job/*"
        ]
      }
    ]
  })
}

/************************************************************
S3 Operation Policy
************************************************************/
resource "aws_iam_policy" "s3_ops" {
  name = "iam-policy-s3-ops"
  tags = {
    Name = "iam-policy-s3-ops"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGetObject"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "${var.transcribe_src_bucket_arn}/*",
          "${var.transcribe_dst_bucket_arn}/*"
        ]
      },
      {
        Sid    = "AllowPutObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "${var.transcribe_dst_bucket_arn}/*",
          "${var.glue_src_bucket_arn}/*"
        ]
      }
    ]
  })
}

/************************************************************
Lambda Operation Policy
************************************************************/
resource "aws_iam_policy" "lambda_ops" {
  name = "iam-policy-lambda-ops"
  tags = {
    Name = "iam-policy-lambda-ops"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowLambdaOps"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "arn:${var.partition}:lambda:${var.region}:${var.account_id}:function:*"
        ]
      }
    ]
  })
}