/************************************************************
CloudWatch Vended Logs Operation Policy
************************************************************/
resource "aws_iam_policy" "cwlogs_vended_delivery_for_sf" {
  name = "iam-policy-cwlogs-vended-delivery-for-sf"
  tags = {
    Name = "iam-policy-cwlogs-vended-delivery-for-sf"
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
resource "aws_iam_policy" "sf_statemachine_ops_for_eventbridge_rule" {
  name = "iam-policy-sf-statemachine-ops-for-eventbridge-rule"
  tags = {
    Name = "iam-policy-sf-statemachine-ops-for-eventbridge-rule"
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
resource "aws_iam_policy" "transcribe_ops_for_sf" {
  name = "iam-policy-transcribe-ops-for-sf"
  tags = {
    Name = "iam-policy-transcribe-ops-for-sf"
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
      },
      {
        Sid    = "AllowDeleteTranscribeJob"
        Effect = "Allow"
        Action = [
          "transcribe:DeleteTranscriptionJob"
        ],
        Resource = [
          "arn:${var.partition}:transcribe:${var.region}:${var.account_id}:transcription-job/*"
        ]
      }
    ]
  })
}

/************************************************************
Translate Operation Policy
************************************************************/
resource "aws_iam_policy" "translate_ops_for_lambda" {
  name = "iam-policy-transcribe-ops-for-lambda"
  tags = {
    Name = "iam-policy-transcribe-ops-for-lambda"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowStartTranslateText"
        Effect = "Allow"
        Action = [
          "translate:TranslateText"
        ],
        Resource = ["*"]
      }
    ]
  })
}

/************************************************************
S3 Operation Policy
************************************************************/
resource "aws_iam_policy" "s3_ops_for_sf" {
  name = "iam-policy-s3-ops-for-sf"
  tags = {
    Name = "iam-policy-s3-ops-for-sf"
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
          "${var.transcribe_src_bucket_arn}/*"
        ]
      },
      {
        Sid    = "AllowPutObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "${var.transcribe_dst_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_ops_for_lambda" {
  name = "iam-policy-s3-ops-for-lambda"
  tags = {
    Name = "iam-policy-s3-ops-for-lambda"
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
          "${var.transcribe_src_bucket_arn}/*",
          "${var.glue_src_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_ops_for_glue_databrew" {
  name = "iam-policy-s3-ops-for-glue-databrew"
  tags = {
    Name = "iam-policy-s3-ops-for-glue-databrew"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowListOfInsideSpecificBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "${var.glue_src_bucket_arn}",
          "${var.glue_dst_bucket_arn}"
        ]
      },
      {
        Sid    = "AllowGetOfInsideSpecificBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "${var.glue_src_bucket_arn}/*",
          "${var.glue_dst_bucket_arn}/*"
        ]
      },
      {
        Sid    = "AllowWriteOfInsideSpecificBucket"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${var.glue_dst_bucket_arn}/*"
        ]
      }
    ]
  })
}

# resource "aws_iam_policy" "s3_ops_for_translate" {
#   name = "iam-policy-s3-ops-for-translate"
#   tags = {
#     Name = "iam-policy-s3-ops-for-translate"
#   }
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "AllowListOfInsideSpecificBucket"
#         Effect = "Allow"
#         Action = [
#           "s3:ListBucket"
#         ],
#         Resource = [
#           "${var.translate_md_bucket_arn}",
#           "${var.translate_en_bucket_arn}"
#         ]
#       },
#       {
#         Sid    = "AllowGetOfInsideSpecificBucket"
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject"
#         ],
#         Resource = [
#           "${var.translate_md_bucket_arn}/*",
#           "${var.translate_en_bucket_arn}/*"
#         ]
#       },
#       {
#         Sid    = "AllowPutOfInsideSpecificBucket"
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject"
#         ],
#         Resource = [
#           "${var.translate_en_bucket_arn}/*"
#         ]
#       }
#     ]
#   })
# }

/************************************************************
Lambda Operation Policy
************************************************************/
resource "aws_iam_policy" "lambda_ops_for_sf" {
  name = "iam-policy-lambda-ops-for-sf"
  tags = {
    Name = "iam-policy-lambda-ops-for-sf"
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

/************************************************************
Polly Operation Policy
************************************************************/
resource "aws_iam_policy" "polly_ops_for_lambda" {
  name = "iam-policy-polly-ops-for-lambda"
  tags = {
    Name = "iam-policy-polly-ops-for-lambda"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPollyOps"
        Effect = "Allow"
        Action = [
          "polly:SynthesizeSpeech"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

/************************************************************
IAM Operation Policy
************************************************************/
resource "aws_iam_policy" "iam_ops_for_eventbridge_rule" {
  name = "iam-policy-iam-ops-for-eventbridge-rule"
  tags = {
    Name = "iam-policy-iam-ops-for-eventbridge-rule"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "*"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" : "states.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "iam_ops_for_sf" {
  name = "iam-policy-iam-ops-for-sf"
  tags = {
    Name = "iam-policy-iam-ops-for-sf"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          "*"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" : "databrew.amazonaws.com"
          }
        }
      }
    ]
  })
}

/************************************************************
Glue DataBrew Operation Policy
************************************************************/
resource "aws_iam_policy" "glue_databrew_ops_for_sf" {
  name = "iam-policy-glue-databrew-ops-for-sf"
  tags = {
    Name = "iam-policy-glue-databrew-ops-for-sf"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGlueDataBrewOps"
        Effect = "Allow"
        Action = [
          "databrew:CreateDataset",
          "databrew:CreateRecipeJob",
          "databrew:DeleteDataset"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}