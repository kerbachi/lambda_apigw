# Lambda Layer Module

This module creates AWS Lambda layers that can be shared across multiple Lambda functions.

## Features

- Creates Lambda layer versions with proper packaging
- Supports multiple compatible runtimes
- Automatic ZIP packaging from source directory
- Version tracking and ARN output

## Usage

```hcl
module "utils_layer" {
  source = "../lambda-layer"

  layer_name           = "utils-layer"
  description          = "Utility functions for Lambda functions"
  compatible_runtimes  = ["python3.12"]
  source_dir           = "lambda_layer_src"
  output_path          = "lambda_build/utils_layer.zip"
}
```

## Variables

| Name                | Description                                   | Type           | Default          | Required |
| ------------------- | --------------------------------------------- | -------------- | ---------------- | :------: |
| layer_name          | The name of the Lambda layer                  | `string`       | n/a              |   yes    |
| description         | Description of the Lambda layer               | `string`       | `""`             |    no    |
| compatible_runtimes | List of compatible runtimes for the layer     | `list(string)` | `["python3.12"]` |    no    |
| license_info        | License info for the layer                    | `string`       | `""`             |    no    |
| source_dir          | Source directory containing the layer code    | `string`       | n/a              |   yes    |
| output_path         | Path where the layer zip file will be created | `string`       | n/a              |   yes    |
| tags                | Tags to apply to the layer                    | `map(string)`  | `{}`             |    no    |

## Outputs

| Name          | Description                         |
| ------------- | ----------------------------------- |
| layer_arn     | The ARN of the Lambda layer version |
| layer_version | The version of the Lambda layer     |
| layer_name    | The name of the Lambda layer        |

## Layer Structure

The layer follows the AWS Lambda layer directory structure:

```
layer/
├── python/
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── logger.py
│   │   ├── validator.py
│   │   └── formatter.py
│   └── requirements.txt (optional)
```

## Example Utilities Included

### logger.py

- `setup_logger()` - Standardized logger setup
- `create_response()` - Standardized API response formatting
- `log_event_info()` - Basic event and context logging

### validator.py

- `validate_email()` - Email format validation
- `validate_required_fields()` - Required field validation
- `validate_string_length()` - String length validation
- `sanitize_input()` - Basic input sanitization

### formatter.py

- `format_response_data()` - Data formatting for JSON serialization
- `mask_sensitive_data()` - Mask sensitive information
- `create_paginated_response()` - Standardized pagination response

## Using Layers in Lambda Functions

To use this layer in a Lambda function:

```hcl
module "lambda_function" {
  source = "../lambda-function"

  function_name = "my-function"
  source_file   = "lambda_src/my_function.py"
  output_path   = "lambda_build/my_function.zip"
  role_arn      = aws_iam_role.lambda_role.arn
  handler       = "my_function.lambda_handler"

  layers = [module.utils_layer.layer_arn]
}
```

In your Lambda function code:

```python
try:
    from utils.logger import setup_logger, create_response
    from utils.validator import validate_email
    from utils.formatter import format_response_data
    LAYER_AVAILABLE = True
except ImportError:
    LAYER_AVAILABLE = False
    # Fallback implementations
```
