# Entra ID Security Groups for Fabric Data Platform

# Platform Groups (static, environment-agnostic)
resource "azuread_group" "platform_admins" {
  display_name     = "lbn_SG-Fabric-Platform-Admins"
  description      = "Fabric tenant administrators - operate the platform and manage all workspaces"
  security_enabled = true
}

resource "azuread_group" "cicd_approvers" {
  display_name     = "lbn_SG-Fabric-CICD-Approvers"
  description      = "Approve CI/CD deployments to production"
  security_enabled = true
}

# Core Workspace Groups (per environment: dev, test, prod)
resource "azuread_group" "core_admins" {
  for_each = toset(var.environments)

  display_name     = "lbn_SG-Fabric-Core-${each.value}-Admins"
  description      = "Admin access to Core workspace - ${each.value} environment"
  security_enabled = true
}

resource "azuread_group" "core_contributors" {
  for_each = toset(var.environments)

  display_name     = "lbn_SG-Fabric-Core-${each.value}-Contributors"
  description      = "Contributor access to Core workspace - ${each.value} environment (Data Engineers & Analysts)"
  security_enabled = true
}

# Business Workspace Groups (per domain, prod only)
resource "azuread_group" "business_admins" {
  for_each = toset(var.business_domains)

  display_name     = "lbn_SG-Fabric-Biz-${each.value}-Admins"
  description      = "Admin access to ${each.value} business workspace (Domain Owners)"
  security_enabled = true
}

resource "azuread_group" "business_contributors" {
  for_each = toset(var.business_domains)

  display_name     = "lbn_SG-Fabric-Biz-${each.value}-Contributors"
  description      = "Contributor access to ${each.value} business workspace (Business Key Users)"
  security_enabled = true
}

# App Audience Groups (per domain + org-wide)
resource "azuread_group" "app_viewers_domain" {
  for_each = toset(var.business_domains)

  display_name     = "lbn_SG-Fabric-App-${each.value}-Viewers"
  description      = "Power BI App viewers for ${each.value} domain reports"
  security_enabled = true
}

resource "azuread_group" "app_viewers_org" {
  display_name     = "lbn_SG-Fabric-App-OrgDashboard-Viewers"
  description      = "Power BI App viewers for organization-wide dashboard"
  security_enabled = true
}

# CI/CD Service Principal
resource "azuread_application" "cicd" {
  display_name = "lbn_SP-Fabric-CICD"
  description  = "Service Principal for CI/CD deployments via GitHub Actions"
}

resource "azuread_service_principal" "cicd" {
  client_id                    = azuread_application.cicd.client_id
  app_role_assignment_required = false
  description                  = "Service Principal for automated Fabric deployments"
}
