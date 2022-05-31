########################################################
### Cloud Trail
########################################################
resource "aws_cloudtrail" "main" {
  name                          = local.trail_name
  s3_bucket_name                = var.use_external_bucket ? var.s3_bucket_name : aws_s3_bucket.cloudtrail[0].id
  s3_key_prefix                 = var.s3_key_prefix
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # CloudTrail requires the Log Stream wildcard
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch.arn
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = var.use_external_kms_key_id ? var.external_kms_key_id : aws_kms_key.cloudtrail[0].arn
  sns_topic_name                = var.sns_topic_name

  ##### Use ONLY ONE of either event_selector or advanced_event_selector
  ##### Basic event selector resource types, i.e, set using `event_selector` block: `AWS::S3::Object`, `AWS::Lambda::Function`, `AWS::DynamoDB::Table`
  ##### Basic event selector resource types are valid in advanced event selectors, but advanced event selector resource types are not valid in basic event selectors.
  ##### https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html

  dynamic "event_selector" {
    for_each = length(var.advanced_event_selectors) > 0 ? null : var.event_selectors
    content {
      read_write_type                  = lookup(event_selector.value, "read_write_type", "All")
      include_management_events        = lookup(event_selector.value, "include_management_events", true)
      exclude_management_event_sources = lookup(event_selector.value, "include_management_events", null) == true ? lookup(event_selector.value, "exclude_management_event_sources", null) : null
      dynamic "data_resource" {
        for_each = try([event_selector.value.data_resource], [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }
  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selectors
    content {
      name = lookup(advanced_event_selector.value, "", null)
      dynamic "field_selector" {
        for_each = try([advanced_event_selector.value.field_selector], [])
        content {
          field           = field_selector.value.field
          equals          = lookup(field_selector.value, "equals", null)
          not_equals      = lookup(field_selector.value, "not_equals", null)
          starts_with     = lookup(field_selector.value, "starts_with", null)
          not_starts_with = lookup(field_selector.value, "not_starts_with", null)
          ends_with       = lookup(field_selector.value, "ends_with", null)
          not_ends_with   = lookup(field_selector.value, "not_ends_with", null)
        }
      }
    }
  }

  dynamic "insight_selector" {
    for_each = var.insight_selector
    content {
      insight_type = lookup(insight_type.value, "insight_type", null) #Valid values are: `ApiCallRateInsight` and `ApiErrorRateInsight`.
    }
  }
  lifecycle {
    ignore_changes = [event_selector]
  }
  tags = merge(
    {
      "Name"        = local.trail_name
      "Environment" = var.environment
    },
    var.other_tags,
  )
  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
resource "aws_s3_bucket" "cloudtrail" {
  count         = var.use_external_bucket ? 0 : 1
  bucket        = local.bucket_name
  force_destroy = var.s3_bucket_force_destroy
  tags = merge(
    {
      "Name"        = local.name
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.use_external_bucket ? 0 : 1
  bucket = aws_s3_bucket.cloudtrail[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.use_external_kms_key_id ? var.external_kms_key_id : aws_kms_key.cloudtrail[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.use_external_bucket ? 0 : 1
  bucket = aws_s3_bucket.cloudtrail[0].id
  policy = var.is_organization_trail && var.use_external_bucket == false ? data.aws_iam_policy_document.org_s3.json : data.aws_iam_policy_document.s3.json
}

resource "aws_s3_bucket_public_access_block" "example" {
  count                   = var.use_external_bucket ? 0 : 1
  bucket                  = aws_s3_bucket.cloudtrail[0].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "trail_versioning" {
  count  = var.use_external_bucket ? 0 : 1
  bucket = aws_s3_bucket.cloudtrail[0].id
  versioning_configuration {
    status = var.trail_bucket_versioning_enabled
  }
}

#########################################
### Cloudwatch Resources
#########################################
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${local.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.use_external_kms_key_id ? aws_kms_key.cloudwatch[0].arn : aws_kms_key.cloudtrail[0].arn
  tags = merge(
    {
      "Name"        = local.name
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
  tags = merge(
    {
      "Name"        = local.name
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

resource "aws_iam_policy" "cloudtrail_cloudwatch" {
  name   = "${local.name}-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
  tags = merge(
    {
      "Name"        = local.name
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       = "${local.name}-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch.arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch.name]
}

###############################################
### When cloudtrail external key is specified
###############################################
resource "aws_kms_key" "cloudwatch" {
  count                   = var.use_external_kms_key_id ? 1 : 0
  description             = "Key used to encrypt cloudwatch logs when external  kms for cloudtrail is specified."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = var.is_organization_trail ? data.aws_iam_policy_document.org_kms.json : data.aws_iam_policy_document.kms.json
  tags = merge(
    {
      "Name"        = "${local.name}-kms-key"
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

resource "aws_kms_alias" "cloudwatch" {
  count         = var.use_external_kms_key_id ? 1 : 0
  name          = "alias/cloudwatch/${local.name}"
  target_key_id = aws_kms_key.cloudwatch[0].arn
}

#############################################
## Trail KMS Resources
#############################################

resource "aws_kms_key" "cloudtrail" {
  count                   = var.use_external_kms_key_id ? 0 : 1
  description             = "Key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = var.is_organization_trail ? data.aws_iam_policy_document.org_kms.json : data.aws_iam_policy_document.kms.json
  tags = merge(
    {
      "Name"        = "${local.name}-kms-key"
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

resource "aws_kms_alias" "cloudtrail" {
  count         = var.use_external_kms_key_id ? 0 : 1
  name          = "alias/cloudtrail/${local.name}"
  target_key_id = aws_kms_key.cloudtrail[0].arn
}

#########################################
### SCP=> Applied in root org account
#########################################
resource "aws_organizations_policy" "main" {
  count       = var.protect_cloudtrail ? 1 : 0
  name        = "${local.name}-organization-policy"
  content     = data.aws_iam_policy_document.cloudtrail_protect_scp.json
  description = "Policy to deny the deletion/disabling ${local.name} cloudtrail"
  tags = merge(
    {
      "Name"        = "${local.name}-scp"
      "Environment" = var.environment
    },
    var.other_tags,
  )
}
