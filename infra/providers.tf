# Provider configuration

provider "azurerm" {
  features {}

  # Use OIDC authentication for GitHub Actions
  use_oidc = true

  # These will be set via environment variables:
  # ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_USE_OIDC
}

provider "fabric" {
  # Use OIDC authentication for GitHub Actions (no token needed!)
  use_oidc = true

  # These will be set via environment variables:
  # FABRIC_USE_OIDC, FABRIC_CLIENT_ID, FABRIC_TENANT_ID
  # GitHub Actions automatically provides OIDC token when id-token: write permission is set

  preview = true
}

provider "azuread" {
  # Use OIDC authentication for GitHub Actions
  use_oidc = true

  # These will be set via environment variables:
  # ARM_CLIENT_ID, ARM_TENANT_ID, ARM_USE_OIDC
}
