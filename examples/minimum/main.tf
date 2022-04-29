locals {
  name          = "account-api-trailz"
  s3_key_prefix = "cloudtrails"
  bucket_name   = "cloudtrail-bkt-boldlink"
}

module "aws_cloudtrail" {
  source                     = "./../../"
  name                       = local.name
  other_tags = {
    Organization = "Operations"
    Division = "DevOps"
    CostCenter = "TerraformModules"
  }
}

output "outputs" {
  value = [
    module.aws_cloudtrail,
  ]
}
