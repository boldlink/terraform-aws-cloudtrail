module "aws_cloudtrail" {
  source = "./../../"
  name   = "minimum-cloudtrail"
  other_tags = {
    Organization = "Operations"
    Division     = "DevOps"
    CostCenter   = "TerraformModules"
  }
}
