locals {
  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name
  organization_id = data.aws_organizations_organization.current.id
  partition       = data.aws_partition.current.partition
  dns_suffix      = data.aws_partition.current.dns_suffix
  tags            = merge({ "Name" = var.name }, var.tags)

  org_kms_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
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
            AWS = ["arn:${local.partition}:iam::${local.account_id}:root"]
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
              "kms:EncryptionContext:aws:logs:arn" = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/cloudtrail/${var.name}"]
            }
          }
        },
        {
          Sid    = "Allow alias creation during setup"
          Effect = "Allow"
          Principal = {
            "AWS" = ["arn:${local.partition}:iam::${local.account_id}:root"]
          }
          Action   = ["kms:CreateAlias"]
          Resource = ["*"]
        },
        {
          Sid    = "Enable cross account log decryption"
          Effect = "Allow"
          Principal = {
            "AWS" = ["arn:${local.partition}:iam::${local.account_id}:root"]
          }
          Action = [
            "kms:Decrypt",
            "kms:ReEncryptFrom"
          ]
          Resource = ["*"]
          Condition = {
            StringEquals = { "kms:CallerAccount" = [local.account_id] }
          }
          Condition = {
            StringLike = { "kms:EncryptionContext:${local.partition}:cloudtrail:arn" = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"] }
          }
        }
  ] })
}
