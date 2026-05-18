# data "external" "json_converter_layer" {
#   program = ["${path.module}/scripts/layer_library_create.sh", "3.14"]
# }

resource "terraform_data" "create_python_package" {
  triggers_replace = filebase64sha256("${path.module}/scripts/requirements.txt")

  provisioner "local-exec" {
    command = "${path.module}/scripts/layer_library_create.sh 3.14"
  }
}

data "archive_file" "json_converter_lambda_layer" {
  depends_on = [
    terraform_data.create_python_package
  ]

  type        = "zip"
  source_dir  = "${path.module}/build/layer/"
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