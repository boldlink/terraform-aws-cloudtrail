variable "name" {
  type        = string
  description = "The name of the stack"
  default     = "cloudtrail-complete-example"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the resources"
  default = {
    Environment        = "example"
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}
