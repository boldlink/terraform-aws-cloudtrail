module "minimum" {
  source = "../../"
  name   = "minimum-boldlink-example"
  other_tags = {
    Organization = "Operations"
    Division     = "DevOps"
    CostCenter   = "TerraformModules"
  }
}
