variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default = "445567080004"  # This will be updated by the import script
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "media-analytics"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "sns_topic_name" {
  description = "SNS topic name for notifications"
  type        = string
  default     = "media-analytics-alerts"
} 