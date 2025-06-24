resource "aws_iam_role" "ec2_codepipeline_role" {
  name = "ec2_codepipeline_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_codepipeline_policy" {
  name = "ec2_codepipeline_policy"
  role = aws_iam_role.ec2_codepipeline_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_codepipeline_profile" {
  name = "ec2_codepipeline_profile"
  role = aws_iam_role.ec2_codepipeline_role.name
}
