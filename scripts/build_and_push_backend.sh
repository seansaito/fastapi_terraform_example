#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/build_and_push_backend.sh --acr-name <name> [options]

Required:
  --acr-name <name>          Azure Container Registry name (without .azurecr.io)

Optional:
  --image-name <name>        Image repository name (default: todo-api)
  --tag <tag>                Image tag to push (default: current git short SHA)
  --context <path>           Build context (default: backend directory)
  --platform <value>         Target platform for buildx (default: linux/amd64)
  --latest-tag <tag>         Additional tag to publish (default: latest; empty string to skip)
  -h, --help                 Show this message

Prerequisites:
  - Azure CLI logged in (`az login`) with access to the target subscription.
  - Docker Buildx configured (Docker Desktop provides it by default).

Example:
  scripts/build_and_push_backend.sh --acr-name azuretodoregistry
USAGE
}

ACR_NAME=""
IMAGE_NAME="todo-api"
TAG=""
CONTEXT=""
PLATFORM="linux/amd64"
LATEST_TAG="latest"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --acr-name)
      ACR_NAME="${2:-}"
      shift 2
      ;;
    --image-name)
      IMAGE_NAME="${2:-}"
      shift 2
      ;;
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    --context)
      CONTEXT="${2:-}"
      shift 2
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --latest-tag)
      LATEST_TAG="${2:-}"
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

if [[ -z "$ACR_NAME" ]]; then
  echo "Error: --acr-name is required." >&2
  usage
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTEXT="${CONTEXT:-${REPO_ROOT}/backend}"

if [[ -z "$TAG" ]]; then
  if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    TAG="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
  else
    echo "Error: --tag not provided and git SHA unavailable." >&2
    exit 1
  fi
fi

REGISTRY="${ACR_NAME}.azurecr.io"
IMAGE_REF="${REGISTRY}/${IMAGE_NAME}"

echo "Logging into ACR: ${ACR_NAME}..."
az acr login --name "$ACR_NAME" >/dev/null

BUILD_ARGS=(
  docker buildx build
  --platform "$PLATFORM"
  -t "${IMAGE_REF}:${TAG}"
)

if [[ -n "$LATEST_TAG" ]]; then
  BUILD_ARGS+=(-t "${IMAGE_REF}:${LATEST_TAG}")
fi

BUILD_ARGS+=(--push "$CONTEXT")

echo "Building and pushing image ${IMAGE_REF}:${TAG}..."
"${BUILD_ARGS[@]}"

cat <<EOF

✅ Image pushed:
  ${IMAGE_REF}:${TAG}
$( [[ -n "$LATEST_TAG" ]] && echo "  ${IMAGE_REF}:${LATEST_TAG}" )

Update infra/terraform/terraform.tfvars with:
  container_image = "${IMAGE_REF}:${TAG}"
EOF
