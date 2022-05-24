locals {
  name = "non-org-trail-example"
}

resource "random_pet" "main" {
  length = 2
}

module "aws_cloudtrail" {
  source                     = "../../"
  name                       = "${local.name}-${random_pet.main.id}"
  enable_log_file_validation = true
  bucket_name                = "${local.name}-${random_pet.main.id}"
  trail_name                 = "${local.name}-${random_pet.main.id}"
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
