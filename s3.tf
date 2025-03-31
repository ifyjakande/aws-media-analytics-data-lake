resource "aws_s3_bucket" "data_lake" {
  bucket = "media-datalake-iceberg-demo"
  
  tags = {}
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

# The redshift-stage_$folder$ appears to be a system-generated marker and doesn't need to be managed by Terraform

# Note: To manage the actual script file, you would typically use a local file resource.
# Since we don't have access to the original file in this session, it would need to be 
# uploaded manually or via another mechanism. Here's how you'd define it if you had the
# file locally:
#
# resource "aws_s3_object" "generate_synthetic_data_script" {
#   bucket = aws_s3_bucket.data_lake.id
#   key    = "scripts/generate_synthetic_data.py"
#   source = "path/to/local/generate_synthetic_data.py"  # Local path to the script file
#   etag   = filemd5("path/to/local/generate_synthetic_data.py")
# } 