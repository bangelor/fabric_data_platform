# GitHub Environment Setup for Manual Approvals

## Overview
This repository uses GitHub Environments to control deployments. Production deployments require manual approval before applying changes.

## Required Environments

Create these environments in your GitHub repository:

1. **dev** - Development environment (auto-deploy on push to main)
2. **test** - Test environment (auto-deploy on push to main)
3. **prod** - Production environment (requires manual approval)

## Setup Instructions

### 1. Navigate to Environment Settings

Go to: `https://github.com/bangelor/fabric_data_platform/settings/environments`

Or:
1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. Click **Environments** (left sidebar)

### 2. Create Each Environment

For each environment (dev, test, prod):

1. Click **New environment**
2. Enter the environment name (exactly: `dev`, `test`, or `prod`)
3. Click **Configure environment**

### 3. Configure Production Protection Rules

For the **prod** environment specifically:

#### Required Reviewers
1. Check **Required reviewers**
2. Add yourself and/or team members who should approve prod deployments
3. Minimum: 1 reviewer
4. Recommended: 2+ reviewers for production safety

#### Deployment Branches (Optional but Recommended)
1. Check **Deployment branches**
2. Select **Selected branches**
3. Add rule: `main` (only allow prod deployments from main branch)

#### Wait Timer (Optional)
1. Enable **Wait timer** if you want a delay before deployment
2. Set to desired minutes (e.g., 5 minutes)

### 4. Configure Dev/Test Environments (Optional)

For **dev** and **test** environments, you can optionally add:

- **Deployment branches**: Restrict to specific branches
- **Environment secrets**: If you need environment-specific secrets
- No required reviewers needed (these auto-deploy)

## How It Works

### Automatic Deployment (Dev & Test)
When you push to `main` branch (merge a PR):
```
Push to main → Plan all envs → Auto-deploy dev → Auto-deploy test
```

### Manual Deployment (Production)
To deploy to production:
```
1. Go to Actions → "Deploy to Production"
2. Click "Run workflow"
3. Type "deploy-prod" in the confirmation field
4. Click "Run workflow"
5. ⚠️ WAIT for approval notification
6. Reviewer approves deployment
7. Deployment proceeds
```

### Pull Request Flow
When you create a PR:
```
Create PR → Plan all envs → Comment on PR with plans
No deployments happen until merged to main
```

## Notification Setup

To receive approval notifications:

1. Go to: https://github.com/settings/notifications
2. Enable **GitHub Actions** notifications
3. Choose your preferred notification method (email, mobile, etc.)

## Emergency Bypass (Not Recommended)

If you absolutely need to deploy prod without approval:

1. Temporarily remove required reviewers from prod environment
2. Run workflow for prod
3. **Immediately re-enable** required reviewers after deployment

⚠️ **This defeats the purpose of the safety mechanism. Use only in emergencies!**

## Verification

To verify your setup works:

1. Create a test change in Terraform
2. Open a PR to see plans
3. Merge to main → dev/test should auto-deploy
4. Run workflow for prod → should wait for approval
5. Approve → deployment proceeds

## Troubleshooting

### "Environment not found" error
- Make sure environment names are **exactly**: `dev`, `test`, `prod` (lowercase)
- Check: Settings → Environments → verify all three exist

### Prod deploys without approval
- Check prod environment has **Required reviewers** enabled
- Verify you added at least one reviewer
- Ensure you're using the `terraform-apply-prod` job (not bypassing it)

### Can't approve own deployment
- GitHub requires a different user to approve
- Add another team member as reviewer, or
- Use a second GitHub account for approvals (not recommended)

## Best Practices

1. ✅ **Always** require 2+ reviewers for prod
2. ✅ Use PR-based workflow for all changes
3. ✅ Review detailed Terraform plan before approving
4. ✅ Deploy to dev/test first, verify, then prod
5. ✅ Set up Slack/Teams notifications for deployment approvals
6. ❌ **Never** bypass approval requirements
7. ❌ Don't approve your own changes (use another team member)

## Related Documentation

- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Deployment Protection Rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#deployment-protection-rules)
