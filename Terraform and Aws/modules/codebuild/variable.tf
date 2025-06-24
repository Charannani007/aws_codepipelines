variable "project_name" {
type = string
}

variable "service_role_arn" {
type = string
}

variable "github_owner" {
type = string
}

variable "github_repo" {
type = string
}

variable "inline_buildspec" {
type = string
description = "Path to inline buildspec file (YAML)"
}
