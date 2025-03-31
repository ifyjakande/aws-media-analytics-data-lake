resource "aws_cloudwatch_event_rule" "media_pipeline_schedule" {
  name                = "MediaPipelineSchedule"
  description         = "Schedule for running the media analytics pipeline"
  schedule_expression = "cron(0 0 * * ? *)"  # Adjust this to match your existing schedule
  
  # The rule is already created in AWS, this is just for Terraform state tracking
  lifecycle {
    ignore_changes = all
  }
}

# Reference the existing Step Functions execution role
# This role allows EventBridge to trigger the Step Function
resource "aws_iam_role" "step_functions_execution_role" {
  name = "StepFunctionsExecutionRole"
  
  # Required field even though we're using lifecycle ignore_changes
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
  
  # This role already exists in AWS, this is just for Terraform state tracking
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  rule      = aws_cloudwatch_event_rule.media_pipeline_schedule.name
  target_id = "1"  # Updated to match actual target ID
  arn       = aws_sfn_state_machine.media_analytics_pipeline.arn
  role_arn  = aws_iam_role.step_functions_execution_role.arn
  input     = jsonencode({
    Comment = "Triggered by EventBridge scheduled rule"
  })
  
  # The target is already created in AWS, this is just for Terraform state tracking
  lifecycle {
    ignore_changes = all
  }
} 