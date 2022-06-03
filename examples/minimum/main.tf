module "minimum" {
  source = "../../"
  name   = "minimum-boldlink-example0"
  other_tags = {
    Organization = "Operations"
    Division     = "DevOps"
    CostCenter   = "TerraformModules"
  }
}
