## new bucket for the Glue Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = "dbt-glue-data-lake-${var.environment}"

  tags = {
    Name        = "dbt-glue-data-lake"
    Environment = var.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

## Create a folder in the S3 bucket for dbt-glue-data-lake bucket
resource "aws_s3_object" "glue_data_lake_folder" {
  bucket = aws_s3_bucket.data_lake.bucket
  key    = "data/"

  content_type = "application/x-directory"
}
