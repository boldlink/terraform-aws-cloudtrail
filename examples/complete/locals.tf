locals {
  name                = "complete-boldlink-example"
  account_id          = data.aws_caller_identity.current.account_id
  region              = data.aws_region.current.name
  partition           = data.aws_partition.current.partition
  dns_suffix          = data.aws_partition.current.dns_suffix
  external_kms_key_id = aws_kms_key.cloudtrail.arn
  kms_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [{
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          "AWS" = ["arn:${local.partition}:iam::${local.account_id}:root"]
        }
        Action   = ["kms:*"]
        Resource = ["*"]
        },
        {
          Sid    = "Allow CloudTrail to encrypt logs"
          Effect = "Allow"
          Principal = {
            Service = ["cloudtrail.${local.dns_suffix}"]
          }
          Action   = ["kms:GenerateDataKey*"]
          Resource = ["*"]
          Condition = {
            StringLike = {
              "kms:EncryptionContext:${local.partition}:cloudtrail:arn" = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
            }
          }
        },
        {
          Sid    = "Allow CloudTrail to describe key"
          Effect = "Allow"
          Principal = {
            Service = ["cloudtrail.${local.dns_suffix}"]
          }
          Action   = ["kms:DescribeKey"]
          Resource = ["*"]
        },
        {
          Sid    = "Allow principals in the account to decrypt log files"
          Effect = "Allow"
          Principal = {
            AWS = ["*"]
          }
          Action = [
            "kms:Decrypt",
            "kms:ReEncryptFrom"
          ]
          Resource = ["*"]
          Condition = {
            StringEquals = {
              "kms:CallerAccount" = [local.account_id]
            }
          }
          Condition = {
            StringLike = {
              "kms:EncryptionContext:${local.partition}:cloudtrail:arn" = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
            }
          }
        },
        {
          Sid = "AllowCloudWatchLogs"
          Action = [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
          ]
          Effect = "Allow"
          Principal = {
            Service = ["logs.${local.region}.${local.dns_suffix}"]
          }
          Resource = ["*"]
          Condition = {
            ArnLike = {
              "kms:EncryptionContext:aws:logs:arn" = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/cloudtrail/${local.name}"]
            }
          }
        },
        {
          Sid    = "Allow alias creation during setup"
          Effect = "Allow"
          Principal = {
            "AWS" = ["*"]
          }
          Action   = ["kms:CreateAlias"]
          Resource = ["*"]
        }
  ] })

  tags = {
    Environment        = "example"
    Name               = local.name
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}
