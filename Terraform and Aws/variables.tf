variable "region" {
description = "AWS region"
type = string
default = "us-east-2"
}

variable "github_owner" {
description = "GitHub owner or organization"
type = string
}

variable "github_repo" {
description = "GitHub repository name"
type = string
}

variable "codestar_connection_arn" {
description = "The ARN of the AWS CodeStar connection to GitHub"
type = string
}
