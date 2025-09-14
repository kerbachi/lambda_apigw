terraform {
  required_version = ">= 1.0"
}

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  count = var.assume_role_policy_document == null ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = var.trusted_entities
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy_document != null ? var.assume_role_policy_document : data.aws_iam_policy_document.assume_role[0].json
  description        = var.role_description

  tags = var.tags
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach VPC access policy if needed
resource "aws_iam_role_policy_attachment" "vpc_access" {
  count      = var.attach_vpc_policy ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom policy attachments
resource "aws_iam_role_policy_attachment" "custom_policies" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.policy_arns[count.index]
}

# Custom inline policy
resource "aws_iam_role_policy" "inline_policy" {
  count  = var.inline_policy != null ? 1 : 0
  name   = coalesce(var.inline_policy_name, "${var.role_name}-inline-policy")
  role   = aws_iam_role.lambda_role.name
  policy = var.inline_policy
}

# Additional policy documents as inline policies
resource "aws_iam_role_policy" "additional_policies" {
  for_each = var.additional_policy_documents
  name     = each.key
  role     = aws_iam_role.lambda_role.name
  policy   = each.value
}
