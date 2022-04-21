#######################################################
### Cloud Trail
#######################################################
resource "aws_cloudtrail" "main" {
  name           = "${var.name}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id

  s3_key_prefix                 = var.s3_key_prefix
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # CloudTrail requires the Log Stream wildcard
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_role.arn
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  sns_topic_name                = var.sns_topic_name

  ##### Use ONLY ONE of either event_selector or advanced_event_selector
  ##### Basic event selector resource types, i.e, set using `event_selector` block: `AWS::S3::Object`, `AWS::Lambda::Function`, `AWS::DynamoDB::Table`
  ##### Basic event selector resource types are valid in advanced event selectors, but advanced event selector resource types are not valid in basic event selectors.
  ##### https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      read_write_type                  = lookup(event_selector.value, "read_write_type", "All")
      include_management_events        = lookup(event_selector.value, "include_management_events", true)
      exclude_management_event_sources = lookup(event_selector.value, "exclude_management_event_sources", null)
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
  depends_on = [
    aws_kms_key.cloudtrail,
    aws_cloudwatch_log_group.cloudtrail
  ]
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.name}-cloudtrail-bucket"
  force_destroy = var.s3_bucket_force_destroy
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.s3.json
}

#########################################
### Cloudwatch Resources
#########################################
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${var.name}-main-cloudtrail-log-group"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.cloudtrail.arn
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name               = "${var.name}-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name   = "cloudtrail-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}

resource "aws_iam_policy_attachment" "main" {
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs.arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch_role.name]
}

resource "aws_kms_key" "cloudtrail" {
  description             = "Key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
  tags = merge(
    {
      "Name"        = "${var.name}-cloudtrail-kms-key"
      "Environment" = var.environment
    },
    var.other_tags,
  )
}

#########################################
### SCP
#########################################
resource "aws_organizations_policy" "main" {
  count       = var.protect_cloudtrail ? 1 : 0
  name        = "${var.name}-organization-policy-for-cloudtrail"
  content     = data.aws_iam_policy_document.cloudtrail_protect_scp.json
  description = "Policy to deny the deletion/disabling of cloudtrail"
  tags = merge(
    {
      "Name"        = "${var.name}-cloudtrail-scp"
      "Environment" = var.environment
    },
    var.other_tags,
  )
}
