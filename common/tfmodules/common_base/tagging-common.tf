locals {
  common_tags_base = {
    "Project Name"          = var.project_name
    "Project Code"          = var.project_code
    "Environment Level"     = var.environment_level
    "Workload_Name"         = var.workload_name
    "Workload_Code"         = var.workload_code
    "Workload_Description"  = var.workload_description
    "Owners"                = var.owners
    "Organization"          = var.organization
    "Team"                  = var.team
    "Provisioning_Type"     = var.provisioning_type
    "Provisioning_SCM"      = var.provisioning_git
    "Provisoning_Workspace" = terraform.workspace
    "Provisoning_Stack"     = var.provisioning_stack
  }
}