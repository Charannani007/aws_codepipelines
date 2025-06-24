resource "aws_codebuild_project" "this" {
name = var.project_name
service_role = var.service_role_arn

artifacts {
type = "NO_ARTIFACTS"
}

environment {
compute_type = "BUILD_GENERAL1_SMALL"
image = "aws/codebuild/standard:7.0"
type = "LINUX_CONTAINER"
privileged_mode = true
}

source {
type = "GITHUB"
location = "https://github.com/${var.github_owner}/${var.github_repo}.git"
buildspec = var.inline_buildspec
git_clone_depth = 1
}

logs_config {
cloudwatch_logs {
status = "ENABLED"
group_name = "/aws/codebuild/${var.project_name}"
stream_name = "build-log"
}
}

tags = {
Environment = "Dev"
Project = var.project_name
}
}