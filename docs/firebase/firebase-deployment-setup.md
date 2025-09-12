# Firebase GitHub Secrets Setup

This document provides instructions for setting up Firebase GitHub secrets using the automated scripts or manual process.

## Overview

The Komodo DeFi SDK Flutter project uses Firebase Hosting for deploying two web applications:

1. **SDK Example** - Deployed to `komodo-defi-sdk` Firebase project
2. **Playground** - Deployed to `komodo-playground` Firebase project

GitHub Actions workflows require service account credentials to deploy to these Firebase projects.

## Prerequisites

### Required Tools

- **Google Cloud SDK (gcloud)** - [Installation Guide](https://cloud.google.com/sdk/docs/install)
- **GitHub CLI (gh)** - [Installation Guide](https://cli.github.com/manual/installation)
- **jq** (for verification script) - JSON processor

### Required Access

- Admin access to both Firebase projects:
  - `komodo-defi-sdk`
  - `komodo-playground`
- Write access to the GitHub repository secrets

## Automated Setup

We provide scripts to automate the entire setup process:

### 1. Setup Script

Run the setup script to create service accounts and configure GitHub secrets:

```bash
./.github/scripts/firebase/setup-github-secrets.sh
```

This script will:

- Check all prerequisites
- Create service accounts (if they don't exist)
- Grant necessary IAM permissions
- Generate service account keys
- Create/update GitHub repository secrets
- Clean up sensitive key files

### 2. Verification Script

Verify your setup is correct:

```bash
./.github/scripts/firebase/verify-github-secrets.sh
```

This script will check:

- Tool installations
- Authentication status
- Service account existence
- IAM permissions
- GitHub secrets existence

## Manual Setup

If you prefer to set up manually or need to troubleshoot:

### Step 1: Authenticate with Google Cloud

```bash
gcloud auth login
gcloud auth application-default login
```

### Step 2: Create Service Accounts

For komodo-defi-sdk:

```bash
gcloud config set project komodo-defi-sdk
gcloud iam service-accounts create github-actions-deploy \
    --display-name="GitHub Actions Deploy" \
    --description="Service account for GitHub Actions Firebase deployments"
```

For komodo-playground:

```bash
gcloud config set project komodo-playground
gcloud iam service-accounts create github-actions-deploy \
    --display-name="GitHub Actions Deploy" \
    --description="Service account for GitHub Actions Firebase deployments"
```

### Step 3: Grant Permissions

For each project, grant the required roles:

```bash
# Set project (komodo-defi-sdk or komodo-playground)
PROJECT_ID="komodo-defi-sdk"  # or "komodo-playground"
SERVICE_ACCOUNT_EMAIL="github-actions-deploy@${PROJECT_ID}.iam.gserviceaccount.com"

# Grant roles
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/firebase.hosting.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/firebase.rules.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/iam.serviceAccountTokenCreator"
```

### Step 4: Generate Service Account Keys

For komodo-defi-sdk:

```bash
gcloud iam service-accounts keys create komodo-defi-sdk-key.json \
    --iam-account="github-actions-deploy@komodo-defi-sdk.iam.gserviceaccount.com" \
    --project="komodo-defi-sdk"
```

For komodo-playground:

```bash
gcloud iam service-accounts keys create komodo-playground-key.json \
    --iam-account="github-actions-deploy@komodo-playground.iam.gserviceaccount.com" \
    --project="komodo-playground"
```

### Step 5: Create GitHub Secrets

```bash
# Authenticate with GitHub CLI
gh auth login

# Create secrets
gh secret set FIREBASE_SERVICE_ACCOUNT_KOMODO_DEFI_SDK \
    < komodo-defi-sdk-key.json \
    --repo KomodoPlatform/komodo-defi-sdk-flutter

gh secret set FIREBASE_SERVICE_ACCOUNT_KOMODO_PLAYGROUND \
    < komodo-playground-key.json \
    --repo KomodoPlatform/komodo-defi-sdk-flutter
```

### Step 6: Clean Up Key Files

⚠️ **IMPORTANT**: Delete the key files after creating GitHub secrets:

```bash
rm -f komodo-defi-sdk-key.json
rm -f komodo-playground-key.json
```

## Testing the Setup

After setting up the secrets, you can test the deployment:

1. **Create a Pull Request** - This triggers the PR preview workflow
2. **Push to `dev` branch** - This triggers the merge deployment workflow

Check the GitHub Actions tab in the repository to monitor the deployment status.

## Troubleshooting

### Common Issues

1. **Authentication Errors**

   - Ensure you're logged in: `gcloud auth login` and `gh auth login`
   - Check you have the correct permissions in both Google Cloud and GitHub

2. **Service Account Permission Errors**

   - Verify all three required roles are granted
   - Wait a few minutes for IAM changes to propagate

3. **GitHub Secret Errors**
   - Ensure the entire JSON key file content is copied
   - Check for any extra whitespace or formatting issues

### Debugging Commands

Check current gcloud configuration:

```bash
gcloud config list
gcloud auth list
```

List service accounts:

```bash
gcloud iam service-accounts list --project=komodo-defi-sdk
gcloud iam service-accounts list --project=komodo-playground
```

Check IAM bindings:

```bash
gcloud projects get-iam-policy komodo-defi-sdk
gcloud projects get-iam-policy komodo-playground
```

List GitHub secrets:

```bash
gh secret list --repo KomodoPlatform/komodo-defi-sdk-flutter
```

## Security Best Practices

1. **Never commit service account keys** to the repository
2. **Delete local key files** immediately after use
3. **Rotate keys periodically** for security
4. **Use least privilege** - only grant necessary permissions
5. **Monitor usage** through Google Cloud Console

## Additional Resources

- [Firebase Admin SDK Service Accounts](https://firebase.google.com/docs/admin/setup#initialize-sdk)
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Google Cloud IAM Documentation](https://cloud.google.com/iam/docs)
- [Firebase Hosting GitHub Action](https://github.com/FirebaseExtended/action-hosting-deploy)
