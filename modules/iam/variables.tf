variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role for Lambda function execution"
}

variable "trusted_entities" {
  description = "Trusted entities that can assume this role"
  type        = list(string)
  default     = ["lambda.amazonaws.com"]
}

variable "attach_vpc_policy" {
  description = "Attach VPC access policy to the role"
  type        = bool
  default     = false
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Inline policy JSON to attach to the role"
  type        = string
  default     = null
}

variable "inline_policy_name" {
  description = "Name for the inline policy"
  type        = string
  default     = null
}

variable "assume_role_policy_document" {
  description = "Custom assume role policy document JSON. If provided, overrides the built-in assume role policy."
  type        = string
  default     = null
}

variable "additional_policy_documents" {
  description = "Map of additional policy documents to attach as inline policies. Keys are policy names, values are policy document JSON strings."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
