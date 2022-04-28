locals {
  name          = "account-api-trailz"
  s3_key_prefix = "cloudtrails"
  bucket_name   = "cloudtrail-bkt-boldlink"
}

module "aws_cloudtrail" {
  source                     = "boldlink/cloudtrail/aws"
  name                       = local.name
  s3_key_prefix              = local.s3_key_prefix
  enable_log_file_validation = true
  bucket_name                = local.bucket_name
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

output "outputs" {
  value = [
    module.aws_cloudtrail,
  ]
}
