data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_organizations_organization" "current" {} #usage data.aws_organizations_organization.current.id

### Bucket Policy
data "aws_iam_policy_document" "s3" {
  version = "2012-10-17"
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:${local.partition}:s3:::${local.bucket_name}"]
  }
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["arn:${local.partition}:s3:::${local.bucket_name}/AWSLogs/${local.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

####################################################################################
### Organizational S3 bucket
### Note=> Not providing cloudtrail name at `aws:SourceArn` will bring an error
####################################################################################

data "aws_iam_policy_document" "org_s3" {
  version = "2012-10-17"
  statement {
    sid    = "AWSCloudTrailAclCheckOrg"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:${local.partition}:s3:::${local.bucket_name}"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWriteOrg"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["arn:${local.partition}:s3:::${local.bucket_name}/AWSLogs/${local.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWriteOrgSrc"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["arn:${local.partition}:s3:::${local.bucket_name}/AWSLogs/${local.organization_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"]
    }
  }
}

######################
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
  }
}

data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:${local.partition}:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:${local.partition}:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/cloudtrail/${local.name}:*"]
  }
}

data "aws_iam_policy_document" "cloudtrail_protect_scp" {
  statement {
    sid    = "DenyCloudtrailDisable"
    effect = "Deny"
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
    ]
    resources = ["*"]
  }
}

##################################################################################
### Organizational Trail KMS
### Note=> Not providing cloudtrail name at `aws:SourceArn` will bring an error
##################################################################################
data "aws_iam_policy_document" "org_kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM Root Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:${local.partition}:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/${local.trail_name}*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${local.dns_suffix}"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:${local.partition}:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }
  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
  }
  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:${local.partition}:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }
  # KMS permissions for cloudwatch logs
  statement {
    sid = "AllowCloudWatchLogs"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = ["logs.${local.region}.${local.dns_suffix}"]
    }

    resources = ["*"]
  }
}

