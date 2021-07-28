terraform {
  backend "s3" {
    bucket = "rebugit-terraform-state"
    key = "tracer/terraform.tfstate"
    region = "us-east-1"
    profile = "rebugit-prod"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "rebugit-prod"
}