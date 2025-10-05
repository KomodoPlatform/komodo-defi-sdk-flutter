# Firebase GitHub Secrets Scripts

This directory contains scripts for managing Firebase service account secrets used by GitHub Actions workflows.

## Scripts

### setup-github-secrets.sh

Automates the creation and configuration of Firebase service accounts and GitHub repository secrets.

**What it does:**
- Creates service accounts in Google Cloud projects (if they don't exist)
- Grants required IAM permissions for Firebase deployments
- Generates service account keys
- Creates/updates GitHub repository secrets
- Cleans up sensitive key files

**Usage:**
```bash
./.github/scripts/firebase/setup-github-secrets.sh
```

### verify-github-secrets.sh

Verifies that Firebase service accounts and GitHub secrets are properly configured.

**What it checks:**
- Prerequisites (gcloud, gh, jq installations)
- Authentication status (Google Cloud and GitHub)
- Firebase project accessibility
- Service account existence and permissions
- GitHub secret configuration

**Usage:**
```bash
./.github/scripts/firebase/verify-github-secrets.sh
```

## Required Permissions

To run these scripts, you need:
- Admin access to Firebase projects (`komodo-defi-sdk` and `komodo-playground`)
- Write access to GitHub repository secrets
- Google Cloud CLI (`gcloud`) authenticated
- GitHub CLI (`gh`) authenticated

## Related Documentation

For detailed setup instructions and troubleshooting, see:
[Firebase Deployment Setup Guide](../../../docs/firebase/firebase-deployment-setup.md)
