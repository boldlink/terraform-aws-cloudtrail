locals {
  name        = "account0-api-trailz0"
  bucket_name = "cloudtrail-bkt-boldlink010"
}

module "org_cloudtrail" {
  source = "boldlink/cloudtrail/aws"
  name                       = local.name
  enable_log_file_validation = true
  bucket_name                = local.bucket_name
  is_organization_trail      = true
  protect_cloudtrail         = true ## Protects against disabling cloudtrail
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
    module.org_cloudtrail,
  ]
}
