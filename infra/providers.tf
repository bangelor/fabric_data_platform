# Provider configuration

provider "azurerm" {
  features {}

  # Use OIDC authentication for GitHub Actions
  use_oidc = true

  # These will be set via environment variables:
  # ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_USE_OIDC
}

provider "fabric" {
  # Use OIDC authentication for GitHub Actions
  use_oidc = true
  preview = true

  # These will be set via environment variables:
  # FABRIC_TENANT_ID, FABRIC_CLIENT_ID, FABRIC_USE_OIDC
}
