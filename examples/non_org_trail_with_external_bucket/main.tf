locals {
  name          = "account-api-trailz"
  s3_bucket_name = "trail-logs-berket" ### Make sure provided bucket exists
  bucket_name   = "cloudtrail-bkt-boldlink"
}

#######################################################
### Bucket policy to ensure the external
### bucket has permissions for cloudtrail
#######################################################
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = local.s3_bucket_name
  policy = data.aws_iam_policy_document.s3.json
}

module "aws_cloudtrail" {
  source                     = "boldlink/cloudtrail/aws"
  name                       = local.name
  enable_log_file_validation = true
  enable_logging             = true
  s3_bucket_name             = local.s3_bucket_name
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
