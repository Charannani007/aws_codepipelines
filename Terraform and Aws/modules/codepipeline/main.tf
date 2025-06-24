resource "aws_codepipeline" "this" {
  name     = var.pipeline_name
  role_arn = var.service_role_arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.branch
        DetectChanges    = tostring(var.detect_changes)
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  dynamic "stage" {
    for_each = var.include_postman_stage ? [1] : []
    content {
      name = "Postman"
      action {
        name             = "Postman"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["build_output"]
        output_artifacts = ["postman_output"]
        version          = "1"

        configuration = {
          ProjectName = "Code-build-postman"
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.include_slack_stage ? [1] : []
    content {
      name = "Slack"
      action {
        name             = "Slack"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["postman_output"]
        output_artifacts = ["slack_output"]
        version          = "1"

        configuration = {
          ProjectName = "Code-build-slack"
        }
      }
    }
  }
}
