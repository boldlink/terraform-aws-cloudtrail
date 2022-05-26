#### NOTE: This example should be run on management account

locals {
  name = "complete-org-trail-example"
}

module "org_cloudtrail" {
  source                     = "../../"
  name                       = local.name
  enable_log_file_validation = true
  bucket_name                = local.name
  trail_name                 = local.name
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
