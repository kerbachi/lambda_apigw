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


resource "aws_iam_role" "example" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



### Lambda function

# Package the Lambda function code
data "archive_file" "function1" {
  type        = "zip"
  source_file = "lambda_src/function1.py"
  output_path = "lambda_build/function1.zip"
}

# Lambda function
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
  }
}