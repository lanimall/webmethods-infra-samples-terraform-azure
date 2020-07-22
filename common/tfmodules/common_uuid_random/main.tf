
//  Define a random seed based on identifying vars
resource "random_id" "main" {
  keepers = {
    project_code = var.project_code
    workload_code = var.workload_code
    environment_level = var.environment_level
    provisioning_stack = var.provisioning_stack
    tf_state = terraform.workspace
  }
  byte_length = 2
}