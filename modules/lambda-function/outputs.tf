output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "invoke_arn" {
  description = "The ARN to be used for invoking Lambda function from API Gateway"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "qualified_arn" {
  description = "The ARN identifying your Lambda function version"
  value       = aws_lambda_function.lambda_function.qualified_arn
}

output "version" {
  description = "Latest published version of your Lambda function"
  value       = aws_lambda_function.lambda_function.version
}

output "layers" {
  description = "List of attached Lambda layer ARNs"
  value       = aws_lambda_function.lambda_function.layers
}
