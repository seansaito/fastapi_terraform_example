#!/usr/bin/env bash
set -euo pipefail

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) is required." >&2
  exit 1
fi

RESOURCE_GROUP=${RESOURCE_GROUP:-}
LOCATION=${LOCATION:-}
STORAGE_ACCOUNT=${STORAGE_ACCOUNT:-}
CONTAINER=${CONTAINER:-tfstate}

if [[ -z "$RESOURCE_GROUP" || -z "$LOCATION" || -z "$STORAGE_ACCOUNT" ]]; then
  cat <<'USAGE'
ERROR: Missing required env vars.
Set RESOURCE_GROUP, LOCATION, STORAGE_ACCOUNT (alphanumeric, <=24 chars, lowercase).
Optionally set CONTAINER (default tfstate).
Example:
  RESOURCE_GROUP=rg-azuretodo-dev \
  LOCATION=japaneast \
  STORAGE_ACCOUNT=azuretodotfstate \
  CONTAINER=tfstate \
  ./scripts/bootstrap_tf_state.sh
USAGE
  exit 1
fi

set +e
az account show >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "You must az login before running this script." >&2
  exit 1
fi
set -e

echo "Ensuring resource group $RESOURCE_GROUP exists..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null

SA=$(echo "$STORAGE_ACCOUNT" | tr '[:upper:]' '[:lower:]')
if [[ $SA != "$STORAGE_ACCOUNT" ]]; then
  echo "Normalized storage account to lowercase: $SA"
  STORAGE_ACCOUNT=$SA
fi

if [[ ${#STORAGE_ACCOUNT} -gt 24 ]]; then
  echo "Storage account name must be <=24 characters" >&2
  exit 1
fi

NAME_AVAILABLE=$(az storage account check-name --name "$STORAGE_ACCOUNT" --query 'nameAvailable' -o tsv)
if [[ "$NAME_AVAILABLE" == "true" ]]; then
  echo "Creating storage account $STORAGE_ACCOUNT in $RESOURCE_GROUP..."
  az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true >/dev/null
else
  echo "Storage account $STORAGE_ACCOUNT already exists (or name unavailable)."
fi

ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --query '[0].value' -o tsv)

echo "Ensuring blob container $CONTAINER exists..."
az storage container create --name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" >/dev/null

echo "Backend bootstrap complete. Use these backend-config values:\n"
cat <<EOF
resource_group_name=$RESOURCE_GROUP
storage_account_name=$STORAGE_ACCOUNT
container_name=$CONTAINER
key=${STORAGE_ACCOUNT}_${CONTAINER}.tfstate
access_key=$ACCOUNT_KEY
EOF
