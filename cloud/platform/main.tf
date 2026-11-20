terraform {
  required_providers {
    vercel = {
      source = "vercel/vercel"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }
}

provider "vercel" {
  team = "team_xvZMkEiGJrbpmKzXuAqNbdO8"
}

provider "supabase" {} # reads SUPABASE_ACCESS_TOKEN

variable "github_repo" {
  type        = string
  description = "owner/name of the repository, for example jdoe/blueharbor-infra"
}

variable "initials" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2,3}$", var.initials))
    error_message = "initials: 2 or 3 lower-case letters."
  }
}

variable "region" {
  type    = string
  default = "eu-west-3"
  validation {
    condition     = contains(["eu-west-3", "eu-central-1"], var.region)
    error_message = "Only EU regions are allowed for BlueHarbor data."
  }
}

variable "supabase_org" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "supabase_key" {
  type      = string
  sensitive = true
}

resource "vercel_project" "trackit" {
  name           = "bh-trackit-${var.initials}"
  root_directory = "trackit"
  framework      = "flask"
  git_repository = {
    type              = "github"
    repo              = var.github_repo
    production_branch = "main"
  }
}

resource "vercel_project_environment_variable" "version" {
  project_id = vercel_project.trackit.id
  key        = "APP_VERSION"
  value      = "1.1.0"
  target     = ["production", "preview"]
  sensitive  = false
}

resource "supabase_project" "trackit" {
  organization_id   = var.supabase_org
  name              = "bh-trackit-dev"
  database_password = var.db_password
  region            = var.region
  lifecycle {
    ignore_changes = [database_password]
  }
}

resource "vercel_project_environment_variable" "sb_url" {
  project_id = vercel_project.trackit.id
  key        = "SUPABASE_URL"
  value      = "https://${supabase_project.trackit.id}.supabase.co"
  target     = ["production", "preview"]
  sensitive  = false
}

resource "vercel_project_environment_variable" "sb_key" {
  project_id = vercel_project.trackit.id
  key        = "SUPABASE_KEY"
  value      = var.supabase_key
  target     = ["production", "preview"]
  sensitive  = true
}

output "project_id" {
  value = vercel_project.trackit.id
}