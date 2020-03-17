

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "github.com/tkam8/drone-demo-module//gcp_ubuntu_systems?ref=v0.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = "../../../../../terragrunt.hcl"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    network             = "networkName"
    public_subnetwork   = "https://www.googleapis.com/compute/v1/projects/f5-gcs-4261-sales-apcj-japan/regions/asia-northeast1/subnetworks/mock-subnet1"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  #skip_outputs = true
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix          = "nginx-controller-demo"
  project              = "f5-gcs-4261-sales-apcj-japan"
  region               = "asia-northeast1"
  zone                 = "asia-northeast1-b"
  network              = dependency.vpc.outputs.network
  subnetwork           = dependency.vpc.outputs.public_subnetwork
  ubuntu_instance_type = "n1-highcpu-8"
  disk_size            = 80
  app_tag_value        = "nginxctlrdemo"
}