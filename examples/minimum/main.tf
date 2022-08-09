locals {
  name = "minimum-boldlink-example"
}

module "minimum" {
  source = "../../"
  name   = local.name
  tags = {
    environment        = "examples"
    Name               = local.name
    "user::CostCenter" = "terraform-registry"
  }
}
