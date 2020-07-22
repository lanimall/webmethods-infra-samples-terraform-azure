locals {
  
  ## remove case issues
  params_string = lower(
    join(
      "",
      [
        var.project_code,
        var.workload_code,
        var.environment_level,
        var.provisioning_stack,
        terraform.workspace
      ]
    )
  )

  params_encoded = sha256(local.params_string)

  params_uuid = lower(
    join(
      "",
      [
        substr(local.params_encoded, 4, 2),
        substr(local.params_encoded, 10, 2),
        substr(local.params_encoded, 16, 1)
      ]
    )
  )
}