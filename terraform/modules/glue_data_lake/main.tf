resource "aws_iam_role" "glue_role" {
  name = "dbt_glue_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_managed_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "glue_data_s3_policy" {
  name = "dbt_glue_data_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          var.data_lake_bucket_arn,
          "${var.data_lake_bucket_arn}/*"
        ]

      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_data_s3_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_data_s3_policy.arn
}


## Glue Job
## This is what upload the script to S3 so that the Glue job can run it. The script is located in the scripts folder of this module.

resource "aws_s3_object" "glue_job_script" {
  bucket = replace(var.data_lake_bucket_arn, "arn:aws:s3:::", "")
  key    = var.glue_job_script_s3_path
  source = "${path.module}/../../../glue/scripts/api_ingestion.py"
  etag   = filemd5("${path.module}/../../../glue/scripts/api_ingestion.py")
}

## This is the Glue job that will run the script. The script is uploaded to S3 in the previous resource.
resource "aws_glue_job" "api_s3_pull_job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${aws_s3_object.glue_job_script.bucket}/${aws_s3_object.glue_job_script.key}"
  }

  max_capacity = 1.0
  #glue_version = "4.0"

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--bucket_name"                      = aws_s3_object.glue_job_script.bucket
  }

  max_retries = 0
}


