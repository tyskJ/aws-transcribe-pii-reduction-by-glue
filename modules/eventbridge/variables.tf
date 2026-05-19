variable "transcribe_src_bucket_name" {
  type = string
}

variable "transcribe_dst_bucket_name" {
  type = string
}

variable "glue_src_bucket_name" {
  type = string
}

variable "sf_arn" {
  type = string
}

variable "eventbridge_rule_role_arn" {
  type = string
}

variable "translate_role_arn" {
  type = string
}

variable "translate_md_bucket_name" {
  type = string
}

variable "translate_en_bucket_name" {
  type = string
}

variable "translate_jp_bucket_name" {
  type = string
}