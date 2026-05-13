output "name_transcribe_src_bucket" {
  value = aws_s3_bucket.transcribe_src.id
}

output "arn_transcribe_src_bucket" {
  value = aws_s3_bucket.transcribe_src.arn
}

output "arn_transcribe_dst_bucket" {
  value = aws_s3_bucket.transcribe_dst.arn
}