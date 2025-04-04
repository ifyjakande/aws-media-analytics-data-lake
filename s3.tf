/*
 * Note: Despite "iceberg" in the bucket name, this project doesn't actually use
 * Apache Iceberg table format. The name is just part of the naming convention.
 */

resource "aws_s3_bucket" "data_lake" {
  bucket = "media-datalake-iceberg-demo"
  
  tags = {}
}

# Add server-side encryption using our existing KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.media_data_lake.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = false
  }
  
  # Prevent Terraform from modifying the existing configuration
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Define key folders in the bucket
resource "aws_s3_object" "athena_results_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "athena-results/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

resource "aws_s3_object" "cloudtrail_logs_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "cloudtrail-logs/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

resource "aws_s3_object" "raw_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "raw/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

# Create the raw subfolders that are used by the generate_synthetic_data.py script
resource "aws_s3_object" "raw_content_metadata_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "raw/content_metadata/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

resource "aws_s3_object" "raw_viewing_data_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "raw/viewing_data/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

resource "aws_s3_object" "raw_viewing_data_csv_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "raw/viewing_data_csv/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

resource "aws_s3_object" "raw_engagement_data_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "raw/engagement_data/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

resource "aws_s3_object" "scripts_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "scripts/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
}

# Create a temp folder for Glue jobs
resource "aws_s3_object" "temp_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "temp/"
  source = "/dev/null"  # Empty object
  content_type = "application/x-directory"
} 