terraform {
  backend "s3" {
    key = "samples/existingclustereks/terraform.tfstate"
    encrypt = true
  }
}
provider "aws" {}

output "todo_api_role_arn" {
  value = aws_iam_policy.todo_api_pod_policy.arn
}