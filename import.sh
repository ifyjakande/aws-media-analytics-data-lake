#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Media Analytics Resource Import Script ${NC}"
echo -e "${GREEN}=========================================${NC}"

# Change to the terraform directory
cd "$(dirname "$0")"

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
fi

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to get AWS account ID. Please check your AWS credentials.${NC}"
    exit 1
fi

# Update account ID in variables.tf
sed -i '' "s/default *= *\"[0-9]*\"/default = \"$ACCOUNT_ID\"/g" variables.tf || echo -e "${YELLOW}Could not automatically update Account ID in variables.tf. Please update it manually.${NC}"

echo -e "${YELLOW}Using AWS Account ID: ${ACCOUNT_ID}${NC}"
REGION=$(aws configure get region)
echo -e "${YELLOW}Using AWS Region: ${REGION}${NC}"

PROJECT_NAME="media-analytics"
ENVIRONMENT="dev"
SNS_TOPIC_NAME="media-analytics-alerts"

echo -e "\n${YELLOW}Identifying available AWS resources...${NC}"

# Check for Step Functions
echo -e "\n${YELLOW}Checking for Step Functions...${NC}"
STEP_FUNCTIONS=$(aws stepfunctions list-state-machines)
echo "$STEP_FUNCTIONS"

echo -e "\n${YELLOW}Enter the name of the Step Function to import (e.g., 'media-analytics-data-pipeline'):"
read STEP_FUNCTION_NAME

if [ -z "$STEP_FUNCTION_NAME" ]; then
    echo -e "${RED}No Step Function name provided, skipping...${NC}"
else
    echo -e "\n${YELLOW}Importing Step Function '${STEP_FUNCTION_NAME}'...${NC}"
    STEP_FUNCTION_ARN="arn:aws:states:${REGION}:${ACCOUNT_ID}:stateMachine:${STEP_FUNCTION_NAME}"
    terraform import aws_sfn_state_machine.media_analytics_pipeline "${STEP_FUNCTION_ARN}"
fi

# Check for Glue Jobs
echo -e "\n${YELLOW}Checking for Glue Jobs...${NC}"
GLUE_JOBS=$(aws glue get-jobs --max-items 10 --query "Jobs[].Name" --output text)
echo "$GLUE_JOBS"

echo -e "\n${YELLOW}Enter the name of the Glue Job to import (e.g., 'media-data-generator'):"
read GLUE_JOB_NAME

if [ -z "$GLUE_JOB_NAME" ]; then
    echo -e "${RED}No Glue Job name provided, skipping...${NC}"
else
    echo -e "\n${YELLOW}Importing Glue Job '${GLUE_JOB_NAME}'...${NC}"
    terraform import aws_glue_job.media_data_generator "${GLUE_JOB_NAME}"
fi

# Check for Glue Crawlers
echo -e "\n${YELLOW}Checking for Glue Crawlers...${NC}"
GLUE_CRAWLERS=$(aws glue get-crawlers --max-results 10 --query "Crawlers[].Name" --output text)
echo "$GLUE_CRAWLERS"

echo -e "\n${YELLOW}Enter the name of the Glue Crawler to import (e.g., 'media-data-crawler'):"
read GLUE_CRAWLER_NAME

if [ -z "$GLUE_CRAWLER_NAME" ]; then
    echo -e "${RED}No Glue Crawler name provided, skipping...${NC}"
else
    echo -e "\n${YELLOW}Importing Glue Crawler '${GLUE_CRAWLER_NAME}'...${NC}"
    terraform import aws_glue_crawler.media_data_crawler "${GLUE_CRAWLER_NAME}"
fi

# Check for SNS Topics
echo -e "\n${YELLOW}Checking for SNS Topics...${NC}"
SNS_TOPICS=$(aws sns list-topics --query "Topics[].TopicArn" --output text)
echo "$SNS_TOPICS"

echo -e "\n${YELLOW}Enter the ARN of the SNS topic to import (full ARN path):"
read SNS_TOPIC_ARN

if [ -z "$SNS_TOPIC_ARN" ]; then
    echo -e "${RED}No SNS Topic ARN provided, skipping...${NC}"
else
    echo -e "\n${YELLOW}Importing SNS Topic '${SNS_TOPIC_ARN}'...${NC}"
    terraform import aws_sns_topic.pipeline_notifications "${SNS_TOPIC_ARN}"
fi

echo -e "\n${GREEN}Import completed.${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Run ${GREEN}terraform plan${NC} to verify the imported resources match your configuration"
echo -e "2. If there are differences, update your Terraform files to match the actual AWS resources"
echo -e "3. Once terraform plan shows no changes, your resources are fully managed by Terraform" 