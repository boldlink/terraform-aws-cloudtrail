### **NOTE**: This example should be run on management account

locals {
  name            = "organizational-boldlink-example0"
  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name
  organization_id = data.aws_organizations_organization.current.id
}

#####################################################################
### Bucket with policy to ensure it has permissions for cloudtrail
#####################################################################
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = local.name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket
  policy = data.aws_iam_policy_document.org_s3.json

  depends_on = [aws_s3_bucket.cloudtrail]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.cloudtrail.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "trail_versioning" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

module "aws_cloudtrail" {
  source                     = "../../"
  name                       = local.name
  enable_log_file_validation = true
  enable_logging             = true
  trail_name                 = local.name
  use_external_bucket        = true
  s3_bucket_name             = aws_s3_bucket.cloudtrail.bucket
  is_organization_trail      = true
  protect_cloudtrail         = true
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

  depends_on = [aws_s3_bucket_policy.cloudtrail]

}
