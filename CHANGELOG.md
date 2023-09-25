# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Facilitate encryption and decryption capabilities using the module KMS key for roles and users with limited privileges.
- Add: `advanced_event_selector` in examples
- Allow overwriting the default KMS Policies
- Restrict user/groups to access the cloudtrails config and logs on cw and s3
- Add the option to replicate the s3 logs to a different account for org and non-org (s3 replication rule - requires a kms key on the destination account)
- Extend s3 configuration to add a lifecycle rule to archive 5y of data (discuss what should be the defaults) for both the local and replicated s3 bucket if enabled

## [1.3.0] - 2023-09-25
- feat: Removed S3 resources so that bucket will be provided via variable.
- feat: Removed kms resources so that AWS CMK key ARN will be provided via variables
- feat: Locked aws provider version to prevent s3 errors as a result of using aws provider version 5.17.0. Will be unlocked in a later version
- fix: CKV2_AWS_61 #"Ensure that an S3 bucket has a lifecycle configuration"
- fix: CKV2_AWS_62 #"Ensure S3 buckets should have event notifications enabled"
- fix: CKV_AWS_21 #"Ensure all data stored in the S3 bucket have versioning enabled"
- fix: CKV_AWS_18 #"Ensure the S3 bucket has access logging enabled
- fix: CKV_AWS_144 #"Ensure that S3 bucket has cross-region replication enabled"
- fix: CKV2_AWS_6 #"Ensure that S3 bucket has a Public Access block"
- fix: CKV_AWS_145 #"Ensure that S3 buckets are encrypted with KMS by default"

## [1.2.4] - 2023-08-16
- fix: CKV_TF_1 "Ensure Terraform module sources use a commit hash"

## [1.2.3] - 2023-02-07
- fix: CKV_AWS_33: "Ensure KMS key policy does not contain wildcard (*) principal"
- fix: CKV_AWS_109: Ensure IAM policies does not allow permissions management / resource exposure without constraints
- fix: CKV_AWS_144: Ensure that S3 bucket has cross-region replication enabled
- fix: CKV_AWS_18: Ensure the S3 bucket has access logging enabled.
- fix: CKV_AWS_145: Ensure that S3 buckets are encrypted with KMS by default. NOTE:: Resource for this feature not currently detected by checkov though buckets are encrypted.
- feat: Used upgraded S3 module for external bucket example (organization trail).


## [1.2.2] - 2023-01-25
- fix: CKV_AWS_111 Ensure IAM policies does not allow write access without constraints

## [1.2.1] - 2023-01-12
### Changes
- fix: CKV_AWS_18 Ensure the S3 bucket has access logging enabled

## [1.2.0] - 2022-08-08
### Changes
- fix: error resulting from insights selector usage
- feat: ability to use multiple insight selectors
- feat: ability to use multiple `field_selectors` in `advanced_event_selector`
- feat: modified tags variables

## [1.1.1] - 2022-07-18
### Changes
- Remove `aws_organizations_policy` because non_organization trail deployed in management account is not visible in member accounts, organization trail is protected by default against deletion from member accounts (organization units) and SCPs don't have effect on the users in the management account, hence the resource would be redundant to be included in the module.

## [1.1.0] - 2022-06-07
### Added
- Added External KMS Support (providing an external KMS key for the trail instead of creating using module)
- Added the `.github/workflow` folder (not supposed to run gitcommit)
- Re-factored examples (`minimum`, `complete` and additional)
- Added `CHANGELOG.md`
- Added `CODEOWNERS`
- Added `versions.tf`, which is important for pre-commit checks
- Added `Makefile` for examples automation
- Added `.gitignore` file

### Features
- Feature: Ability to create organizational trail
- Feature: SCP to protect the trail from deletion
- Feature: Introduced public accessibility control for trail S3 bucket
- Feature: Ensure S3 buckets have versioning enabled and that objects at rest are encrypted
- Feature: The necessary IAM policy required to create an organizational trail

### Changes/Fixes
- Modified `data.tf` to include both KMS and S3 policy statements for organizational trail

## [1.0.0] - 2022-04-21

### Added
- Initial commit

[Unreleased]: https://github.com/boldlink/terraform-aws-cloudtrail/compare/1.2.5...HEAD

[1.2.5]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.5
[1.2.4]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.4
[1.2.3]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.3
[1.2.2]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.2
[1.2.1]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.1
[1.2.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.0
[1.1.1]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.1.1
[1.1.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.0.0
