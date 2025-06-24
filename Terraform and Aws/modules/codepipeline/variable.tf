variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "service_role_arn" {
  description = "IAM role ARN for CodePipeline"
  type        = string
}

variable "github_owner" {
  description = "GitHub owner name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "branch" {
  description = "Branch name to trigger the pipeline"
  type        = string
}

variable "codebuild_project_name" {
  description = "CodeBuild project to be used in the build stage"
  type        = string
}

variable "codestar_connection_arn" {
  description = "AWS CodeStar connection ARN for GitHub"
  type        = string
}

variable "include_slack_stage" {
  description = "Whether to include the Slack CodeBuild stage"
  type        = bool
  default     = false
}

variable "include_postman_stage" {
  description = "Whether to include the Postman CodeBuild stage"
  type        = bool
  default     = false
}

variable "detect_changes" {
  description = "Whether to enable automatic pipeline trigger on code changes (push events)"
  type        = bool
  default     = true
}

variable "artifact_bucket_name" {
  description = "Name of the S3 bucket to use for CodePipeline artifacts. Must be in the same region as the pipeline."
  type        = string
}
