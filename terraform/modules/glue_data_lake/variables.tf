variable "data_lake_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket used by Glue for data"
}

variable "glue_job_name" {
  type        = string
  description = "Name of the Glue job"
}

variable "glue_job_script_s3_path" {
  type        = string
  description = "S3 path to the Glue job script"
}
