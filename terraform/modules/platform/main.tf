resource "random_id" "bucket_suffix" {
  byte_length = 4
}

## new bucket for the Glue Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = "dbt-glue-data-lake-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "dbt-glue-data-lake"
    Environment = var.environment
  }
}

## Create a folder in the S3 bucket for dbt-glue-data-lake bucket
resource "aws_s3_object" "glue_data_lake_folder" {
  bucket = aws_s3_bucket.data_lake.bucket
  key    = "data/"

  content_type = "application/x-directory"
}

## Encrypt the S3 bucket with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for the S3 bucket
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning (recover overwritten/deleted objects)
resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

