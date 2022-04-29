locals {
  name       = "test-trail"
  account_id = data.aws_caller_identity.current.account_id
}

resource "random_pet" "main" {
  length = 2
}

#####################################################################
### Bucket with policy to ensure it has permissions for cloudtrail
#####################################################################
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${local.name}-${random_pet.main.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket
  policy = data.aws_iam_policy_document.s3.json

  depends_on = [aws_s3_bucket.cloudtrail]
}

module "aws_cloudtrail" {
  source                     = "boldlink/cloudtrail/aws"
  name                       = "${local.name}-${random_pet.main.id}"
  enable_log_file_validation = true
  enable_logging             = true
  trail_name                 = "${local.name}-${random_pet.main.id}"
  use_external_bucket        = true
  s3_bucket_name             = aws_s3_bucket.cloudtrail.bucket
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

  depends_on = [aws_s3_bucket_policy.cloudtrail]

}

output "outputs" {
  value = [
    module.aws_cloudtrail,
  ]
}
