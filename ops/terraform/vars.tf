variable "project" {
  type = object({
    name = string
    github_repository_name = string
    github_organization_name = string
    github_branch = string
    ecr_repository_url = string
  })

  default = {
    name = "standalone_images"
    github_repository_name = "standalone"
    github_organization_name = "rebugit"
    github_branch = "master"
    ecr_repository_url = "public.ecr.aws/c3m8k8v9"
  }
}

variable "codestar_connection_arn" {
  type = string
  default = "arn:aws:codestar-connections:us-east-1:726268367460:connection/badc208f-c12b-4519-abd0-e087e4d70cd8"
}
variable "artifacts_name" {
  type = string
  default = "standalone_images_artifacts"
}
variable "codepipeline_role_arn" {
  type = string
  default = "arn:aws:iam::726268367460:role/codepipeline_images"
}
variable "codepipeline_bucket_name" {
  type = string
  default = "rebugit-codepipeline-images"
}
variable "codebuild_role_arn" {
  type = string
  default = "arn:aws:iam::726268367460:role/codebuild_images"
}