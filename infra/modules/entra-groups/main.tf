# Entra ID Security Groups for Fabric Data Platform

# Platform Groups (created only in prod environment to avoid duplicates)
resource "azuread_group" "platform_admins" {
  count = var.environment == "prod" ? 1 : 0

  display_name     = "lbn_SG-Fabric-Platform-Admins"
  description      = "Fabric tenant administrators - operate the platform and manage all workspaces"
  security_enabled = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_group" "cicd_approvers" {
  count = var.environment == "prod" ? 1 : 0

  display_name     = "lbn_SG-Fabric-CICD-Approvers"
  description      = "Approve CI/CD deployments to production"
  security_enabled = true

  lifecycle {
    prevent_destroy = true
  }
}

# Core Workspace Groups (only for current environment)
resource "azuread_group" "core_admins" {
  display_name     = "lbn_SG-Fabric-Core-${var.environment}-Admins"
  description      = "Admin access to Core workspace - ${var.environment} environment"
  security_enabled = true
}

resource "azuread_group" "core_contributors" {
  display_name     = "lbn_SG-Fabric-Core-${var.environment}-Contributors"
  description      = "Contributor access to Core workspace - ${var.environment} environment (Data Engineers & Analysts)"
  security_enabled = true
}

# Business Workspace Groups (per domain, prod only)
resource "azuread_group" "business_admins" {
  for_each = var.environment == "prod" ? toset(var.business_domains) : []

  display_name     = "lbn_SG-Fabric-Biz-${each.value}-Admins"
  description      = "Admin access to ${each.value} business workspace (Domain Owners)"
  security_enabled = true
}

resource "azuread_group" "business_contributors" {
  for_each = var.environment == "prod" ? toset(var.business_domains) : []

  display_name     = "lbn_SG-Fabric-Biz-${each.value}-Contributors"
  description      = "Contributor access to ${each.value} business workspace (Business Key Users)"
  security_enabled = true
}

# App Audience Groups (per domain + org-wide, prod only)
resource "azuread_group" "app_viewers_domain" {
  for_each = var.environment == "prod" ? toset(var.business_domains) : []

  display_name     = "lbn_SG-Fabric-App-${each.value}-Viewers"
  description      = "Power BI App viewers for ${each.value} domain reports"
  security_enabled = true
}

resource "azuread_group" "app_viewers_org" {
  count = var.environment == "prod" ? 1 : 0

  display_name     = "lbn_SG-Fabric-App-OrgDashboard-Viewers"
  description      = "Power BI App viewers for organization-wide dashboard"
  security_enabled = true
}
