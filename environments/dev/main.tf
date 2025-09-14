terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
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
      "arn:aws:s3:::my-dev-bucket/*"
    ]
  }
}

# Create IAM role for Lambda functions
module "lambda_iam_role" {
  source = "../../modules/iam"

  role_name        = "lambda-execution-role-dev"
  role_description = "IAM role for Lambda function execution in dev environment"
  trusted_entities = ["lambda.amazonaws.com"]
  
  # Example 1: Using custom assume role policy document
  # assume_role_policy_document = data.aws_iam_policy_document.logs_assume_role.json
  
  # Example 2: Using additional policy documents as inline policies
  # additional_policy_documents = {
  #   "s3-access-policy" = data.aws_iam_policy_document.s3_access.json
  # }
  
  attach_vpc_policy = false
  policy_arns      = []
  tags = merge(
    var.resource_tags,
    {
      Environment = "dev"
    }
  )
}



#######################################
# Create Lambda function1
#######################################

module "function1" {
  source = "../../modules/lambda-function"

  source_file         = "../../lambda-src/function1/function1.py"
  output_path         = "../../lambda-build/function1-dev.zip"
  function_name       = "function1-dev"
  role_arn            = module.lambda_iam_role.role_arn
  handler             = "function1.lambda_handler"
  runtime             = "python3.12"
  timeout             = 30
  memory_size         = 128

  environment_variables = {
    ENVIRONMENT = "dev"
    LOG_LEVEL   = "debug"
  }

  tags = merge(
    var.resource_tags,
    {
      Environment = "dev"
      Application = "example"
    }
  )
}


#######################################
# Create Lambda function-with-layer-dev
#######################################


# Create Lambda layer
module "lambda_layer" {
  source = "../../modules/lambda-layer"

  layer_name          = "utils-layer-dev"
  description         = "Utility functions layer for Lambda functions"
  source_dir          = "../../lambda_layer_src"
  output_path         = "../../lambda-build/layer-dev.zip"
  compatible_runtimes = ["python3.12"]

  tags = merge(
    var.resource_tags,
    {
      Environment = "dev"
    }
  )
}


# Create function_with_layer
module "function_with_layer" {
  source = "../../modules/lambda-function"

  source_file         = "../../lambda-src/function_with_layer/function_with_layer.py"
  output_path         = "../../lambda-build/function-with-layer-dev.zip"
  function_name       = "function-with-layer-dev"
  role_arn            = module.lambda_iam_role.role_arn
  handler             = "function_with_layer.lambda_handler"
  runtime             = "python3.12"
  timeout             = 30
  memory_size         = 128

  layers = [module.lambda_layer.layer_arn]

  environment_variables = {
    ENVIRONMENT = "dev"
    LOG_LEVEL   = "debug"
  }

  tags = merge(
    var.resource_tags,
    {
      Environment = "dev"
      Application = "example"
    }
  )
}
