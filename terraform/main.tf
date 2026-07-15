terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"
}

module "glue_data_lake" {
  source = "./modules/glue_data_lake"

  data_lake_bucket_arn    = module.platform.data_lake_bucket_arn
  glue_job_name           = "api_ingestion_job_dev"
  glue_job_script_s3_path = "scripts/api_ingestion.py"
}

module "platform" {
  source      = "./modules/platform"
  environment = var.environment
}


