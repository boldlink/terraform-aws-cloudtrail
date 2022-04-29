locals {
  name = "test-trail"
}

resource "random_pet" "main" {
  length = 2
}

module "aws_cloudtrail" {
  source                     = "boldlink/cloudtrail/aws"
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

output "outputs" {
  value = [
    module.aws_cloudtrail,
  ]
}
