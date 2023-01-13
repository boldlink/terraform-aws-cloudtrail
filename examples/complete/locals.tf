locals {
  name                = "complete-boldlink-example"
  account_id          = data.aws_caller_identity.current.account_id
  region              = data.aws_region.current.name
  partition           = data.aws_partition.current.partition
  dns_suffix          = data.aws_partition.current.dns_suffix
  external_kms_key_id = aws_kms_key.cloudtrail.arn
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
