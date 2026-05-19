variable "transcribe_src_bucket_name" {
  type = string
}

variable "transcribe_dst_bucket_name" {
  type = string
}

variable "glue_src_bucket_name" {
  type = string
}

variable "glue_dst_bucket_name" {
  type = string
}

variable "sf_arn" {
  type = string
}

variable "eventbridge_rule_role_arn" {
  type = string
}

variable "glue_databrew_role_arn" {
  type = string
}

variable "glue_databrew_recipe_name" {
  type = string
}

variable "glue_databrew_recipe_version" {
  type = string
}