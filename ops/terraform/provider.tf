terraform {
  backend "s3" {
    bucket = "rebugit-terraform-state"
    key = "standalone/terraform.tfstate"
    region = "us-east-1"
    profile = "rebugit-prod"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "rebugit-prod"
}