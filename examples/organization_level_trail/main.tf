#### NOTE: This example should be run on management account

locals {
  name = "test-trail"
}

resource "random_pet" "main" {
  length = 2
}

module "org_cloudtrail" {
  source                     = "boldlink/cloudtrail/aws"
  name                       = "${local.name}-${random_pet.main.id}"
  enable_log_file_validation = true
  bucket_name                = "${local.name}-${random_pet.main.id}"
  trail_name                 = "${local.name}-${random_pet.main.id}"
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
