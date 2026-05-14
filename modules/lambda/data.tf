data "archive_file" "converter" {
  type        = "zip"
  source_file = "${path.module}/asset/transcribe_json_to_csv.py"
  output_path = "${path.module}/asset/transcribe_json_to_csv.zip"
}


data "archive_file" "createwav" {
  type        = "zip"
  source_file = "${path.module}/asset/create_include_pii_wav.py"
  output_path = "${path.module}/asset/create_include_pii_wav.zip"
}