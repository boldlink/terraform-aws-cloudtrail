provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "dest"
  region = "eu-central-1"
}

module "replication_role" {
  #checkov:skip=CKV_TF_1
  source                = "boldlink/iam-role/aws"
  version               = "1.1.0"
  name                  = "${local.name}-replication-role"
  description           = "S3 replication role"
  assume_role_policy    = local.assume_role_policy
  force_detach_policies = true
  policies = {
    "${local.name}-replication-policy" = {
      policy = local.role_policy
    }
  }
}

module "replication_kms_key" {
  #checkov:skip=CKV_TF_1
  source           = "boldlink/kms/aws"
  version          = "1.1.0"
  description      = "kms key for ${local.replication_bucket}"
  create_kms_alias = true
  alias_name       = "alias/${local.replication_bucket}-key-alias"
  tags             = local.tags

  providers = {
    aws = aws.dest
  }
}

module "replication_bucket" {
  #checkov:skip=CKV_TF_1
  source                 = "boldlink/s3/aws"
  version                = "2.2.0"
  bucket                 = local.replication_bucket
  sse_kms_master_key_arn = module.replication_kms_key.arn
  force_destroy          = true
  tags                   = local.tags

  providers = {
    aws = aws.dest
  }
}

################################################################################################
### Supporting resources for complete example also showing module usage with external KMS Key
################################################################################################
module "kms_key" {
  #checkov:skip=CKV_TF_1
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
  replication_role           = module.replication_role.arn
  tags                       = local.tags
  depends_on                 = [module.kms_key]

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

  replication_configuration = {
    rules = [
      {
        id     = "everything"
        status = "Enabled"

        delete_marker_replication = {
          status = "Enabled"
        }

        destination = {
          bucket        = module.replication_bucket.arn
          storage_class = "STANDARD"

          encryption_configuration = {
            replica_kms_key_id = module.replication_kms_key.arn
          }
        }

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }

          sse_kms_encrypted_objects = {
            status = "Enabled"
          }
        }
      }
    ]
  }
}
