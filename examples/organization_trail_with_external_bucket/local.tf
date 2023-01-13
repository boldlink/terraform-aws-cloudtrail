locals {
  name            = "organizational-boldlink-example"
  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name
  organization_id = data.aws_organizations_organization.current.id
  tags = {
    Environment        = "example"
    Name               = local.name
    "user::CostCenter" = "terraform-registry"
    Department         = "DevOps"
    Project            = "Examples"
    Owner              = "Boldlink"
    LayerName          = "cExample"
    LayerId            = "cExample"
  }
}
