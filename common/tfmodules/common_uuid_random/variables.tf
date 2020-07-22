
variable "project_code" {
  description = "general project code (use short name if possible, because some resources have length limit on its name)"
}

variable "workload_code" {
  description = "workload code (use short name if possible, because some resources have length limit on its name)"
}

variable "environment_level" {
  description = "environment code level - dev, test, impl, prod"
}

variable "provisioning_stack" {
  description = "project provisoning stack name"
}