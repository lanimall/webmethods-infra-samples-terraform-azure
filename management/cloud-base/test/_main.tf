

module "common_uuid" {
  source = "../../../../common/tfmodules/common_uuid_consistent"

  project_code = var.project_code
  environment_level = var.environment_level
  workload_code = var.workload_code
  provisioning_stack = var.provisioning_stack
}

output "common_uuid" {
  value = module.common_uuid.uuid
}

output "common_uuid_params_string" {
  value = module.common_uuid.internal_params_string
}

output "common_uuid_params_encoded" {
  value = module.common_uuid.internal_params_encoded
}

module "common_base" {
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

output "common_base_uuid" {
  value = module.common_base.uuid
}