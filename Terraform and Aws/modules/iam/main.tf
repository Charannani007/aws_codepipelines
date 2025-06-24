resource "aws_iam_role" "pipeline_role" {
  name = "pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "codebuild.amazonaws.com",
            "codepipeline.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Managed Policies Attachments
resource "aws_iam_role_policy_attachment" "attach_codebuild_admin" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_developer" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "attach_codestar_full_access" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeStarFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_s3_full_access" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_secretsmanager_full_access" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Inline Policies
resource "aws_iam_role_policy" "pipeline_inline_policy" {
  name = "pipeline-custom-inline"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # 2. CreateLogStream
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream"
        ],
        Resource = "*"
      },
      # 5. GetObject for release-snapshot bucket
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::dataskate-project-release/*"
        ]
      },
      # 6. CloudWatch and Logs permissions
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:DescribeInsightRules",
          "cloudwatch:DescribeAnomalyDetectors",
          "cloudwatch:GetDashboard",
          "cloudwatch:PutDashboard"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        Resource = "*"
      },
      # 7. Update specific CodeBuild project
      {
        Effect = "Allow",
        Action = "codebuild:UpdateProject",
        Resource = "arn:aws:codebuild:eu-north-1:054037110178:project/release-codebuild-saicharan"
      }
    ]
  })
}
