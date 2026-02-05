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

# Assign Contributor role to the subscription
print_message "Assigning Contributor role to subscription..."
az role assignment create \
    --assignee "$APP_ID" \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    2>/dev/null || print_warning "Role assignment may already exist"

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

✓ Main branch (Production):    repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/main
✓ Develop branch (Development): repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/develop
✓ Pull Requests:                repo:$GITHUB_ORG/$GITHUB_REPO:pull_request

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

=============================================================================
Backend State Storage Setup (Optional):
=============================================================================

To configure Terraform remote state in Azure Storage:

1. Create a storage account:
   az storage account create \\
     --name stterraformstate\$RANDOM \\
     --resource-group rg-terraform-state \\
     --location eastus \\
     --sku Standard_LRS \\
     --encryption-services blob

2. Create a container:
   az storage container create \\
     --name tfstate \\
     --account-name <storage_account_name>

3. Update infra/backend.tf with the storage account details

=============================================================================
Next Steps:
=============================================================================

1. Add the secrets to your GitHub repository (see commands above)
2. Configure Terraform backend for remote state (optional)
3. Update infra/environments/*.tfvars with your environment values
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
