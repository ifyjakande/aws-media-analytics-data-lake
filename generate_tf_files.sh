#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Generate Terraform Files from State  ${NC}"
echo -e "${GREEN}=========================================${NC}"

# This script will create Terraform files based on the imported state
# It's better to let Terraform generate the files based on actual AWS resources

if [ ! -f ".terraform/terraform.tfstate" ]; then
    echo -e "${RED}Error: Terraform state not found.${NC}"
    echo -e "${YELLOW}Please run ./import.sh first to import resources.${NC}"
    exit 1
fi

# Files to generate
FILES=(
    "step_function.tf"
    "glue.tf"
    "sns.tf"
    "iam.tf"
    "outputs.tf"
)

# Create a backup of existing files
backup_dir="backups_$(date +%Y%m%d_%H%M%S)"
mkdir -p $backup_dir

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${YELLOW}Backing up existing ${file}...${NC}"
        cp "$file" "$backup_dir/"
    fi
done

echo -e "\n${YELLOW}Generating Terraform files from state...${NC}"

# Generate files from state
terraform state show aws_sfn_state_machine.media_analytics_pipeline > step_function.tf.new
terraform state show aws_sns_topic.pipeline_notifications > sns.tf.new
terraform state show aws_glue_job.media_data_generator > glue_job.tf.new
terraform state show aws_glue_crawler.media_data_crawler > glue_crawler.tf.new
terraform state show aws_glue_catalog_database.media_analytics_db > glue_db.tf.new
terraform state show aws_s3_bucket.data_lake > s3.tf.new

# Combine Glue resources
cat glue_job.tf.new glue_crawler.tf.new glue_db.tf.new s3.tf.new > glue.tf.new
rm glue_job.tf.new glue_crawler.tf.new glue_db.tf.new s3.tf.new

# Generate IAM resources
terraform state show aws_iam_role.step_function_role > iam_role_step.tf.new
terraform state show aws_iam_role.glue_role > iam_role_glue.tf.new
terraform state show aws_iam_policy.step_function_glue_policy > iam_policy_1.tf.new
terraform state show aws_iam_policy.step_function_sns_policy > iam_policy_2.tf.new
terraform state show aws_iam_policy.glue_s3_policy > iam_policy_3.tf.new

# Combine IAM resources
cat iam_role_step.tf.new iam_role_glue.tf.new iam_policy_*.tf.new > iam.tf.new
rm iam_role_*.tf.new iam_policy_*.tf.new

# Create outputs file
cat > outputs.tf.new << EOL
output "step_function_arn" {
  description = "ARN of the Step Function"
  value       = aws_sfn_state_machine.media_analytics_pipeline.arn
}

output "data_lake_bucket" {
  description = "S3 bucket for the data lake"
  value       = aws_s3_bucket.data_lake.bucket
}

output "glue_job_name" {
  description = "Name of the Glue job for data generation"
  value       = aws_glue_job.media_data_generator.name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.media_data_crawler.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = aws_sns_topic.pipeline_notifications.arn
}
EOL

# Convert .new files to proper Terraform files
for file in "${FILES[@]}"; do
    base_name=$(basename "$file" .tf)
    
    if [ -f "${base_name}.tf.new" ]; then
        echo -e "${GREEN}Creating ${file}...${NC}"
        
        # Add resource block markers
        echo "# Generated from terraform state" > "$file"
        echo "" >> "$file"
        
        # Add content from .new file
        cat "${base_name}.tf.new" >> "$file"
        rm "${base_name}.tf.new"
    fi
done

echo -e "\n${GREEN}Terraform files generated successfully!${NC}"
echo -e "${YELLOW}Please review the generated files and run terraform plan to verify.${NC}" 