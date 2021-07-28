resource "aws_codepipeline" "tracer_image" {
  name = var.project.name
  role_arn = var.codepipeline_role_arn

  tags = {
    project = "rebugit"
    service = "tracer"
    env = "prod"
    type = "ops"
    description = "Codepipeline for standalone images"
  }

  artifact_store {
    location = var.codepipeline_bucket_name
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = [var.artifacts_name]
      configuration = {
        ConnectionArn = var.codestar_connection_arn
        FullRepositoryId = "${var.project.github_organization_name}/${var.project.github_repository_name}"
        BranchName = var.project.github_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = [var.artifacts_name]
      configuration = {
        ProjectName = aws_codebuild_project.tracer_image.name
      }
    }
  }
}

resource "aws_codebuild_project" "tracer_image" {
  name = var.project.name
  service_role = var.codebuild_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "GITHUB_REPOSITORY_URL"
      value = "https://github.com/${var.project.github_organization_name}/${var.project.github_repository_name}.git"
    }

    environment_variable {
      name = "ECR_REPOSITORY_URL"
      value = var.project.ecr_repository_url
    }

    environment_variable {
      name = "ENV"
      value = "prod"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}