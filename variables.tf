variable "name" {
  type        = string
  description = "The name of the stack"
}

variable "s3_key_prefix" {
  type        = string
  description = "(Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  default     = null
}

variable "include_global_service_events" {
  type        = bool
  description = "(Optional) Whether the trail is publishing events from global services such as IAM to the log files. Defaults to `true`."
  default     = true
}

variable "protect_cloudtrail" {
  type        = bool
  description = "Choose whether to protect cloudtrail from deletion or disabling"
  default     = false
}

variable "enable_log_file_validation" {
  type        = bool
  description = "(Optional) Whether log file integrity validation is enabled. Defaults to `false`."
  default     = false
}

variable "enable_logging" {
  type        = bool
  description = "(Optional) Enables logging for the trail. Defaults to `true`. Setting this to false will pause logging."
  default     = true
}

variable "event_selectors" {
  type        = any
  description = "(Optional) Specifies an event selector for enabling data event logging."
  default     = []
}

variable "s3_bucket_force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = true
}

variable "advanced_event_selectors" {
  type        = any
  description = "(Optional) Specifies an advanced event selector for enabling data event logging. Conflicts with `event_selector`."
  default     = []
}

variable "insight_selector" {
  type        = map(string)
  description = "(Optional) Configuration block for identifying unusual operational activity."
  default     = {}
}

variable "is_multi_region_trail" {
  type        = bool
  description = "(Optional) Whether the trail is created in the current region or in all regions. Defaults to `false`"
  default     = true
}

variable "is_organization_trail" {
  type        = bool
  description = "(Optional) Whether the trail is an AWS Organizations trail."
  default     = false
}

variable "key_deletion_window_in_days" {
  type        = number
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive."
  default     = 7
}

variable "log_retention_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 14
}

variable "kms_key_id" {
  type        = string
  description = "(Optional) KMS key ARN to use to encrypt the logs delivered by CloudTrail."
  default     = null
}

variable "sns_topic_name" {
  type        = string
  description = "(Optional) Name of the Amazon SNS topic defined for notification of log file delivery."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to assign to the trail."
  default     = {}
}

variable "environment" {
  type        = string
  description = "Environment where you are creating the resources"
  default     = "staging"
}

variable "other_tags" {
  type        = map(string)
  description = "Other map of tags to assign to the resources."
  default     = {}
}
