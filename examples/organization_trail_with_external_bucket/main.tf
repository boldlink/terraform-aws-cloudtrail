### **NOTE**: This example should be run on management account
module "kms_key" {
  source           = "boldlink/kms/aws"
  description      = "kms key for ${local.name}"
  create_kms_alias = true
  alias_name       = "alias/${local.name}-key-alias"
  tags             = local.tags
}

module "external_bucket" {
  source                 = "boldlink/s3/aws"
  bucket                 = local.name
  bucket_policy          = data.aws_iam_policy_document.org_s3.json
  sse_kms_master_key_arn = module.kms_key.arn
  force_destroy          = true
  tags                   = local.tags
}

module "aws_cloudtrail" {
  source                     = "../../"
  name                       = local.name
  enable_log_file_validation = true
  enable_logging             = true
  trail_name                 = local.name
  use_external_bucket        = true
  s3_bucket_name             = module.external_bucket.bucket
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
}
