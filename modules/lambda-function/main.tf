terraform {
  required_version = ">= 1.0"
}

# Package the Lambda function code
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = var.source_file
  output_path = var.output_path
}

# Lambda function
resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  runtime = var.runtime

  dynamic "environment" {
    for_each = var.environment_variables != null ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  timeout     = var.timeout
  memory_size = var.memory_size

  layers      = var.layers

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )
}
