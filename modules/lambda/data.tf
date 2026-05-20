data "external" "create_python_package" {
  program = ["${path.module}/scripts/layer_library_create.sh", "3.14"]
}

data "archive_file" "json_converter_lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/${data.external.create_python_package.result.path}"
  output_path = "${path.module}/asset/json_converter_lambda_layer.zip"
}

data "archive_file" "json_converter" {
  type        = "zip"
  source_file = "${path.module}/asset/transcribe_json_to_excel.py"
  output_path = "${path.module}/asset/transcribe_json_to_excel.zip"
}


data "archive_file" "createwav" {
  type        = "zip"
  source_file = "${path.module}/asset/create_include_pii_wav.py"
  output_path = "${path.module}/asset/create_include_pii_wav.zip"
}

data "archive_file" "csv_converter" {
  type        = "zip"
  source_file = "${path.module}/asset/glue_csv_to_text.py"
  output_path = "${path.module}/asset/glue_csv_to_text.zip"
}