# Configure the Azure Provider
provider "azurerm" {
  version = "=2.5.0"
  environment = var.cloud_environment
  subscription_id = var.cloud_subscription
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}