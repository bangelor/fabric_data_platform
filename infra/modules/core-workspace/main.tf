# ==============================================================================
# Core Workspace Module - Acc Fabric Data Platform
# ==============================================================================

locals {
  env_label   = title(var.environment)
  name_prefix = "acc_fabric"
}

# ------------------------------------------------------------------------------
# Workspace
# ------------------------------------------------------------------------------
resource "fabric_workspace" "core" {
  display_name = "${local.name_prefix}_ws_core_${var.environment}"
  description  = "Core data platform workspace – ${local.env_label}"
  capacity_id  = var.capacity_id

  # lifecycle {
  #   prevent_destroy = true  # Uncomment once stable
  # }
}

# ------------------------------------------------------------------------------
# Role Assignments (no Viewer role by design)
# ------------------------------------------------------------------------------
resource "fabric_workspace_role_assignment" "admin" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.admin_group_id
    type = "Group"
  }
  role = "Admin"
}

resource "fabric_workspace_role_assignment" "contributor" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.contributor_group_id
    type = "Group"
  }
  role = "Contributor"
}

# ------------------------------------------------------------------------------
# Lakehouse
# ------------------------------------------------------------------------------
resource "fabric_lakehouse" "core" {
  display_name = "${local.name_prefix}_lh_core_${var.environment}"
  description  = "Core lakehouse – ${local.env_label}"
  workspace_id = fabric_workspace.core.id
}

# ------------------------------------------------------------------------------
# Warehouse
# ------------------------------------------------------------------------------
resource "fabric_warehouse" "core" {
  display_name = "${local.name_prefix}_wh_core_${var.environment}"
  description  = "Core warehouse – ${local.env_label}"
  workspace_id = fabric_workspace.core.id
}

# ------------------------------------------------------------------------------
# Variable Library (for deployment pipelines)
# Note: Created empty – variables are managed via Fabric UI post-creation
# ------------------------------------------------------------------------------
resource "fabric_variable_library" "deployment" {
  display_name = "${local.name_prefix}_vl_deploy_${var.environment}"
  description  = "Deployment pipeline variables – ${local.env_label}"
  workspace_id = fabric_workspace.core.id
}

# ------------------------------------------------------------------------------
# Medallion Schemas (bootstrap only – Terraform won't detect manual drift)
# Placeholder tables prevent Fabric from dropping empty schemas.
# ------------------------------------------------------------------------------
resource "terraform_data" "warehouse_schemas" {
  triggers_replace = [
    fabric_warehouse.core.id
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail

      MAX_RETRIES=5
      RETRY=0

      until [ $RETRY -ge $MAX_RETRIES ]; do
        # Fetch token inside loop – tokens expire after ~5 min
        export SQLCMDPASSWORD=$(az account get-access-token \
          --resource https://database.windows.net/ \
          --query accessToken -o tsv 2>/dev/null)

        if [ -z "$SQLCMDPASSWORD" ]; then
          echo "ERROR: Failed to acquire SQL access token. Is az CLI authenticated?"
          exit 1
        fi

        sqlcmd \
          -S "${fabric_warehouse.core.properties.connection_string}" \
          -d "${fabric_warehouse.core.display_name}" \
          -G \
          -Q "
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='bronze') EXEC('CREATE SCHEMA bronze');
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='silver') EXEC('CREATE SCHEMA silver');
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='gold') EXEC('CREATE SCHEMA gold');
            -- Placeholder tables: Fabric drops empty schemas; these prevent that
            IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='bronze' AND TABLE_NAME='_placeholder') CREATE TABLE bronze._placeholder (id INT);
            IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='silver' AND TABLE_NAME='_placeholder') CREATE TABLE silver._placeholder (id INT);
            IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='gold' AND TABLE_NAME='_placeholder') CREATE TABLE gold._placeholder (id INT);
          " && echo "Schemas created successfully." && exit 0

        RETRY=$((RETRY+1))
        echo "Attempt $RETRY/$MAX_RETRIES failed. Retrying in $((10*RETRY))s..."
        sleep $((10*RETRY))
      done

      echo "FAILED: Schema creation failed after $MAX_RETRIES attempts."
      exit 1
    EOT
  }

  depends_on = [fabric_warehouse.core]
}