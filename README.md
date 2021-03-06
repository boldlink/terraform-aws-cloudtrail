[![Build Status](https://github.com/boldlink/terraform-aws-cloudtrail/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/boldlink/terraform-aws-cloudtrail/actions)

[<img src="https://avatars.githubusercontent.com/u/25388280?s=200&v=4" width="96"/>](https://boldlink.io)

# AWS Cloudtrail Terraform module

## Description

This terraform module creates an AWS Cloudtrail, KMS, S3 bucket, organization policy to protect the cloudtrail and IAM roles for the cloudtrail.

Examples available [here](https://github.com/boldlink/terraform-aws-cloudtrail/tree/main/examples/)

## Usage
*Points to Note*:
- These examples use the latest version of this module
- If you want to use an existing CMK KMS key for trails encryption/decryption, provide the `ARN` of the key to the variable `external_kms_key_id` e.g `external_kms_key_id = <KEY_ARN_HERE>`. The key must have the required permissions for this stack to succeed.

```hcl
module "minimum" {
  source = "../../"
  name   = "minimum_trail-boldlink-example"
  other_tags = {
    Organization = "Operations"
    Division     = "DevOps"
    CostCenter   = "TerraformModules"
  }
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.22.0 |

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
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.trail_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.org_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.org_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_event_selectors"></a> [advanced\_event\_selectors](#input\_advanced\_event\_selectors) | (Optional) Specifies an advanced event selector for enabling data event logging. Conflicts with `event_selector`. | `any` | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the cloudtrail logging bucket | `string` | `""` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | (Optional) Whether log file integrity validation is enabled. Defaults to `false`. | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | (Optional) Enables logging for the trail. Defaults to `true`. Setting this to false will pause logging. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where you are creating the resources | `string` | `"staging"` | no |
| <a name="input_event_selectors"></a> [event\_selectors](#input\_event\_selectors) | (Optional) Specifies an event selector for enabling data event logging. | `any` | `[]` | no |
| <a name="input_external_kms_key_id"></a> [external\_kms\_key\_id](#input\_external\_kms\_key\_id) | Enter KMS ARN for the external Key that will be used for encrypting/decrypting trail logs. | `string` | `null` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | (Optional) Whether the trail is publishing events from global services such as IAM to the log files. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_insight_selector"></a> [insight\_selector](#input\_insight\_selector) | (Optional) Configuration block for identifying unusual operational activity. | `map(string)` | `{}` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | (Optional) Whether the trail is created in the current region or in all regions. Defaults to `false` | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | (Optional) Whether the trail is an AWS Organizations trail. | `bool` | `false` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. | `number` | `7` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `1827` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the stack | `string` | n/a | yes |
| <a name="input_other_tags"></a> [other\_tags](#input\_other\_tags) | Other map of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_s3_bucket_force_destroy"></a> [s3\_bucket\_force\_destroy](#input\_s3\_bucket\_force\_destroy) | A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `true` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket designated for publishing log files. | `string` | `null` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | (Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery. | `string` | `null` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | (Optional) Name of the Amazon SNS topic defined for notification of log file delivery. | `string` | `null` | no |
| <a name="input_trail_bucket_versioning_enabled"></a> [trail\_bucket\_versioning\_enabled](#input\_trail\_bucket\_versioning\_enabled) | Specify whether to enable versioning for the trail bucket. Valid values are "Enabled" and "Disabled". | `string` | `"Enabled"` | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | Name for the cloudtrail | `string` | `""` | no |
| <a name="input_use_external_bucket"></a> [use\_external\_bucket](#input\_use\_external\_bucket) | Choose whether to use an external bucket. | `bool` | `false` | no |
| <a name="input_use_external_kms_key_id"></a> [use\_external\_kms\_key\_id](#input\_use\_external\_kms\_key\_id) | Choose whether to use external KMS Key for trails encryption and decryption. | `bool` | `false` | no |

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

### Makefile
The makefile contain in this repo is optimised for linux paths and the main purpose is to execute testing for now.
* Create all tests:
`$ make tests`
* Clean all tests:
`$ make clean`

#### BOLDLink-SIG 2022
