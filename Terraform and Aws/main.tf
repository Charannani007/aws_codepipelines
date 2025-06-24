provider "aws" {
  region = "eu-north-1"
}

module "iam" {
  source = "./modules/iam"
}


module "ec2_instance" {
  source = "./modules/ec2_instance"
}

module "codebuild1" {
  source           = "./modules/codebuild"
  project_name     = "Code-build-feature"
  service_role_arn = module.iam.pipeline_role_arn
  github_owner     = var.github_owner
  github_repo      = var.github_repo
  inline_buildspec = file("${path.module}/buildspecs/buildspec1.yml")
}

module "codebuild2" {
  source           = "./modules/codebuild"
  project_name     = "Code-build-develop"
  service_role_arn = module.iam.pipeline_role_arn
  github_owner     = var.github_owner
  github_repo      = var.github_repo
  inline_buildspec = file("${path.module}/buildspecs/buildspec2.yml")
}

module "codebuild3" {
  source           = "./modules/codebuild"
  project_name     = "Code-build-release"
  service_role_arn = module.iam.pipeline_role_arn
  github_owner     = var.github_owner
  github_repo      = var.github_repo
  inline_buildspec = file("${path.module}/buildspecs/buildspec3.yml")
}

module "codebuild4" {
  source           = "./modules/codebuild"
  project_name     = "Code-build-slack"
  service_role_arn = module.iam.pipeline_role_arn
  github_owner     = var.github_owner
  github_repo      = var.github_repo
  inline_buildspec = file("${path.module}/buildspecs/buildspec4.yml")
}

module "codebuild5" {
  source           = "./modules/codebuild"
  project_name     = "Code-build-postman"
  service_role_arn = module.iam.pipeline_role_arn
  github_owner     = var.github_owner
  github_repo      = var.github_repo
  inline_buildspec = file("${path.module}/buildspecs/buildspec5.yml")
}


module "pipeline1" {
  source                  = "./modules/codepipeline"
  pipeline_name           = "Codepipeline-feature"
  service_role_arn        = module.iam.pipeline_role_arn
  github_owner            = var.github_owner
  github_repo             = var.github_repo
  branch                  = "feature"
  codebuild_project_name  = "Code-build-feature"
  codestar_connection_arn = "arn:aws:codeconnections:eu-north-1:054037110178:connection/234c17b1-18aa-48bf-bb1f-065237bc5f8c"
  detect_changes          = false
  artifact_bucket_name   = "dataskate-project-release"
}

module "pipeline2" {
  source                  = "./modules/codepipeline"
  pipeline_name           = "Codepipeline-develop"
  service_role_arn        = module.iam.pipeline_role_arn
  github_owner            = var.github_owner
  github_repo             = var.github_repo
  branch                  = "develop"
  codebuild_project_name  = "Code-build-develop"
  codestar_connection_arn = "arn:aws:codeconnections:eu-north-1:054037110178:connection/234c17b1-18aa-48bf-bb1f-065237bc5f8c"
  artifact_bucket_name   = "dataskate-project-release"
}

module "pipeline3" {
  source                  = "./modules/codepipeline"
  pipeline_name           = "Codepipeline-release"
  service_role_arn        = module.iam.pipeline_role_arn
  github_owner            = var.github_owner
  github_repo             = var.github_repo
  branch                  = "release"
  codebuild_project_name  = "Code-build-release"
  codestar_connection_arn = "arn:aws:codeconnections:eu-north-1:054037110178:connection/234c17b1-18aa-48bf-bb1f-065237bc5f8c"
  include_postman_stage   = true
  include_slack_stage     = true
  artifact_bucket_name   = "dataskate-project-release"
}

output "pipeline_role_arn" {
  value = module.iam.pipeline_role_arn
}
