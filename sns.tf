resource "aws_sns_topic" "pipeline_notifications" {
  name = "media-analytics-alerts"
  
  tags = {
    Name        = "media-analytics-alerts"
    Environment = var.environment
    Project     = var.project_name
  }
  
  # This SNS topic already exists in AWS, this is just for Terraform state tracking
  lifecycle {
    ignore_changes = all
  }
} 