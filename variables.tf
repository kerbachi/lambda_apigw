variable "aws_id" {
  description = "AWS ID account"
  type        = string
  default     = "219113380444"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    project = "poc"
    # owner       = data.aws_caller_identity.current.arn
    application = "eks-karpenter"
  }
}

############ Networking variables #############

variable "region" {
  description = "Region of deployment"
  default     = "us-east-1"
}

# variable vpc_id {
#   description = "VPC id for deployment"
#   default = "vpc-8d2d84f7"
# }