# Code template for AWS LAmbda deployment using terraform.

## New Project Structure

```javascript
terraform/
├── modules/
│   ├── lambda-function/      # Reusable Lambda module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                  # Reusable IAM module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/                  # Development environment
│   │   ├── main.tf           # Calls modules for dev
│   │   ├── variables.tf      # Dev-specific variables
│   │   └── terraform.tfvars  # Dev variable values
│   └── prod/                 # Production environment
│       ├── main.tf           # Calls modules for prod
│       ├── variables.tf      # Prod-specific variables
│       └── terraform.tfvars  # Prod variable values
├── lambda-src/               # Source code for all functions
│   └── function1/
│       └── function1.py      # Migrated function1 code
├── lambda-build/             # Built artifacts (gitignored)
├── .gitignore                # Updated to ignore build artifacts
```

## Key Improvements

1. **Modular Design**: Created reusable modules for Lambda functions and IAM roles
2. **Environment Separation**: Separate dev/prod environments with isolated configurations
3. **Clean Code Organization**: Each Lambda function now has its own source directory
4. **Scalability**: Easy to add new functions by creating new module instances
5. **Maintainability**: IAM roles and policies are now in their own dedicated module
6. **Enhanced Policy Support**: IAM module now accepts Terraform policy documents as data sources
7. **Lambda Layer Support**: Added support for Lambda layers with reusable utility functions

## Using Policy Documents with the IAM Module

The IAM module now supports passing Terraform `aws_iam_policy_document` data sources directly:

### Custom Assume Role Policy

```hcl
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

module "lambda_iam_role" {
  source = "../../modules/iam"

  role_name = "lambda-execution-role"
  assume_role_policy_document = data.aws_iam_policy_document.logs_assume_role.json
  # ... other parameters
}
```

### Additional Policy Documents

```hcl
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::my-bucket/*"]
  }
}

module "lambda_iam_role" {
  source = "../../modules/iam"

  role_name = "lambda-execution-role"
  additional_policy_documents = {
    "s3-access-policy" = data.aws_iam_policy_document.s3_access.json
  }
  # ... other parameters
}
```

## Lambda Layer Support

This project now includes support for Lambda layers through a dedicated `lambda-layer` module. Layers allow you to share code and dependencies across multiple Lambda functions.

### Included Utilities

The example layer includes useful utilities:

- **Logger**: Standardized logging setup and response formatting
- **Validator**: Input validation functions (email, required fields, string length)
- **Formatter**: Data formatting for JSON serialization and pagination

### Using Layers

To create and use a Lambda layer:

```hcl
module "utils_layer" {
  source = "../modules/lambda-layer"

  layer_name          = "utils-layer"
  description         = "Utility functions for Lambda functions"
  compatible_runtimes = ["python3.12"]
  source_dir          = "lambda_layer_src"
  output_path         = "lambda_build/utils_layer.zip"
}

module "lambda_function_with_layer" {
  source = "../modules/lambda-function"

  function_name = "my-function"
  source_file   = "lambda_src/my_function.py"
  output_path   = "lambda_build/my_function.zip"
  role_arn      = module.iam.lambda_role_arn
  handler       = "my_function.lambda_handler"

  layers = [module.utils_layer.layer_arn]
}
```

### Layer Structure

```
lambda_layer_src/
└── utils/
    ├── __init__.py
    ├── logger.py      # Logging and response utilities
    ├── validator.py   # Input validation functions
    └── formatter.py   # Data formatting utilities
```

## How to Use

To deploy to different environments:

```bash
# For development
cd environments/dev
terraform init
terraform plan
terraform apply

# For production
cd environments/prod
terraform init
terraform plan
terraform apply
```

To add a new Lambda function:

1. Create `lambda-src/function2/function2.py`
2. Add a new module block in your environment's `main.tf`
3. Run `terraform apply`

The existing function1 has been migrated to this new structure and maintains the same functionality while being properly isolated in the dev/prod environments.

## TODO

1. Add API GW + integration
2. DevOps Azure
3. Store credentials
