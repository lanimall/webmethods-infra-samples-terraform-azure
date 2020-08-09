###### Get data from security project ###### 
data "terraform_remote_state" "base_loadbalancing" {
    backend = "s3"
    config = {
      bucket = var.s3_bucket_name
      key    = join(
                "/",
                [
                  var.project_name,
                  var.provider_name,
                  var.workload_name,
                  var.environment_level,
                  "loadbalancing.tfstate"
                ]
              )
      region = var.s3_bucket_region
    }
}