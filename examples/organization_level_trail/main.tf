locals {
  name          = "account-api-trailz"
  s3_key_prefix = "cloudtrails"
  bucket_name   = "cloudtrail-bkt-boldlink01"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

module "aws_cloudtrail" {
  #source = "boldlink/cloudtrail/aws"
  source                     = "../../"
  name                       = local.name
  enable_log_file_validation = true
  bucket_name                = local.bucket_name
  is_organization_trail      = true
  protect_cloudtrail         = true  ## Protects against disabling cloudtrail
  enable_logging             = true

  event_selectors = [
    {
      read_write_type = "All"
      data_resource = {
        type   = "AWS::Lambda::Function"
        values = ["arn:aws:lambda"]
      }
    },
    {
      read_write_type = "All"
      data_resource = {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3:::"]
      }
    }
  ]
}
