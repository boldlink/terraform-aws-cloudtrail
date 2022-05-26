locals {
  name = "non-organization-trail-example"
}

module "aws_cloudtrail" {
  source                     = "../../"
  name                       = local.name
  enable_log_file_validation = true
  bucket_name                = local.name
  trail_name                 = local.name
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
