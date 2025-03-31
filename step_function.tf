resource "aws_sfn_state_machine" "media_analytics_pipeline" {
  name     = "MediaAnalyticsPipeline"
  role_arn = "arn:aws:iam::445567080004:role/service-role/StepFunctions-MediaAnalyticsPipeline-role-q8037zxe2"
  
  definition = jsonencode({
    Comment = "Media Analytics Data Pipeline"
    StartAt = "GenerateSyntheticData"
    States = {
      GenerateSyntheticData = {
        Type = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = "media-data-generator"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "RunViewingCrawler"
      },
      
      // First crawler - Viewing Data
      RunViewingCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = "media-data-viewing-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "WaitForViewingCrawler"
      },
      WaitForViewingCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:getCrawler",
        Parameters = {
          Name = "media-data-viewing-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "CheckViewingCrawlerStatus"
      },
      CheckViewingCrawlerStatus = {
        Type = "Choice",
        Choices = [{
          Variable = "$.Crawler.State",
          StringEquals = "RUNNING",
          Next = "WaitBeforeCheckingViewingAgain"
        }],
        Default = "RunViewingCSVCrawler"
      },
      WaitBeforeCheckingViewingAgain = {
        Type = "Wait",
        Seconds = 60,
        Next = "WaitForViewingCrawler"
      },
      
      // Second crawler - Viewing Data CSV
      RunViewingCSVCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = "media-data-viewing-csv-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "WaitForViewingCSVCrawler"
      },
      WaitForViewingCSVCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:getCrawler",
        Parameters = {
          Name = "media-data-viewing-csv-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "CheckViewingCSVCrawlerStatus"
      },
      CheckViewingCSVCrawlerStatus = {
        Type = "Choice",
        Choices = [{
          Variable = "$.Crawler.State",
          StringEquals = "RUNNING",
          Next = "WaitBeforeCheckingViewingCSVAgain"
        }],
        Default = "RunContentCrawler"
      },
      WaitBeforeCheckingViewingCSVAgain = {
        Type = "Wait",
        Seconds = 60,
        Next = "WaitForViewingCSVCrawler"
      },
      
      // Third crawler - Content Metadata
      RunContentCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = "media-data-content-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "WaitForContentCrawler"
      },
      WaitForContentCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:getCrawler",
        Parameters = {
          Name = "media-data-content-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "CheckContentCrawlerStatus"
      },
      CheckContentCrawlerStatus = {
        Type = "Choice",
        Choices = [{
          Variable = "$.Crawler.State",
          StringEquals = "RUNNING",
          Next = "WaitBeforeCheckingContentAgain"
        }],
        Default = "RunEngagementCrawler"
      },
      WaitBeforeCheckingContentAgain = {
        Type = "Wait",
        Seconds = 60,
        Next = "WaitForContentCrawler"
      },
      
      // Fourth crawler - Engagement Data
      RunEngagementCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = "media-data-engagement-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "WaitForEngagementCrawler"
      },
      WaitForEngagementCrawler = {
        Type = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:getCrawler",
        Parameters = {
          Name = "media-data-engagement-crawler"
        },
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next = "SendFailureNotification",
          ResultPath = "$.error"
        }],
        Next = "CheckEngagementCrawlerStatus"
      },
      CheckEngagementCrawlerStatus = {
        Type = "Choice",
        Choices = [{
          Variable = "$.Crawler.State",
          StringEquals = "RUNNING",
          Next = "WaitBeforeCheckingEngagementAgain"
        }],
        Default = "SendSuccessNotification"
      },
      WaitBeforeCheckingEngagementAgain = {
        Type = "Wait",
        Seconds = 60,
        Next = "WaitForEngagementCrawler"
      },
      
      SendSuccessNotification = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = "arn:aws:sns:us-east-1:445567080004:media-analytics-alerts",
          Message = "Media data lake pipeline completed successfully! All crawlers have been executed.",
          Subject = "Media Analytics Pipeline - Success"
        },
        End = true
      },
      SendFailureNotification = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = "arn:aws:sns:us-east-1:445567080004:media-analytics-alerts",
          "Message.$" = "States.Format('Media data lake pipeline failed with error: {}', $.error)",
          Subject = "Media Analytics Pipeline - Failure"
        },
        End = true
      }
    }
  })
  
  tags = {
    Name        = "MediaAnalyticsPipeline"
    Environment = var.environment
    Project     = var.project_name
  }
} 