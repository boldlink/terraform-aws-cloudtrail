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
    for_each = length(var.advanced_event_selectors) > 0 ? [] : var.event_selectors
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
      name = advanced_event_selector.value.name

      dynamic "field_selector" {
        for_each = lookup(advanced_event_selector.value, "field_selectors", null)
        content {
          field           = field_selector.value.field
          equals          = try(field_selector.value.equals, null)
          not_equals      = try(field_selector.value.not_equals, null)
          starts_with     = try(field_selector.value.starts_with, null)
          not_starts_with = try(field_selector.value.not_starts_with, null)
          ends_with       = try(field_selector.value.ends_with, null)
          not_ends_with   = try(field_selector.value.not_ends_with, null)
        }
      }
    }
  }

  dynamic "insight_selector" {
    for_each = var.insight_selectors
    content {
      insight_type = try(insight_selector.value.insight_type, null) #Valid values are: `ApiCallRateInsight` and `ApiErrorRateInsight`.
    }
  }

  lifecycle {
    ignore_changes = [event_selector]
  }

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

resource "aws_s3_bucket" "cloudtrail" {
  count         = var.use_external_bucket ? 0 : 1
  bucket        = local.bucket_name
  force_destroy = var.s3_bucket_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_logging" "cloudtrail" {
  count                 = length(var.s3_bucket_logging) == 0 || var.use_external_bucket ? 0 : 1
  bucket                = aws_s3_bucket.cloudtrail[0].id
  target_bucket         = var.s3_bucket_logging["target_bucket"]
  target_prefix         = var.s3_bucket_logging["target_prefix"]
  expected_bucket_owner = try(var.s3_bucket_logging["expected_bucket_owner"], null)
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

### S3 Buckets only support a single replication configuration
resource "aws_s3_bucket_replication_configuration" "main" {
  count = length(keys(var.replication_configuration)) > 0 && var.use_external_bucket == false ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id
  token  = try(var.replication_configuration["token"], null)
  role   = var.replication_role

  dynamic "rule" {
    for_each = lookup(var.replication_configuration, "rules", [])
    content {

      id       = try(rule.value.id, null)
      prefix   = try(rule.value.prefix, null)
      priority = try(rule.value.priority, null)

      status = "Enabled"

      dynamic "delete_marker_replication" {
        for_each = try([rule.value.delete_marker_replication], [])
        content {
          status = delete_marker_replication.value.status
        }
      }

      dynamic "destination" {
        for_each = try([rule.value.destination], [])
        content {
          account       = try(destination.value.account, null)
          bucket        = destination.value.bucket
          storage_class = try(destination.value.storage_class, null)

          dynamic "access_control_translation" {
            for_each = try([destination.value.access_control_translation], [])
            content {
              owner = access_control_translation.value.owner
            }
          }

          dynamic "encryption_configuration" {
            for_each = try([destination.value.encryption_configuration], [])
            content {
              replica_kms_key_id = encryption_configuration.value.replica_kms_key_id
            }
          }

          dynamic "metrics" {
            for_each = try([destination.value.metrics], [])
            content {
              status = metrics.value.status

              dynamic "event_threshold" {
                for_each = try([metrics.value.event_threshold], [])
                content {
                  minutes = event_threshold.value.minutes
                }
              }
            }
          }

          dynamic "replication_time" {
            for_each = try([destination.value.replication_time], [])
            content {
              status = replication_time.value.status

              dynamic "time" {
                for_each = replication_time.value.time
                content {
                  minutes = time.value.minutes
                }
              }
            }
          }
        }
      }

      dynamic "filter" {
        for_each = try(flatten([rule.value.filter]), []) != [] ? try(flatten([rule.value.filter]), []) : []

        content {
          prefix = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try([filter.value.tag], [])

            content {
              key   = try(tag.value.key, null)
              value = try(tag.value.value, null)
            }
          }
        }
      }

      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) > 0 ? [] : [true]
        content {
        }
      }

      dynamic "filter" {
        for_each = try([rule.value.filter.and.tags], [rule.value.filter.and.prefix], []) != [] ? try(flatten([rule.value.filter]), []) : []
        content {
          and {
            prefix = try(rule.value.filter.and.prefix, null)
            tags   = try(rule.value.filter.and.tags, null)
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = try([rule.value.source_selection_criteria], [])
        content {

          dynamic "replica_modifications" {
            for_each = try([source_selection_criteria.value.replica_modifications], [])
            content {
              status = replica_modifications.value.status
            }
          }

          dynamic "sse_kms_encrypted_objects" {
            for_each = try([source_selection_criteria.value.sse_kms_encrypted_objects], [])
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }

      dynamic "existing_object_replication" {
        for_each = try([rule.value.existing_object_replication], [])
        content {
          status = existing_object_replication.value.status
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.trail_versioning]
}

#########################################
### Cloudwatch Resources
#########################################
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${local.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.use_external_kms_key_id ? var.external_kms_key_id : aws_kms_key.cloudtrail[0].arn
  tags              = var.tags
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
  tags               = var.tags
}

resource "aws_iam_policy" "cloudtrail_cloudwatch" {
  name   = "${local.name}-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
  tags   = var.tags
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       = "${local.name}-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch.arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch.name]
}

#############################################
## Trail KMS Resources
#############################################

resource "aws_kms_key" "cloudtrail" {
  count                   = var.use_external_kms_key_id ? 0 : 1
  description             = "Key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = var.is_organization_trail ? local.org_kms_policy : local.kms_policy
  tags                    = var.tags
}

resource "aws_kms_alias" "cloudtrail" {
  count         = var.use_external_kms_key_id ? 0 : 1
  name          = "alias/cloudtrail/${local.name}"
  target_key_id = aws_kms_key.cloudtrail[0].arn
}
