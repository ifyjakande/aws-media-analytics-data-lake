# Media Analytics Data Lake Project

This repository manages the AWS infrastructure for a media analytics data lake using Terraform. The project implements a serverless data pipeline that generates synthetic media data, processes it through AWS Glue, and makes it available for analysis in Amazon Athena.

## Architecture Overview

![Media Analytics Architecture](media%20architecture.png)

- **Data Generation**: AWS Glue Python job generates synthetic media content, viewing, and engagement data
- **Storage**: S3-based data lake with organized directories for raw data
- **Metadata Management**: AWS Glue crawlers catalog the data for querying
- **Orchestration**: AWS Step Functions coordinate the end-to-end pipeline execution
- **Scheduling**: EventBridge rules trigger the pipeline on a defined schedule
- **Notifications**: SNS alerts for pipeline success/failure

## Infrastructure Components

- **S3 Bucket**: `media-datalake-demo` with structured folders
- **Glue Database**: `media_analytics` containing tables for media data
- **Glue Job**: `media-data-generator` creates synthetic JSON and CSV data
- **Glue Crawlers**: Update schema in the Glue Data Catalog
- **Step Function**: `MediaAnalyticsPipeline` orchestrates the workflow
- **IAM Roles/Policies**: Secure permissions for all components
- **EventBridge Rule**: Scheduled triggers for the pipeline
- **SNS Topic**: Notifications about pipeline status

## Getting Started

1. Ensure you have the AWS CLI and Terraform installed:
   ```bash
   brew install terraform awscli
   aws configure
   ```

2. Clone this repository and initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

3. Verify the infrastructure configuration:
   ```bash
   terraform plan
   ```

4. Apply changes (if needed):
   ```bash
   terraform apply
   ```

5. Manually trigger the pipeline:
   ```bash
   aws stepfunctions start-execution --state-machine-arn <STEP_FUNCTION_ARN> --name "ManualExecution-$(date +%s)"
   ```

## Data Structure

The data lake contains three main datasets:
- **Content Metadata**: Information about movies, series, documentaries
- **Viewing Data**: User viewing sessions with platforms and durations (in both JSON and CSV formats)
- **Engagement Data**: User interactions like ratings, likes, and shares

## Querying Data

Once the pipeline has run successfully, query data using Amazon Athena:

```sql
-- Example: Get the 10 most recent viewing sessions
SELECT * FROM media_analytics.viewing_data 
ORDER BY view_date DESC, start_time DESC 
LIMIT 10
```

## Scripts

- `import.sh`: Import existing AWS resources into Terraform state
- `download_glue_script.sh`: Download the Glue job script from S3
- `generate_tf_files.sh`: Generate initial Terraform configuration files

## Additional Resources

For more detailed instructions on importing existing resources, see [IMPORT_GUIDE.md](IMPORT_GUIDE.md).

