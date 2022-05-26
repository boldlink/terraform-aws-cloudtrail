# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Add: `advanced_event_selector` in examples

## [1.1.0] - 2022-05-25
### Added
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

[1.0.0]: https://github.com/boldlink/terraform-aws-cloudtrail/releases/tag/1.0.0
