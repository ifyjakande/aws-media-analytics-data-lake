# 📥 Importing Existing AWS Resources to Terraform

This guide will help you import your existing AWS resources into Terraform to manage them as Infrastructure as Code going forward.

## 📋 Prerequisites

- Terraform installed (v1.5.7 or newer)
- AWS CLI installed and configured with your credentials
- AWS account with permissions to access your resources
- Existing AWS resources (Step Function, Glue jobs, IAM roles, etc.)

## 🔄 Step-by-Step Import Process

### 🔑 1. Configure AWS CLI

Ensure your AWS CLI is configured with the correct credentials:

```bash
aws configure
```

Enter your AWS Access Key ID, Secret Access Key, and set the region to `us-east-1` (the region where our media analytics resources are deployed).

### 📜 2. Run the Scripts

We've provided several scripts to help you import your resources into Terraform's state:

#### 📥 2.1. Download the Glue Script

First, download your existing Glue job script from S3:

```bash
cd terraform
./download_glue_script.sh
```

This script will:
- Connect to your S3 bucket `media-datalake-iceberg-demo`
- Download the Glue Python script from the scripts directory
- Save it to your local terraform/scripts folder for version control
- Create a template if the script isn't found

#### 🔄 2.2. Import the Resources

Run the import script to import all your existing resources into Terraform's state:

```bash
./import.sh
```

This script will:
- Initialize Terraform
- Get your AWS account ID
- Import the following resources:
  - S3 bucket and all folder objects
  - Glue database, job, and all four crawlers
  - Step Function state machine
  - SNS topic for notifications
  - IAM roles and policies
  - EventBridge rule and target
- Show progress for each imported resource

#### 🏗️ 2.3. Generate Terraform Files

After importing the resources, you can generate Terraform configuration files from the imported state:

```bash
./generate_tf_files.sh
```

This script will:
- Generate Terraform configuration files based on your imported resources
- Create a backup of any existing files
- Split resources into separate logical files (iam.tf, glue.tf, etc.)
- Generate outputs.tf with references to all your resources

### ✅ 3. Verify the Import

After importing and generating files, run a Terraform plan to see if there are any differences between your Terraform configuration and the actual AWS resources:

```bash
terraform plan
```

If you see a lot of changes, it means your Terraform configuration doesn't match the actual resources in AWS. You may need to adjust the generated files manually.

### 📝 4. Update Terraform Files (if needed)

If there are differences, you might need to modify the generated Terraform files to match your actual resources:

- `main.tf` - Provider configuration
- `variables.tf` - Variable definitions
- `iam.tf` - IAM roles and policies
- `sns.tf` - SNS topic
- `glue.tf` - Glue resources
- `s3.tf` - S3 bucket and folder structure
- `step_function.tf` - Step Function definition
- `eventbridge.tf` - EventBridge rule and target

### 🏁 5. Finalize the Import

Once your Terraform plan shows no changes (or only acceptable changes), your resources are fully managed by Terraform.

### 🔄 6. Make Future Changes

From now on, make all changes to your infrastructure through Terraform:

1. Edit the Terraform files
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

## ⚠️ Common Issues and Solutions

### 🔄 Different Resource Configuration

If your Terraform-defined resources differ from the actual AWS resources, you have two options:

1. Update the Terraform files to match the AWS resources
2. Allow Terraform to modify the AWS resources to match your configuration

Option 1 is safer if you want to keep your current infrastructure exactly as-is.

### ❌ Failed Imports

If certain resources fail to import, you may need to:

1. Check if the resource exists in AWS
2. Verify you have the correct resource name/ARN
3. Ensure your AWS credentials have permission to access the resource

### 🔍 Missing Resources

If you discover additional resources in AWS that need to be imported:

1. Add the resource definition to the appropriate Terraform file
2. Import the resource manually using:
   ```bash
   terraform import [resource_type].[resource_name] [resource_id]
   ```

## 📤 Uploading Glue Script

If you need to upload or update your Glue script in S3:

```bash
aws s3 cp terraform/scripts/generate_media_data.py s3://media-datalake-iceberg-demo/scripts/generate_media_data.py
```

## 🎉 Conclusion

After completing this process, your existing AWS resources will be fully managed by Terraform. Any future changes should be made through Terraform to ensure your infrastructure remains consistent and well-documented. 