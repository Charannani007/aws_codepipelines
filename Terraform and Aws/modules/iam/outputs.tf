output "pipeline_role_arn" {
  description = "ARN of the IAM role for CodePipeline/CodeBuild"
  value       = aws_iam_role.pipeline_role.arn
}
