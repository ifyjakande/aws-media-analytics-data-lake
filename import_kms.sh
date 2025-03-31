#!/bin/bash

echo "Importing existing KMS key into Terraform state..."
terraform import aws_kms_key.media_data_lake 4d1e2457-90fa-4e46-91db-3b5cedcd2515

echo "Importing S3 bucket encryption configuration..."
terraform import aws_s3_bucket_server_side_encryption_configuration.data_lake media-datalake-iceberg-demo

echo "Import completed. Run 'terraform plan' to verify the state match." 