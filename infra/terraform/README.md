# Terraform Deployment (Phase 4)

This directory provisions the Azure resources required for the Azure Todo Stack:

- Resource group
- Log Analytics workspace
- Optional Azure Container Registry
- Azure Key Vault
- Azure Database for PostgreSQL Flexible Server
- Azure Container Apps environment + backend container
- Storage Account (Static Website) for the Vite frontend

## Prerequisites

1. Terraform `>= 1.6`
2. Azure CLI authenticated (`az login`) and set to the proper subscription (`az account set --subscription <id>`)
3. Remote state storage (recommended): create a storage account + container beforehand, then populate `backend.tf` via `terraform init -backend-config=...`.

## Bootstrap Remote State (optional helper)

If you do not already have a storage account + container for Terraform state, run the helper script (after `az login`):

```bash
RESOURCE_GROUP=rg-azuretodo-dev \
LOCATION=eastus \
STORAGE_ACCOUNT=azuretodotfstate \
CONTAINER=tfstate \
./scripts/bootstrap_tf_state.sh
```

The script ensures the resource group, storage account, and blob container exist and prints the `backend-config` values to reuse for `terraform init`.

## Usage

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with subscription_id, tenant_id, container image, secrets, etc.
terraform init -backend-config="resource_group_name=<rg>" \
  -backend-config="storage_account_name=<sa>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=azure-todo-dev.tfstate"
terraform plan
terraform apply
```

### Variables of Interest

| Variable | Description |
| --- | --- |
| `subscription_id` / `tenant_id` | Azure identifiers for the deployment |
| `prefix` & `environment` | Used to build resource names (`<prefix>-<env>`) |
| `container_image` | Fully qualified backend image (e.g. from ACR/GHCR) |
| `postgres_admin_password` | Password for the flexible server admin account (store securely) |
| `enable_container_registry` | Set to true to provision an Azure Container Registry in the stack |
| `custom_domain` | Optional custom domain for the static website |

## Outputs

- `resource_group_name` – deployed RG
- `container_app_fqdn` – public API hostname
- `frontend_endpoint` – static website URL
- `postgres_fqdn` – database host
- `key_vault_name` – Key Vault storing secrets

## Post-Apply Steps

1. Upload frontend assets to the storage account (from repo root):
   ```bash
   pnpm --dir frontend build
   az storage blob upload-batch -s frontend/dist -d '$web' --account-name <storage_account>
   ```
2. Update DNS if `custom_domain` is set (create CNAME pointing to storage endpoint).
3. Push backend images to your registry and update `container_image` before re-running `terraform apply` for new releases.
