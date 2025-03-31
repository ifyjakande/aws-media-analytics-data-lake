resource "aws_glue_catalog_database" "media_analytics_db" {
  name = "media_analytics"
  
  description = "Database for media analytics data"
  
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_glue_job" "media_data_generator" {
  name     = "media-data-generator"
  role_arn = "arn:aws:iam::445567080004:role/GlueIcebergRole"
  
  glue_version = "1.0"
  max_capacity = 0.0625
  timeout = 2880
  
  command {
    name            = "pythonshell"
    script_location = "s3://media-datalake-iceberg-demo/scripts/generate_synthetic_data.py"
    python_version  = "3"
  }
  
  default_arguments = {
    "--TempDir"      = "s3://media-datalake-iceberg-demo/temp/"
    "--job-language" = "python"
    # No need for explicit input/output paths since they're hardcoded in the script
    # BUCKET_NAME = 'media-datalake-iceberg-demo' is defined in the script
  }
  
  execution_property {
    max_concurrent_runs = 1
  }
  
  tags = {}
}

# Define a crawler for the raw content metadata
resource "aws_glue_crawler" "media_data_content_metadata_crawler" {
  name          = "media-data-content-crawler"
  role          = "GlueIcebergRole"
  database_name = "media_analytics"
  
  s3_target {
    path = "s3://media-datalake-iceberg-demo/raw/content_metadata/"
  }
  
  lake_formation_configuration {
    use_lake_formation_credentials = false
  }
  
  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }
  
  tags = {}
}

# Define a crawler for the viewing data (JSON format)
resource "aws_glue_crawler" "media_data_viewing_crawler" {
  name          = "media-data-viewing-crawler"
  role          = "GlueIcebergRole"
  database_name = "media_analytics"
  
  s3_target {
    path = "s3://media-datalake-iceberg-demo/raw/viewing_data/"
  }
  
  lake_formation_configuration {
    use_lake_formation_credentials = false
  }
  
  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }
  
  tags = {}
}

# Define a crawler for the viewing data (CSV format)
resource "aws_glue_crawler" "media_data_viewing_csv_crawler" {
  name          = "media-data-viewing-csv-crawler"
  role          = "GlueIcebergRole"
  database_name = "media_analytics"
  
  s3_target {
    path = "s3://media-datalake-iceberg-demo/raw/viewing_data_csv/"
  }
  
  lake_formation_configuration {
    use_lake_formation_credentials = false
  }
  
  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }
  
  tags = {}
}

# Define a crawler for the engagement data
resource "aws_glue_crawler" "media_data_engagement_crawler" {
  name          = "media-data-engagement-crawler"
  role          = "GlueIcebergRole"
  database_name = "media_analytics"
  
  s3_target {
    path = "s3://media-datalake-iceberg-demo/raw/engagement_data/"
  }
  
  lake_formation_configuration {
    use_lake_formation_credentials = false
  }
  
  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }
  
  tags = {}
} 