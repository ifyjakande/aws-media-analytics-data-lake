#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Download Glue Script from S3  ${NC}"
echo -e "${GREEN}=========================================${NC}"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to get AWS account ID. Please check your AWS credentials.${NC}"
    exit 1
fi

echo -e "${YELLOW}Using AWS Account ID: ${ACCOUNT_ID}${NC}"

# Check for the bucket name from variables.tf
BUCKET_NAME=$(grep -A 2 'variable.*s3_bucket_name' variables.tf 2>/dev/null | grep default | sed 's/.*default.*"\(.*\)".*/\1/')

# If not found in variables.tf, use the default
if [ -z "$BUCKET_NAME" ]; then
    echo -e "${YELLOW}Using default bucket name${NC}"
    BUCKET_NAME="media-datalake-iceberg-demo"
fi

echo -e "${YELLOW}Using bucket name: ${BUCKET_NAME}${NC}"

# Parameters
SCRIPT_S3_PATH="scripts/generate_media_data.py"
LOCAL_SCRIPT_DIR="scripts"
LOCAL_SCRIPT_PATH="${LOCAL_SCRIPT_DIR}/generate_media_data.py"

# Create scripts directory if it doesn't exist
if [ ! -d "${LOCAL_SCRIPT_DIR}" ]; then
    mkdir -p "${LOCAL_SCRIPT_DIR}"
fi

# Download the script
echo -e "\n${YELLOW}Downloading Glue script from S3...${NC}"
aws s3 cp "s3://${BUCKET_NAME}/${SCRIPT_S3_PATH}" "${LOCAL_SCRIPT_PATH}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully downloaded Glue script to ${LOCAL_SCRIPT_PATH}${NC}"
else
    echo -e "${RED}Failed to download Glue script.${NC}"
    echo -e "${YELLOW}Creating a template script for you to customize.${NC}"
    
    # Create a minimal template script
    cat > "${LOCAL_SCRIPT_PATH}" << 'EOL'
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *
from pyspark.sql.types import *
import datetime
import random

# Job parameters
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'output-bucket', 'output-path'])

# Set up Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Replace this with your actual ETL logic
# The script should match what's in your AWS environment

# Complete the job
job.commit()
EOL

    echo -e "${YELLOW}Template created. Update it with your actual script logic.${NC}"
fi 