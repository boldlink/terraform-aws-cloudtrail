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

data "aws_iam_policy_document" "kms_policy" {
  source_policy_documents = compact([local.kms_policy, var.custom_kms_policy])
}

data "aws_iam_policy_document" "org_kms_policy" {
  source_policy_documents = compact([local.org_kms_policy, var.custom_kms_policy])
}
