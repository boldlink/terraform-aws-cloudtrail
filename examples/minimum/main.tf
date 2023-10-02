module "kms_key" {
  source                  = "boldlink/kms/aws"
  version                 = "1.1.0"
  description             = "Key used to encrypt/decrypt cloudTrail log files stored in S3."
  create_kms_alias        = true
  alias_name              = "alias/${var.name}-key-alias"
  deletion_window_in_days = var.key_deletion_window_in_days
  kms_policy              = local.kms_policy
  tags                    = local.tags
}

module "trail_bucket" {
  source                 = "boldlink/s3/aws"
  version                = "2.3.0"
  bucket                 = var.name
  bucket_policy          = data.aws_iam_policy_document.s3.json
  sse_kms_master_key_arn = module.kms_key.arn
  force_destroy          = true
  tags                   = local.tags
}

module "minimum" {
  source         = "../../"
  name           = var.name
  kms_key_id     = module.kms_key.arn
  s3_bucket_name = module.trail_bucket.id
  tags           = local.tags
}
