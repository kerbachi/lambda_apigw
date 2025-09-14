variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    project     = "poc"
    application = "example"
  }
}
