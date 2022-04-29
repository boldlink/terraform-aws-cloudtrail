locals {
  name            = var.name
  bucket_name     = var.bucket_name
  trail_name      = var.trail_name
  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name
  organization_id = data.aws_organizations_organization.current.id
  partition       = data.aws_partition.current.partition
}
