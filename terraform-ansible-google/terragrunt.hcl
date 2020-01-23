# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Configure the cloud storage for storing the state file
remote_state {
  backend = "gcs"
  config = {
    bucket         = "tky-nginx-ctlr-v3-demo"
    prefix         = "${path_relative_to_include()}/terraform.tfstate"
  }
}



# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  # Configure Terragrunt to use common vars encoded as yaml to help you keep often-repeated variables (e.g., account ID)
  # DRY. We use yamldecode to merge the maps into the inputs, as opposed to using varfiles due to a restriction in
  # Terraform >=0.12 that all vars must be defined as variable blocks in modules. Terragrunt inputs are not affected by
  # this restriction.
  yamldecode(
    file("${get_terragrunt_dir()}/${find_in_parent_folders("region.yaml", local.default_yaml_path)}"),
  ),
  yamldecode(
    file("${get_terragrunt_dir()}/${find_in_parent_folders("env.yaml", local.default_yaml_path)}"),
  ),
  {
    project           = "f5-gcs-4261-sales-apcj-japan"
  },
  {
    allowed_networks  = ["210.226.41.0/24"]
  },
  {
    ## The URL for downloading F5 Declarative Onboarding. Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
    DO_URL            = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.8.0/f5-declarative-onboarding-1.8.0-2.noarch.rpm"
  },
  {
    ## The URL for downloading F5 Application Services 3 extension. Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
    TS_URL            = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.8.0/f5-telemetry-1.8.0-1.noarch.rpm"
  },
  {
    ## The URL for downloading F5 Application Services 3 extension. Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
    AS3_URL           = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.15.0/f5-appsvcs-3.15.0-6.noarch.rpm"
  }
)





