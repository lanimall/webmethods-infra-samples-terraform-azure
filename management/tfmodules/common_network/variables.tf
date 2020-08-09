variable "s3_bucket_name" {
  description = "S3 Bucket name where the terraform state is kept"
}

variable "s3_bucket_region" {
  description = "S3 Bucket region where the terraform state is kept"
}

variable "project_name" {
  description = "General Project Name"
}

variable "provider_name" {
  description = "cloud provider (ie. azure, aws)"
}

variable "workload_name" {
  description = "Workload Name"
}

variable "environment_level" {
  description = "environment code level - dev, test, impl, prod"
}