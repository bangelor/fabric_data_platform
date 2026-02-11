# Core Workspace Module - Simplified

# Fabric Workspace for core data platform
resource "fabric_workspace" "core" {
  display_name = var.workspace_name
  description  = "Core Fabric workspace - ${title(var.environment)} environment"
  capacity_id  = var.capacity_id
}

# Assign Admin security group as Workspace Admin
resource "fabric_workspace_role_assignment" "admin" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.admin_group_id
    type = "Group"
  }
  role = "Admin"
}

# Assign Contributor security group as Workspace Contributor
resource "fabric_workspace_role_assignment" "contributor" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.contributor_group_id
    type = "Group"
  }
  role = "Contributor"
}

# Lakehouse for core workspace
resource "fabric_lakehouse" "core" {
  display_name = "core_lakehouse_${var.environment}"
  description  = "Core lakehouse for ${var.environment} environment"
  workspace_id = fabric_workspace.core.id
}

# Warehouse for core workspace
resource "fabric_warehouse" "core" {
  display_name = "core_warehouse_${var.environment}"
  description  = "Core warehouse for ${var.environment} environment"
  workspace_id = fabric_workspace.core.id
}

# Create bronze, silver, gold schemas in warehouse
resource "terraform_data" "warehouse_schemas" {
  triggers_replace = [
    fabric_warehouse.core.id
  ]

  provisioner "local-exec" {
    command = <<-EOT
      MAX_RETRIES=5
      RETRY=0
      TOKEN=$(az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv)

      until [ $RETRY -ge $MAX_RETRIES ]; do
        sqlcmd \
          -S "${fabric_warehouse.core.properties.connection_string}" \
          -d "${fabric_warehouse.core.display_name}" \
          -G -P "$TOKEN" \
          -Q "
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='bronze') EXEC('CREATE SCHEMA bronze');
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='silver') EXEC('CREATE SCHEMA silver');
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='gold') EXEC('CREATE SCHEMA gold');
          " && echo "Schemas created successfully." && exit 0

        RETRY=$((RETRY+1))
        echo "Attempt $RETRY failed, retrying in $((10*RETRY))s..."
        sleep $((10*RETRY))
      done

      echo "Failed after $MAX_RETRIES attempts."
      exit 1
    EOT
  }

  depends_on = [fabric_warehouse.core]
}