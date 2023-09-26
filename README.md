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

# AWS Cloudtrail Terraform module

## Description

This terraform module creates an AWS Cloudtrail and cloudwatch resources associated with the trail

### Why choose this module over the standard resources

- Ability to create associated cloudtrail resources with minimum configuration changes.
- Follows aws security best practices and uses checkov to ensure compliance.
- Has elaborate examples that you can use to setup cloudtrail within a very short time.

Examples available [here](./examples/)

## Usage
**Note:**
- These examples use the latest version of this module
- Release `1.3.0` brings breaking changes. One has to provide a well configured S3 bucket with the required bucket policy. If a AWS CMK key is used it should also be correctly configured. Check examples for more.

```hcl
module "kms_key" {
  source                  = "boldlink/kms/aws"
  version                 = "1.1.0"
  description             = "Key used to encrypt/decrypt cloudTrail log files stored in S3."
  create_kms_alias        = true
  alias_name              = "alias/${var.name}-key-alias"
  deletion_window_in_days = var.key_deletion_window_in_days
  kms_policy              = local.kms_policy
  tags                    = local.tags
}

module "trail_bucket" {
  source                 = "boldlink/s3/aws"
  version                = "2.3.0"
  bucket                 = var.name
  bucket_policy          = data.aws_iam_policy_document.s3.json
  sse_kms_master_key_arn = module.kms_key.arn
  force_destroy          = true
  tags                   = local.tags
}

module "minimum" {
  source         = "../../"
  name           = var.name
  kms_key_id     = module.kms_key.arn
  s3_bucket_name = module.trail_bucket.id
  tags           = local.tags
}
```
## Documentation

[AWS Cloudtrail documentation](https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/Welcome.html)

[Terraform provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.cloudtrail_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.cloudtrail_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_event_selectors"></a> [advanced\_event\_selectors](#input\_advanced\_event\_selectors) | (Optional) Specifies an advanced event selector for enabling data event logging. Conflicts with `event_selector`. | `any` | `[]` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | (Optional) Whether log file integrity validation is enabled. Defaults to `false`. | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | (Optional) Enables logging for the trail. Defaults to `true`. Setting this to false will pause logging. | `bool` | `true` | no |
| <a name="input_event_selectors"></a> [event\_selectors](#input\_event\_selectors) | (Optional) Specifies an event selector for enabling data event logging. | `any` | `[]` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | (Optional) Whether the trail is publishing events from global services such as IAM to the log files. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_insight_selectors"></a> [insight\_selectors](#input\_insight\_selectors) | (Optional) Configuration block for identifying unusual operational activity. | `any` | `[]` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | (Optional) Whether the trail is created in the current region or in all regions. Defaults to `false` | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | (Optional) Whether the trail is an AWS Organizations trail. | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Enter KMS ARN for the Key that will be used for encrypting/decrypting trail logs. | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `1827` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the stack | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket designated for publishing log files. | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | (Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery. | `string` | `null` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | (Optional) Name of the Amazon SNS topic defined for notification of log file delivery. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the trail. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the trail. |
| <a name="output_home_region"></a> [home\_region](#output\_home\_region) | Region in which the trail was created. |
| <a name="output_id"></a> [id](#output\_id) | Name of the trail. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource |
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

### Supporting resources:

The example stacks are used by BOLDLink developers to validate the modules by building an actual stack on AWS.

Some of the modules have dependencies on other modules (ex. Ec2 instance depends on the VPC module) so we create them
first and use data sources on the examples to use the stacks.

Any supporting resources will be available on the `tests/supportingResources` and the lifecycle is managed by the `Makefile` targets.

Resources on the `tests/supportingResources` folder are not intended for demo or actual implementation purposes, and can be used for reference.

### Makefile
The makefile contained in this repo is optimized for linux paths and the main purpose is to execute testing for now.
* Create all tests stacks including any supporting resources:
```console
make tests
```
* Clean all tests *except* existing supporting resources:
```console
make clean
```
* Clean supporting resources - this is done separately so you can test your module build/modify/destroy independently.
```console
make cleansupporting
```
* !!!DANGER!!! Clean the state files from examples and test/supportingResources - use with CAUTION!!!
```console
make cleanstatefiles
```


#### BOLDLink-SIG 2023
