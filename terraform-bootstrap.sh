#!/bin/bash

# Terraform Bootstrap Script
# Creates Azure App Registration with Federated Credentials for GitHub Actions
# This enables OIDC authentication between GitHub and Azure (no secrets needed!)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed. Output will be less formatted."
    JQ_AVAILABLE=false
else
    JQ_AVAILABLE=true
fi

print_message "Starting Azure App Registration setup for GitHub OIDC..."

# Prompt for required information
read -p "Enter your GitHub organization/username: " GITHUB_ORG
read -p "Enter your GitHub repository name: " GITHUB_REPO
read -p "Enter Azure subscription ID (or press Enter to use default): " SUBSCRIPTION_ID

# Login check
print_message "Checking Azure login status..."
if ! az account show &> /dev/null; then
    print_message "Not logged in. Starting Azure login..."
    az login
fi

# Set subscription if provided
if [ -n "$SUBSCRIPTION_ID" ]; then
    print_message "Setting subscription to: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
else
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    print_message "Using default subscription: $SUBSCRIPTION_ID"
fi

# Get subscription details
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

print_message "Subscription: $SUBSCRIPTION_NAME"
print_message "Tenant ID: $TENANT_ID"

# App Registration name
APP_NAME="fabric-data-platform-github"

# Check if app already exists
print_message "Checking if App Registration already exists..."
EXISTING_APP=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)

if [ -n "$EXISTING_APP" ]; then
    print_warning "App Registration '$APP_NAME' already exists with ID: $EXISTING_APP"
    read -p "Do you want to use the existing app? (y/n): " USE_EXISTING
    if [ "$USE_EXISTING" = "y" ]; then
        APP_ID=$EXISTING_APP
        print_message "Using existing App Registration: $APP_ID"
    else
        print_error "Please delete the existing app or choose a different name."
        exit 1
    fi
else
    # Create App Registration
    print_message "Creating App Registration: $APP_NAME"
    APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
    print_message "App Registration created with ID: $APP_ID"
fi

# Get Object ID
OBJECT_ID=$(az ad app show --id "$APP_ID" --query id -o tsv)

# Create Service Principal if it doesn't exist
print_message "Creating/Updating Service Principal..."
SP_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --query "[0].id" -o tsv)

if [ -z "$SP_ID" ]; then
    SP_ID=$(az ad sp create --id "$APP_ID" --query id -o tsv)
    print_message "Service Principal created with ID: $SP_ID"
else
    print_message "Service Principal already exists with ID: $SP_ID"
fi

# Add Power BI Service API permissions (required for Fabric)
print_message "Adding Power BI Service API permissions to App Registration..."

# Get Power BI Service API ID
POWERBI_API_ID=$(az ad sp list --filter "displayName eq 'Power BI Service'" --query "[0].appId" -o tsv 2>/dev/null)

if [ -n "$POWERBI_API_ID" ]; then
    print_message "Found Power BI Service API: $POWERBI_API_ID"
    
    # Add Tenant.ReadWrite.All (Application permission)
    # ID: b2f1b2fa-f35c-407c-979c-a858a808ba85
    az ad app permission add \
        --id "$APP_ID" \
        --api "$POWERBI_API_ID" \
        --api-permissions "b2f1b2fa-f35c-407c-979c-a858a808ba85=Role" \
        2>/dev/null || print_warning "Tenant.ReadWrite.All permission may already exist"
    
    print_message "⚠️  You must grant admin consent manually in Azure Portal:"
    print_message "   Azure AD > App registrations > $APP_NAME > API permissions > Grant admin consent"
    
    print_message "✓ Power BI Service API permissions added (waiting for admin consent)"
else
    print_warning "Could not find Power BI Service API. You must grant permissions manually."
fi

# Add Microsoft Graph API permissions (required for Entra group creation)
print_message "Adding Microsoft Graph API permissions for Entra AD group management..."

# Microsoft Graph API ID (fixed)
GRAPH_API_ID="00000003-0000-0000-c000-000000000000"

# Add Group.ReadWrite.All (Application permission)
# ID: 62a82d76-70ea-41e2-9197-370581804d09
az ad app permission add \
    --id "$APP_ID" \
    --api "$GRAPH_API_ID" \
    --api-permissions "62a82d76-70ea-41e2-9197-370581804d09=Role" \
    2>/dev/null || print_warning "Group.ReadWrite.All permission may already exist"

print_message "✓ Microsoft Graph API permissions added (waiting for admin consent)"

# Assign Contributor role to the subscription
print_message "Assigning Contributor role to subscription..."
az role assignment create \
    --assignee "$APP_ID" \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    2>/dev/null || print_warning "Role assignment may already exist"

# Setup Terraform State Storage Access
print_message ""
print_message "=== Terraform State Storage Configuration ==="
read -p "Do you want to configure access to Terraform state storage? (y/n): " SETUP_STORAGE

if [ "$SETUP_STORAGE" = "y" ]; then
    # Prompt for storage details (with defaults from backend.tf)
    read -p "Enter storage account resource group name [lbn-tf-state]: " STORAGE_RG
    STORAGE_RG=${STORAGE_RG:-lbn-tf-state}
    
    read -p "Enter storage account name [lbntfstate]: " STORAGE_ACCOUNT
    STORAGE_ACCOUNT=${STORAGE_ACCOUNT:-lbntfstate}
    
    read -p "Enter storage container name [tfstate]: " STORAGE_CONTAINER
    STORAGE_CONTAINER=${STORAGE_CONTAINER:-tfstate}
    
    print_message "Checking if storage account exists..."
    if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$STORAGE_RG" &> /dev/null; then
        STORAGE_SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RG/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
        
        print_message "Assigning Storage Blob Data Contributor role..."
        az role assignment create \
            --assignee "$APP_ID" \
            --role "Storage Blob Data Contributor" \
            --scope "$STORAGE_SCOPE" \
            2>/dev/null || print_warning "Storage role assignment may already exist"
        
        print_message "✓ Storage account access configured for Terraform state"
        STORAGE_SETUP_DONE=true
    else
        print_warning "Storage account '$STORAGE_ACCOUNT' not found in resource group '$STORAGE_RG'."
        print_warning "Create it first or the workflow will fail during 'terraform init'."
        STORAGE_SETUP_DONE=false
    fi
else
    print_warning "Skipping storage setup. Ensure the service principal has access to the state storage."
    STORAGE_SETUP_DONE=false
fi

# Setup Fabric Capacity Admin
print_message ""
print_message "=== Fabric Capacity Configuration ==="
read -p "Do you want to configure Fabric Capacity admin access? (y/n): " SETUP_FABRIC

if [ "$SETUP_FABRIC" = "y" ]; then
    # Install Microsoft Fabric CLI extension
    print_message "Installing Microsoft Fabric CLI extension..."
    az extension add --name microsoft-fabric --upgrade 2>/dev/null || print_warning "Extension may already be installed"
    
    # Prompt for Fabric Capacity details
    read -p "Enter Fabric Capacity resource group name: " FABRIC_RG
    read -p "Enter Fabric Capacity name: " FABRIC_CAPACITY
    
    print_message "Getting Fabric Capacity details..."
    FABRIC_CAPACITY_JSON=$(az fabric capacity show \
        --resource-group "$FABRIC_RG" \
        --capacity-name "$FABRIC_CAPACITY" \
        --output json 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        print_error "Failed to get Fabric Capacity. Please check the resource group and capacity name."
        print_warning "Skipping Fabric setup. You can run this manually later."
    else
        FABRIC_CAPACITY_ID=$(echo "$FABRIC_CAPACITY_JSON" | jq -r '.id')
        print_message "Fabric Capacity ID: $FABRIC_CAPACITY_ID"
        
        # Assign Owner role to Fabric Capacity (required for Fabric API operations)
        print_message "Assigning Owner role to Fabric Capacity..."
        az role assignment create \
            --assignee "$SP_ID" \
            --role "Owner" \
            --scope "$FABRIC_CAPACITY_ID" \
            2>/dev/null || print_warning "Role assignment may already exist"
        
        # Add service principal and user as Fabric Capacity admin
        print_message "Adding service principal and user as Fabric Capacity admin members..."
        MEMBERS=$(echo "$FABRIC_CAPACITY_JSON" | jq -c ".administration.members += [\"$SP_ID\", \"lorenz.bangerter@isolutions.ch\"] | .administration")
        
        az fabric capacity update \
            --resource-group "$FABRIC_RG" \
            --capacity-name "$FABRIC_CAPACITY" \
            --administration "$MEMBERS" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            print_message "✓ Service principal and user added as Fabric Capacity admin"
            FABRIC_SETUP_DONE=true
        else
            print_warning "Failed to add admin member. You may need to do this manually in Azure Portal."
            FABRIC_SETUP_DONE=false
        fi
    fi
else
    print_warning "Skipping Fabric Capacity setup. You'll need to manually add the service principal as admin."
    FABRIC_SETUP_DONE=false
fi

# Create Federated Credentials for different environments
print_message "Creating federated credentials for GitHub..."

# 1. Main branch (Production)
print_message "Creating federated credential for main branch..."
CRED_NAME_MAIN="github-main"
az ad app federated-credential create \
    --id "$OBJECT_ID" \
    --parameters "{
        \"name\": \"$CRED_NAME_MAIN\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/main\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions - Main Branch (Production)\"
    }" 2>/dev/null || print_warning "Federated credential for main branch may already exist"

# 2. Develop branch (Development)
print_message "Creating federated credential for develop branch..."
CRED_NAME_DEV="github-develop"
az ad app federated-credential create \
    --id "$OBJECT_ID" \
    --parameters "{
        \"name\": \"$CRED_NAME_DEV\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/develop\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions - Develop Branch (Development)\"
    }" 2>/dev/null || print_warning "Federated credential for develop branch may already exist"

# 3. Pull Requests
print_message "Creating federated credential for pull requests..."
CRED_NAME_PR="github-pr"
az ad app federated-credential create \
    --id "$OBJECT_ID" \
    --parameters "{
        \"name\": \"$CRED_NAME_PR\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:pull_request\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions - Pull Requests\"
    }" 2>/dev/null || print_warning "Federated credential for pull requests may already exist"

# 4. Dev Environment
print_message "Creating federated credential for dev environment..."
CRED_NAME_ENV_DEV="github-env-dev"
az ad app federated-credential create \
    --id "$OBJECT_ID" \
    --parameters "{
        \"name\": \"$CRED_NAME_ENV_DEV\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:environment:dev\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions - Dev Environment\"
    }" 2>/dev/null || print_warning "Federated credential for dev environment may already exist"

# 5. Prod Environment
print_message "Creating federated credential for prod environment..."
CRED_NAME_ENV_PROD="github-env-prod"
az ad app federated-credential create \
    --id "$OBJECT_ID" \
    --parameters "{
        \"name\": \"$CRED_NAME_ENV_PROD\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:environment:prod\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions - Prod Environment\"
    }" 2>/dev/null || print_warning "Federated credential for prod environment may already exist"

# 6. Test Environment
print_message "Creating federated credential for test environment..."
CRED_NAME_ENV_TEST="github-env-test"
az ad app federated-credential create \
    --id "$OBJECT_ID" \
    --parameters "{
        \"name\": \"$CRED_NAME_ENV_TEST\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:$GITHUB_ORG/$GITHUB_REPO:environment:test\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions - Test Environment\"
    }" 2>/dev/null || print_warning "Federated credential for test environment may already exist"

# Create output file
OUTPUT_FILE="github-secrets.txt"
print_message "Creating output file: $OUTPUT_FILE"

cat > "$OUTPUT_FILE" <<EOF
=============================================================================
GitHub Secrets Configuration for Azure OIDC Authentication
=============================================================================

Add these secrets to your GitHub repository:
Repository Settings > Secrets and variables > Actions > New repository secret

AZURE_CLIENT_ID
    $APP_ID

AZURE_TENANT_ID
    $TENANT_ID

AZURE_SUBSCRIPTION_ID
    $SUBSCRIPTION_ID

=============================================================================
How to add secrets to GitHub:
=============================================================================

1. Go to: https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions

2. Click "New repository secret" for each of the above values

3. OR use GitHub CLI:
   gh secret set AZURE_CLIENT_ID -b"$APP_ID"
   gh secret set AZURE_TENANT_ID -b"$TENANT_ID"
   gh secret set AZURE_SUBSCRIPTION_ID -b"$SUBSCRIPTION_ID"

=============================================================================
Federated Credentials Created:
=============================================================================

✓ Main branch:        repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/main
✓ Develop branch:     repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/develop
✓ Pull Requests:      repo:$GITHUB_ORG/$GITHUB_REPO:pull_request
✓ Dev Environment:    repo:$GITHUB_ORG/$GITHUB_REPO:environment:dev
✓ Test Environment:   repo:$GITHUB_ORG/$GITHUB_REPO:environment:test
✓ Prod Environment:   repo:$GITHUB_ORG/$GITHUB_REPO:environment:prod

=============================================================================
Azure Resources Created:
=============================================================================

App Registration:    $APP_NAME
App ID (Client ID):  $APP_ID
Object ID:           $OBJECT_ID
Service Principal:   $SP_ID
Tenant ID:           $TENANT_ID
Subscription:        $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)

Role Assignment:     Contributor (subscription scope)

EOF

if [ "${STORAGE_SETUP_DONE:-false}" = "true" ]; then
cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Terraform State Storage Configuration:
=============================================================================

Resource Group:      $STORAGE_RG
Storage Account:     $STORAGE_ACCOUNT
Container:           $STORAGE_CONTAINER

Role Assignment:     ✓ Storage Blob Data Contributor

EOF
elif [ "$SETUP_STORAGE" = "y" ]; then
cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Terraform State Storage Configuration:
=============================================================================

⚠️  Storage account not found. You must create it before running Terraform:

   az storage account create \\
     --name $STORAGE_ACCOUNT \\
     --resource-group $STORAGE_RG \\
     --location eastus \\
     --sku Standard_LRS \\
     --encryption-services blob
   
   az storage container create \\
     --name $STORAGE_CONTAINER \\
     --account-name $STORAGE_ACCOUNT
   
   # Then assign permissions:
   az role assignment create \\
     --assignee "$APP_ID" \\
     --role "Storage Blob Data Contributor" \\
     --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RG/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

EOF
else
cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Terraform State Storage Configuration:
=============================================================================

⚠️  Storage setup was skipped. Ensure backend storage exists and is accessible:

   1. Create storage account (if needed):
      az storage account create \\
        --name <storage-account-name> \\
        --resource-group <resource-group> \\
        --location eastus \\
        --sku Standard_LRS
   
   2. Create container:
      az storage container create \\
        --name tfstate \\
        --account-name <storage-account-name>
   
   3. Assign permissions:
      az role assignment create \\
        --assignee "$APP_ID" \\
        --role "Storage Blob Data Contributor" \\
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<storage-account>"

EOF
fi

if [ "${FABRIC_SETUP_DONE:-false}" = "true" ]; then
cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Fabric Capacity Configuration:
=============================================================================

Resource Group:      $FABRIC_RG
Capacity Name:       $FABRIC_CAPACITY
Capacity ID:         $FABRIC_CAPACITY_ID

Role Assignment:     Owner (Fabric Capacity scope)
Admin Member:        ✓ Service Principal added as Fabric Capacity admin

⚠️  IMPORTANT: Update your Terraform tfvars files!
    
    Add the following to ALL environment tfvars files:
    (infra/environments/dev.tfvars, test.tfvars, prod.tfvars)
    
    fabric_capacity_id = "$FABRIC_CAPACITY_ID"
    
    This is required because Terraform now uses direct capacity ID
    instead of looking up by name (avoiding list permission requirements).

EOF
elif [ "$SETUP_FABRIC" = "y" ]; then
cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Fabric Capacity Configuration:
=============================================================================

⚠️  Fabric setup was attempted but incomplete.
    Please manually add the service principal as Fabric Capacity admin:
    
    Service Principal Object ID: $SP_ID
    
    1. Go to Azure Portal > Fabric Capacity > Access Control (IAM)
    2. Add role assignment: Owner
    3. Assign to: $APP_NAME
    4. Also add as admin member via Azure CLI or Portal
    
    Once configured, get the Fabric Capacity ID and add to your tfvars:
    
    FABRIC_ID=\$(az fabric capacity show -g "$FABRIC_RG" -n "$FABRIC_CAPACITY" --query id -o tsv)
    
    Then update ALL environment tfvars files with:
    fabric_capacity_id = "\$FABRIC_ID"

EOF
else
cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Fabric Capacity Configuration:
=============================================================================

⚠️  Fabric Capacity setup was skipped.
    To enable Fabric Terraform provider access, you must:
    
    1. Install Fabric CLI extension:
       az extension add --name microsoft-fabric
    
    2. Add service principal as Fabric Capacity admin:
       SP_ID="$SP_ID"
       FABRIC_RG="<your-fabric-rg>"
       FABRIC_CAPACITY="<your-fabric-capacity>"
       
       # Get capacity
       FABRIC_JSON=\$(az fabric capacity show -g "\$FABRIC_RG" -n "\$FABRIC_CAPACITY" -o json)
       FABRIC_ID=\$(echo "\$FABRIC_JSON" | jq -r '.id')
       
       # Assign Owner role (required for Fabric OIDC operations)
       az role assignment create --assignee "\$SP_ID" --role Owner --scope "\$FABRIC_ID"
       
       # Add as admin member
       MEMBERS=\$(echo "\$FABRIC_JSON" | jq -c ".administration.members += [\"\$SP_ID\"] | .administration")
       az fabric capacity update -g "\$FABRIC_RG" -n "\$FABRIC_CAPACITY" --administration "\$MEMBERS"
    
    3. Update ALL environment tfvars files with capacity ID:
       
       fabric_capacity_id = "\$FABRIC_ID"
       
       This is required in: infra/environments/dev.tfvars, test.tfvars, prod.tfvars

EOF
fi

cat >> "$OUTPUT_FILE" <<EOF
=============================================================================
Authentication Configuration Summary:
=============================================================================

Azure Resource Manager (ARM):
  Provider:     azurerm
  Auth Method:  OIDC (OpenID Connect)
  Environment:  ARM_USE_OIDC=true
                ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID

Microsoft Fabric:
  Provider:     fabric
  Auth Method:  OIDC (OpenID Connect)
  Environment:  FABRIC_USE_OIDC=true
                FABRIC_CLIENT_ID, FABRIC_TENANT_ID
  
✓ No secrets or tokens needed - GitHub provides OIDC token automatically!
✓ Workflow has 'id-token: write' permission for OIDC

=============================================================================
Next Steps:
=============================================================================

1. Add the secrets to your GitHub repository (see commands above)

2. Update infra/environments/*.tfvars with Fabric Capacity ID:
   - Get capacity ID: az fabric capacity show -g <rg> -n <capacity> --query id -o tsv
   - Add to dev.tfvars, test.tfvars, prod.tfvars:
     fabric_capacity_id = "/subscriptions/.../providers/Microsoft.Fabric/capacities/..."

3. Configure Terraform backend for remote state (if not done)

4. Push changes to GitHub to trigger CI/CD workflows

5. Verify workflows run successfully in GitHub Actions

=============================================================================
EOF

print_message "Bootstrap complete! 🎉"
echo ""
print_message "Summary:"
echo "  App Registration: $APP_NAME"
echo "  Client ID: $APP_ID"
echo "  Tenant ID: $TENANT_ID"
echo "  Subscription ID: $SUBSCRIPTION_ID"
echo ""
print_message "Configuration details saved to: $OUTPUT_FILE"
echo ""
print_warning "IMPORTANT: Add the secrets to your GitHub repository!"
echo "Visit: https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions"
echo ""

# Optional: Open the file
if command -v code &> /dev/null; then
    read -p "Open $OUTPUT_FILE in VS Code? (y/n): " OPEN_FILE
    if [ "$OPEN_FILE" = "y" ]; then
        code "$OUTPUT_FILE"
    fi
fi

print_message "Done! You can now use GitHub Actions with Azure OIDC authentication."
