terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_default_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "confluent" {
  cloud_api_key    = var.cflt_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.cflt_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
}

resource "confluent_environment" "environment" {
  display_name = "${var.env_prefix}cluster"
}
