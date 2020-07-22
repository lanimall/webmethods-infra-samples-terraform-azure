module "common_uuid" {
  source = "../common_uuid_consistent"

  project_code = var.project_code
  environment_level = var.environment_level
  workload_code = var.workload_code
  provisioning_stack = var.provisioning_stack
}

locals {
  name_delimiter = "-"
  hostname_delimiter = ""
  inventory_filename_delimiter = "_"

  provisioning_stack_clean = replace(var.provisioning_stack, " ", local.name_delimiter)

  name_friendly_id = lower(
    join(
      "",
      [
        var.project_code,
        var.workload_code,
        var.environment_level,
        terraform.workspace != "default" ? terraform.workspace: ""
      ]
    )
  )

  name_prefix_long = lower(
    replace(
      trimsuffix(
        join(
          local.name_delimiter,
          [
            local.name_friendly_id,
            local.provisioning_stack_clean,
            module.common_uuid.uuid
          ]
        ),
        local.name_delimiter
      ),
      "_", local.name_delimiter
    )
  )

  name_prefix_long_nouuid = lower(
    replace(
      trimsuffix(
        join(
          local.inventory_filename_delimiter,
          [
            local.name_friendly_id,
            local.provisioning_stack_clean,
          ]
        ),
        local.inventory_filename_delimiter
      ),
      "_", local.inventory_filename_delimiter
    )
  )
  
  ##some names cannot exceed some char length...we can use that random ID instead when needed
  name_prefix_short = join(
    local.name_delimiter,
    [
      join(
        "",
        [
          var.project_code,
          var.workload_code
        ]
      ),
      module.common_uuid.uuid
    ]
  )

  common_tags = merge(
    local.common_tags_base,
    {
      "Provisoning_UUID"   = module.common_uuid.uuid
    }
  )
}