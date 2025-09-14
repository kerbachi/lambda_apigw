output "layer_arn" {
  description = "The ARN of the Lambda layer version"
  value       = aws_lambda_layer_version.lambda_layer.arn
}

output "layer_version" {
  description = "The version of the Lambda layer"
  value       = aws_lambda_layer_version.lambda_layer.version
}

output "layer_name" {
  description = "The name of the Lambda layer"
  value       = aws_lambda_layer_version.lambda_layer.layer_name
}
