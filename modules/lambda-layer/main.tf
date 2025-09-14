terraform {
  required_version = ">= 1.0"
}

# Package the Lambda layer code
data "archive_file" "layer_package" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.output_path
}

# Lambda layer
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name           = var.layer_name
  description          = var.description
  license_info         = var.license_info
  compatible_runtimes  = var.compatible_runtimes

  filename             = data.archive_file.layer_package.output_path
  source_code_hash     = data.archive_file.layer_package.output_base64sha256
}
