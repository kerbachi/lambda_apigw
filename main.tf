provider "aws" {
  region = var.region
}



### IAM Role for Lambda function

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Example: Custom policy document for CloudWatch Logs assume role
data "aws_iam_policy_document" "logs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}

# Example: Custom policy for S3 access
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::my-bucket/*"
    ]
  }
}

resource "aws_iam_role" "example" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



### Lambda function

# Package the Lambda function code
data "archive_file" "function1" {
  type        = "zip"
  source_dir  = "lambda-src/function1"
  output_path = "lambda_build/function1.zip"
}

# Package the Lambda layer code
data "archive_file" "utils_layer" {
  type        = "zip"
  source_dir  = "lambda_layer_src"
  output_path = "lambda_build/utils_layer.zip"
}

# Lambda layer
resource "aws_lambda_layer_version" "utils_layer" {
  layer_name          = "utils-layer"
  description         = "Utility functions for Lambda functions"
  compatible_runtimes = ["python3.12"]

  filename         = data.archive_file.utils_layer.output_path
  source_code_hash = data.archive_file.utils_layer.output_base64sha256
}

# Package the Lambda function code
data "archive_file" "function_with_layer" {
  type        = "zip"
  source_file = "lambda_src/function_with_layer.py"
  output_path = "lambda_build/function_with_layer.zip"
}

# Lambda function with layer
resource "aws_lambda_function" "function_with_layer" {
  filename         = data.archive_file.function_with_layer.output_path
  function_name    = "function-with-layer"
  role             = aws_iam_role.example.arn
  handler          = "function_with_layer.lambda_handler"
  source_code_hash = data.archive_file.function_with_layer.output_base64sha256

  runtime = "python3.12"

  layers = [aws_lambda_layer_version.utils_layer.arn]

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
    HasLayer    = "true"
  }
}

# Original Lambda function (without layer for comparison)
resource "aws_lambda_function" "function1" {
  filename         = data.archive_file.function1.output_path
  function_name    = "function1"
  role             = aws_iam_role.example.arn
  handler          = "function1.lambda_handler"
  source_code_hash = data.archive_file.function1.output_base64sha256

  runtime = "python3.12"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
    HasLayer    = "false"
  }
}
