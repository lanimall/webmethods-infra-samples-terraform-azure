module "global_common_base" {
  source = "../../../../common/tfmodules/common_base"

  cloud_environment = var.cloud_environment
  cloud_subscription = var.cloud_subscription
  cloud_region = var.cloud_region
  project_name = var.project_name
  project_code = var.project_code
  environment_level = var.environment_level
  workload_name = var.workload_name
  workload_code = var.workload_code
  workload_description = var.workload_description
  provisioning_type = var.provisioning_type
  provisioning_git = var.provisioning_git
  provisioning_stack = var.provisioning_stack
  owners = var.owners
  organization = var.organization
  team = var.team
}

module "global_common_base_compute" {
  source = "../../../../common/tfmodules/common_compute_base"

  common_compute_vm_linux = var.common_compute_vm_linux
  common_compute_vm_windows = var.common_compute_vm_windows
  common_compute_scheduler = var.common_compute_scheduler
}

module "management_common_base_network" {
  source = "../../tfmodules/common_network"

  s3_bucket_name = "softwareag-devops-tfstates"
  s3_bucket_region = "us-east-1"
  provider_name = "azure"
  project_name = var.project_name
  environment_level = var.environment_level
  workload_name = var.workload_name
}

module "management_common_base_security" {
  source = "../../tfmodules/common_security"

  s3_bucket_name = "softwareag-devops-tfstates"
  s3_bucket_region = "us-east-1"
  provider_name = "azure"
  project_name = var.project_name
  environment_level = var.environment_level
  workload_name = var.workload_name
}

module "management_common_base_loadbalancing" {
  source = "../../tfmodules/common_loadbalancing"

  s3_bucket_name = "softwareag-devops-tfstates"
  s3_bucket_region = "us-east-1"
  provider_name = "azure"
  project_name = var.project_name
  environment_level = var.environment_level
  workload_name = var.workload_name
}