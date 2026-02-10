# Terraform backend configuration
# Configure remote state storage in Azure Storage Account
# The 'key' parameter is intentionally omitted here and must be provided
# via -backend-config="key=<environment>.tfstate" to support multiple environments

terraform {
  backend "azurerm" {
    resource_group_name  = "lbn-tf-state"
    storage_account_name = "lbntfstate"
    container_name       = "tfstate"
    # key is specified via -backend-config in CI/CD workflow
  }
}
