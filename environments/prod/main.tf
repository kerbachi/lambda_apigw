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

# Create IAM role for Lambda functions
module "lambda_iam_role" {
  source = "../../modules/iam"

  role_name        = "lambda-execution-role-prod"
  role_description = "IAM role for Lambda function execution in prod environment"
  trusted_entities = ["lambda.amazonaws.com"]
  attach_vpc_policy = false
  policy_arns      = []
  tags = merge(
    var.resource_tags,
    {
      Environment = "prod"
    }
  )
}




# Create Lambda function
module "function1" {
  source = "../../modules/lambda-function"

  source_file         = "../../lambda-src/function1/function1.py"
  output_path         = "../../lambda-build/function1-prod.zip"
  function_name       = "function1-prod"
  role_arn            = module.lambda_iam_role.role_arn
  handler             = "function1.lambda_handler"
  runtime             = "python3.12"
  timeout             = 30
  memory_size         = 128

  environment_variables = {
    ENVIRONMENT = "prod"
    LOG_LEVEL   = "info"
  }

  tags = merge(
    var.resource_tags,
    {
      Environment = "prod"
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

  layer_name          = "utils-layer-prod"
  description         = "Utility functions layer for Lambda functions"
  source_dir          = "../../lambda_layer_src"
  output_path         = "../../lambda-build/layer-prod.zip"
  compatible_runtimes = ["python3.12"]

  tags = merge(
    var.resource_tags,
    {
      Environment = "prod"
    }
  )
}


# Create function_with_layer
module "function_with_layer" {
  source = "../../modules/lambda-function"

  source_file         = "../../lambda-src/function_with_layer/function_with_layer.py"
  output_path         = "../../lambda-build/function-with-layer-prod.zip"
  function_name       = "function-with-layer-prod"
  role_arn            = module.lambda_iam_role.role_arn
  handler             = "function_with_layer.lambda_handler"
  runtime             = "python3.12"
  timeout             = 30
  memory_size         = 128

  layers = [module.lambda_layer.layer_arn]

  environment_variables = {
    ENVIRONMENT = "prod"
    LOG_LEVEL   = "info"
  }

  tags = merge(
    var.resource_tags,
    {
      Environment = "prod"
      Application = "example"
    }
  )
}
