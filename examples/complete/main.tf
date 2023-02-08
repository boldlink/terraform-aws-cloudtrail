################################################################################################
### Supporting resources for complete example also showing module usage with external KMS Key
################################################################################################
module "kms_key" {
  source                  = "boldlink/kms/aws"
  version                 = "1.1.0"
  description             = "Key used to encrypt/decrypt cloudTrail log files stored in S3."
  create_kms_alias        = true
  alias_name              = "alias/${local.name}-key-alias"
  deletion_window_in_days = var.key_deletion_window_in_days
  kms_policy              = local.kms_policy
  tags                    = local.tags
}

module "complete" {
  source                     = "../../"
  name                       = local.name
  enable_log_file_validation = true
  use_external_kms_key_id    = true
  external_kms_key_id        = local.external_kms_key_id
  bucket_name                = local.name
  trail_name                 = local.name
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

  insight_selectors = [
    {
      insight_type = "ApiCallRateInsight"
    },
    {
      insight_type = "ApiErrorRateInsight"
    }
  ]

  tags = local.tags

  depends_on = [module.kms_key]
}
