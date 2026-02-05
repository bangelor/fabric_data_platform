# Terraform backend configuration
# Configure remote state storage in Azure Storage Account

terraform {
  backend "azurerm" {
    # resource_group_name  = "rg-terraform-state"
    # storage_account_name = "stterraformstate"
    # container_name       = "tfstate"
    # key                  = "fabric-data-platform.tfstate"
    
    # Uncomment and configure the above values for remote state
    # Or use backend configuration file with: terraform init -backend-config=backend.conf
  }
}
