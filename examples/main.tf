locals {
  name          = "sample-${uuid()}"
  s3_key_prefix = "ct-"
}

module "aws_cloudtrail" {
  source                     = "../"
  name                       = local.name
  s3_key_prefix              = local.s3_key_prefix
  enable_log_file_validation = true
  enable_logging             = true
  #protect_cloudtrail         = true
  is_multi_region_trail = false
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
