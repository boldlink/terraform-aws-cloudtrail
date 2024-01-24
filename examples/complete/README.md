[![License](https://img.shields.io/badge/License-Apache-blue.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/release/boldlink/terraform-aws-cloudtrail.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/releases/latest)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/update.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/release.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/pr-labeler.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/module-examples-tests.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/checkov.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/auto-merge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)
[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/auto-badge.yaml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# Example showing the complete configuration for an organization trail


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cloudtrail"></a> [aws\_cloudtrail](#module\_aws\_cloudtrail) | ../../ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | boldlink/kms/aws | 1.1.0 |
| <a name="module_trail_bucket"></a> [trail\_bucket](#module\_trail\_bucket) | boldlink/s3/aws | 2.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.org_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the stack | `string` | `"complete-trail-example"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | <pre>{<br>  "Department": "DevOps",<br>  "Environment": "example",<br>  "LayerId": "cExample",<br>  "LayerName": "cExample",<br>  "Owner": "Boldlink",<br>  "Project": "Examples",<br>  "user::CostCenter": "terraform-registry"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Third party software
This repository uses third party software:
* [pre-commit](https://pre-commit.com/) - Used to help ensure code and documentation consistency
  * Install with `brew install pre-commit`
  * Manually use with `pre-commit run`
* [terraform 0.14.11](https://releases.hashicorp.com/terraform/0.14.11/) For backwards compatibility we are using version 0.14.11 for testing making this the min version tested and without issues with terraform-docs.
* [terraform-docs](https://github.com/segmentio/terraform-docs) - Used to generate the [Inputs](#Inputs) and [Outputs](#Outputs) sections
  * Install with `brew install terraform-docs`
  * Manually use via pre-commit
* [tflint](https://github.com/terraform-linters/tflint) - Used to lint the Terraform code
  * Install with `brew install tflint`
  * Manually use via pre-commit

### Makefile
The makefile contain in this repo is optimised for linux paths and the main purpose is to execute testing for now.
* Create all tests:
`$ make tests`
* Clean all tests:
`$ make clean`

#### BOLDLink-SIG 2024
