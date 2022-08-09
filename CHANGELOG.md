# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- fix: CKV_AWS_111: Ensure IAM policies does not allow write access without constraints
- fix: CKV_AWS_109: Ensure IAM policies does not allow permissions management / resource exposure without constraints
- fix: CKV_AWS_144: Ensure that S3 bucket has cross-region replication enabled
- fix: CKV_AWS_18: Ensure the S3 bucket has access logging enabled
- fix: CKV_AWS_145: Ensure that S3 buckets are encrypted with KMS by default. NOTE:: Resource for this feature not currently detected by checkov though buckets are encrypted.

- Add: `advanced_event_selector` in examples
- Change: Use upgraded S3 module for external bucket
- Allow overwriting the default KMS Policies
- Restrict user/groups to access the cloudtrails config and logs on cw and s3
- Add the option to replicate the s3 logs to a different account for org and non-org (s3 replication rule - requires a kms key on the destination account)
- Extend s3 configuration to add a lifecycle rule to archive 5y of data (discuss what should be the defaults) for both the local and replicated s3 bucket if enabled

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

[Unreleased]: https://github.com/boldlink/terraform-aws-cloudtrail/compare/1.2.0...HEAD

[1.2.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.2.0
[1.1.1]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.1.1
[1.1.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.0.0
