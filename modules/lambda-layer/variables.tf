variable "layer_name" {
  description = "The name of the Lambda layer"
  type        = string
}

variable "description" {
  description = "Description of the Lambda layer"
  type        = string
  default     = ""
}

variable "compatible_runtimes" {
  description = "List of compatible runtimes for the layer"
  type        = list(string)
  default     = ["python3.12"]
}

variable "license_info" {
  description = "License info for the layer"
  type        = string
  default     = ""
}

variable "source_dir" {
  description = "Source directory containing the layer code"
  type        = string
}

variable "output_path" {
  description = "Path where the layer zip file will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the layer"
  type        = map(string)
  default     = {}
}
