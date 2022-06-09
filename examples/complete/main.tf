################################################################################################
### Supporting resources for complete example also showing module usage with external KMS Key
################################################################################################
resource "aws_kms_key" "cloudtrail" {
  description             = "Key used to encrypt/decrypt cloudTrail log files stored in S3."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail/${local.name}"
  target_key_id = aws_kms_key.cloudtrail.arn
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

  depends_on = [aws_kms_key.cloudtrail]
}
