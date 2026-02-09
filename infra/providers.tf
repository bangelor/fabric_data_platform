# Provider configuration

provider "azurerm" {
  features {}

  # Use OIDC authentication for GitHub Actions
  use_oidc = true

  # These will be set via environment variables:
  # ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_USE_OIDC
}

provider "fabric" {
  # Use token-based authentication (token set via FABRIC_TOKEN env var in CI/CD)
  # For local development, use: az login && export FABRIC_TOKEN=$(az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)
  preview = true
}
