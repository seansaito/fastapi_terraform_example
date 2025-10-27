#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/deploy_frontend.sh --storage-account <name> [options]

Required:
  --storage-account <name>   Azure Storage account hosting the static website

Optional:
  --dist-path <path>         Directory to upload (default: frontend/dist)
  --build                    Run `pnpm --dir frontend build` before uploading (default: enabled)
  --no-build                 Skip the build step (use existing dist output)
  --container <name>         Destination container (default: $web)
  --resource-group <name>    Storage account resource group (used for az storage account show)
  --subscription <id>        Azure subscription to target (passes through to az commands)
  --api-url <url>            Override Vite VITE_API_BASE_URL during build
  -h, --help                 Show this help message

Prerequisites:
  - Azure CLI logged in (`az login`) and pointing to the right subscription.
  - Frontend dependencies installed (`pnpm install`).

Example:
  scripts/deploy_frontend.sh --storage-account stazuretododevcmss
USAGE
}

STORAGE_ACCOUNT=""
DIST_PATH=""
RUN_BUILD=true
CONTAINER="\$web"
RESOURCE_GROUP=""
SUBSCRIPTION=""
API_URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --storage-account)
      STORAGE_ACCOUNT="${2:-}"
      shift 2
      ;;
    --dist-path)
      DIST_PATH="${2:-}"
      shift 2
      ;;
    --build)
      RUN_BUILD=true
      shift 1
      ;;
    --no-build)
      RUN_BUILD=false
      shift 1
      ;;
    --container)
      CONTAINER="${2:-}"
      shift 2
      ;;
    --resource-group)
      RESOURCE_GROUP="${2:-}"
      shift 2
      ;;
    --subscription)
      SUBSCRIPTION="${2:-}"
      shift 2
      ;;
    --api-url)
      API_URL="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$STORAGE_ACCOUNT" ]]; then
  echo "Error: --storage-account is required." >&2
  usage
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_PATH="${DIST_PATH:-${REPO_ROOT}/frontend/dist}"

if [[ "$RUN_BUILD" == true ]]; then
  echo "Building frontend with pnpm..."
  if [[ -n "$API_URL" ]]; then
    echo "Using API base URL: $API_URL"
    (cd "${REPO_ROOT}/frontend" && VITE_API_BASE_URL="$API_URL" pnpm build)
  else
    pnpm --dir "${REPO_ROOT}/frontend" build
  fi
fi

if [[ ! -d "$DIST_PATH" ]]; then
  echo "Error: dist path '$DIST_PATH' does not exist. Did the build succeed?" >&2
  exit 1
fi

ACCOUNT_SHOW_CMD=(az storage account show --name "$STORAGE_ACCOUNT")
UPLOAD_CMD=(az storage blob upload-batch --account-name "$STORAGE_ACCOUNT" --destination "$CONTAINER" --source "$DIST_PATH" --pattern "*" --overwrite)

if [[ -n "$RESOURCE_GROUP" ]]; then
  echo "Ensuring storage account ${STORAGE_ACCOUNT} exists in ${RESOURCE_GROUP}..."
  ACCOUNT_SHOW_CMD+=(--resource-group "$RESOURCE_GROUP")
else
  echo "Ensuring storage account ${STORAGE_ACCOUNT} exists..."
fi

if [[ -n "$SUBSCRIPTION" ]]; then
  ACCOUNT_SHOW_CMD+=(--subscription "$SUBSCRIPTION")
  UPLOAD_CMD+=(--subscription "$SUBSCRIPTION")
fi

"${ACCOUNT_SHOW_CMD[@]}" >/dev/null

echo "Uploading ${DIST_PATH} to container ${CONTAINER} in ${STORAGE_ACCOUNT}..."
"${UPLOAD_CMD[@]}"

echo "✅ Frontend uploaded. Browse the static site endpoint printed by Terraform outputs."
