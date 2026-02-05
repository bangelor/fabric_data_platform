# Terraform backend configuration
# Configure remote state storage in Azure Storage Account

terraform {
  backend "azurerm" {
    resource_group_name  = "lbn-tf-state"
    storage_account_name = "lbntfstate"
    container_name       = "tfstate"
    key                  = "fabric-data-platform.tfstate"
    
  }
}
