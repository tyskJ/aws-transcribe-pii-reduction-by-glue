/************************************************************
Bucket Name
************************************************************/
output "name_transcribe_src_bucket" {
  value = aws_s3_bucket.transcribe_src.id
}

output "name_transcribe_dst_bucket" {
  value = aws_s3_bucket.transcribe_dst.id
}

output "name_glue_src_bucket" {
  value = aws_s3_bucket.glue_src.id
}

output "name_glue_dst_bucket" {
  value = aws_s3_bucket.glue_dst.id
}

/************************************************************
Bucket ARN
************************************************************/
output "arn_transcribe_src_bucket" {
  value = aws_s3_bucket.transcribe_src.arn
}

output "arn_transcribe_dst_bucket" {
  value = aws_s3_bucket.transcribe_dst.arn
}

output "arn_glue_src_bucket" {
  value = aws_s3_bucket.glue_src.arn
}

output "arn_glue_dst_bucket" {
  value = aws_s3_bucket.glue_dst.arn
}