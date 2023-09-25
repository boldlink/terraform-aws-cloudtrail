variable "name" {
  type        = string
  description = "The name of the stack"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket designated for publishing log files."
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

variable "enable_log_file_validation" {
  type        = bool
  description = "(Optional) Whether log file integrity validation is enabled. Defaults to `false`."
  default     = true
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

variable "advanced_event_selectors" {
  type        = any
  description = "(Optional) Specifies an advanced event selector for enabling data event logging. Conflicts with `event_selector`."
  default     = []
}

variable "insight_selectors" {
  type        = any
  description = "(Optional) Configuration block for identifying unusual operational activity."
  default     = []
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

variable "kms_key_id" {
  type        = string
  description = "Enter KMS ARN for the Key that will be used for encrypting/decrypting trail logs."
  default     = null
}

variable "log_retention_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 1827
}

variable "sns_topic_name" {
  type        = string
  description = "(Optional) Name of the Amazon SNS topic defined for notification of log file delivery."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the trail."
  default     = {}
}
