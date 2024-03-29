### **NOTE**: This example should be run on management account
module "kms_key" {
  source           = "boldlink/kms/aws"
  version          = "1.1.0"
  description      = "kms key for ${var.name}"
  create_kms_alias = true
  kms_policy       = local.org_kms_policy
  alias_name       = "alias/${var.name}-key-alias"
  tags             = local.tags
}

module "trail_bucket" {
  source                 = "boldlink/s3/aws"
  version                = "2.3.0"
  bucket                 = var.name
  bucket_policy          = data.aws_iam_policy_document.org_s3.json
  sse_kms_master_key_arn = module.kms_key.arn
  force_destroy          = true
  tags                   = local.tags
}

module "aws_cloudtrail" {
  source                     = "../../"
  name                       = var.name
  enable_log_file_validation = true
  enable_logging             = true
  kms_key_id                 = module.kms_key.arn
  s3_bucket_name             = module.trail_bucket.bucket
  is_organization_trail      = true
  tags                       = local.tags

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

  insight_selectors = [
    {
      insight_type = "ApiCallRateInsight"
    },
    {
      insight_type = "ApiErrorRateInsight"
    }
  ]
}
