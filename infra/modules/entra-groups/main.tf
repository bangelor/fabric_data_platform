# ==============================================================================
# Entra ID Security Groups - Acc Fabric Data Platform
# ==============================================================================
# Naming: ACC-SG-Fabric-{Scope}-{Env}-{Role}
# Tenant-wide groups omit the environment segment.
# ==============================================================================

locals {
  prefix = "ACC-SG-Fabric"
  env    = title(var.environment) # "Prod" / "Dev"
}

# ------------------------------------------------------------------------------
# Platform-wide groups (tenant-scoped, prod only to avoid duplicates)
# ------------------------------------------------------------------------------
resource "azuread_group" "platform_admins" {
  count            = var.environment == "prod" ? 1 : 0
  display_name     = "${local.prefix}-Platform-Admins"
  description      = "Fabric tenant administrators – capacity, gateway, and workspace management"
  security_enabled = true
}

resource "azuread_group" "cicd_approvers" {
  count            = var.environment == "prod" ? 1 : 0
  display_name     = "${local.prefix}-CICD-Approvers"
  description      = "Approve CI/CD deployment pipelines to production"
  security_enabled = true
}

# ------------------------------------------------------------------------------
# Core workspace groups (per environment)
# ------------------------------------------------------------------------------
resource "azuread_group" "core_admins" {
  display_name     = "${local.prefix}-Core-${local.env}-Admins"
  description      = "Admin access to Core ${local.env} workspace – platform team"
  security_enabled = true
}

resource "azuread_group" "core_contributors" {
  display_name     = "${local.prefix}-Core-${local.env}-Contributors"
  description      = "Contributor access to Core ${local.env} workspace – data engineers and analysts"
  security_enabled = true
}

# ------------------------------------------------------------------------------
# Business domain workspace groups (prod only, one per domain)
# ------------------------------------------------------------------------------
resource "azuread_group" "biz_admins" {
  for_each         = var.environment == "prod" ? toset(var.business_domains) : []
  display_name     = "${local.prefix}-Biz-${each.value}-Admins"
  description      = "Admin access to ${each.value} business workspace – domain owners"
  security_enabled = true
}

resource "azuread_group" "biz_contributors" {
  for_each         = var.environment == "prod" ? toset(var.business_domains) : []
  display_name     = "${local.prefix}-Biz-${each.value}-Contributors"
  description      = "Contributor access to ${each.value} business workspace – business key users"
  security_enabled = true
}

# ------------------------------------------------------------------------------
# Audience groups (prod only – used for Power BI App audiences, RLS, etc.)
# Decoupled from delivery mechanism so they can serve Apps, APIs, or direct access.
# ------------------------------------------------------------------------------
resource "azuread_group" "aud_domain" {
  for_each         = var.environment == "prod" ? toset(var.business_domains) : []
  display_name     = "${local.prefix}-Aud-${each.value}-Members"
  description      = "Audience for ${each.value} domain – report and data consumers"
  security_enabled = true
}

resource "azuread_group" "aud_org" {
  count            = var.environment == "prod" ? 1 : 0
  display_name     = "${local.prefix}-Aud-Org-Members"
  description      = "Audience for organization-wide dashboards and cross-domain content"
  security_enabled = true
}