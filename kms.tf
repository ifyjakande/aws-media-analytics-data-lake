resource "aws_kms_key" "media_data_lake" {
  description         = "Media Data Lake Encryption Key"
  enable_key_rotation = true
  
  # This is using lifecycle meta-argument to prevent Terraform from recreating the key
  # since it already exists in AWS with the specific ID
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

# Using the existing alias name format (without hyphens between "data" and "lake")
# to avoid having duplicate aliases for the same key
resource "aws_kms_alias" "media_data_lake" {
  name          = "alias/media-datalake-key"
  target_key_id = aws_kms_key.media_data_lake.key_id
  
  lifecycle {
    ignore_changes = [target_key_id]
  }
} 