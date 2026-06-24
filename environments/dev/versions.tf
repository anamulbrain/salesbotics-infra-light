terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "salesbotics-tfstate-444083008308"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "salesbotics-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
