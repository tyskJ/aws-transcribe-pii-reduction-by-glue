output "name_transcribe_src_bucket" {
  value = aws_s3_bucket.transcribe_src.id
}

output "name_transcribe_dst_bucket" {
  value = aws_s3_bucket.transcribe_dst.id
}

output "name_translate_en_bucket" {
  value = aws_s3_bucket.translate_en.id
}

output "name_translate_jp_bucket" {
  value = aws_s3_bucket.translate_jp.id
}

output "name_glue_src_bucket" {
  value = aws_s3_bucket.glue_src.id
}

output "arn_transcribe_src_bucket" {
  value = aws_s3_bucket.transcribe_src.arn
}

output "arn_translate_en_bucket" {
  value = aws_s3_bucket.translate_en.arn
}

output "arn_translate_jp_bucket" {
  value = aws_s3_bucket.translate_jp.arn
}

output "arn_transcribe_dst_bucket" {
  value = aws_s3_bucket.transcribe_dst.arn
}

output "arn_glue_src_bucket" {
  value = aws_s3_bucket.glue_src.arn
}