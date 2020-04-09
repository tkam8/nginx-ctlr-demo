# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


# Use below code as backup to dependency block as last resort
// data "terraform_remote_state" "vpc" {
//     backend = "gcs"
//   config = {
//     bucket         = "tky-drone-demo-stage"
//     prefix         = "terraform/state"
//     region         = "asia-northeast1"
//   }
// }

terraform {
  source = "github.com/tkam8/drone-demo-module//ansible_files?ref=v0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = "../../../../terragrunt.hcl"
}

dependency "controller" {
  config_path = "../functions/nginx_controller"

  mock_outputs = {
    ubuntu_public_ip   = "4.4.4.4"
  }
}

dependency "nginx" {
  config_path = "../functions/nginx"

  mock_outputs = {
    nginx_instance    = "instanceSelfLink"
    nginx_public_ip   = "6.6.6.6"
    nginx_private_ip  = "5.5.5.5"
  }
}

dependency "gke" {
  config_path = "../functions/gke_cluster"

  mock_outputs = {
    gke_cluster_name    = "clusterName"
    gke_endpoint        = "3.3.3.3"
    cluster_username    = "admin"
    cluster_password    = "default"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  terragrunt_path             = "${get_terragrunt_dir()}"
  nginx_controller_public_ip  = dependency.controller.outputs.ubuntu_public_ip
  nginx_controller_private_ip = dependency.controller.outputs.ubuntu_private_ip
  gke_cluster_name            = dependency.gke.outputs.gke_cluster_name
  gke_endpoint                = dependency.gke.outputs.gke_endpoint
  nginx_public_ip             = dependency.nginx.outputs.nginx_public_ip
  nginx_private_ip            = dependency.nginx.outputs.nginx_private_ip

  app_tag_value         = "nginxctlrdemo"
  #use below var for multiple nginx deployements
  #gcp_f5_pool_members  = join("','", dependency.nginx.outputs.nginx_private_ip)
  cluster_username      = dependency.gke.outputs.cluster_username
  cluster_password      = dependency.gke.outputs.cluster_password
}
