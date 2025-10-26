#!/usr/bin/env bash
set -euo pipefail

echo "Starting Azure Todo stack via docker compose..."
docker compose up --build "$@"
