# Azure Todo Stack

Demo full-stack to-do application showcasing a Vite/React frontend, FastAPI backend, and Terraform-based Azure deployment. Use this repo to experiment with modern tooling (ShadCN UI, SQLModel, structlog) and IaC workflows targeting Azure Container Apps + Static Web Apps.

## Project Layout

```
backend/    # FastAPI app, SQLModel models, pytest suite
frontend/   # Vite + React + ShadCN UI client
infra/      # Terraform root + modules for Azure resources
docs/       # Architecture notes, decision logs
scripts/    # Helper scripts (build/push images, seed data, etc.)
```

## Toolchain Prereqs

- Node.js 20+, pnpm
- Python 3.11, [uv](https://github.com/astral-sh/uv)
- Terraform 1.6+
- Azure CLI (logged in to your subscription)

## Getting Started

1. Copy environment templates:
   ```bash
   cp .env.example backend/.env
   cp .env.example frontend/.env
   ```
2. Install dependencies:
   ```bash
   (cd backend && uv sync --extra dev)
   (cd frontend && pnpm install)
   ```
3. Local dev servers:
   - Backend: `cd backend && uv run uvicorn app.main:app --reload`
   - Frontend: `cd frontend && pnpm dev`
4. Run tests:
   - Backend: `cd backend && uv run pytest`
   - Frontend: `cd frontend && pnpm test`
5. Use the Docker workflow below for an integrated local dev loop.

## Local Dev with Docker Compose

1. Copy the Docker env template:
   ```bash
   cp backend/.env.docker.example backend/.env.docker
   ```
2. Start the stack (database, backend API, frontend dev server):
   ```bash
   ./scripts/dev.sh
   ```
   Override defaults by appending extra docker-compose flags, e.g. `./scripts/dev.sh --build`.
3. Tear everything down (including data volume):
   ```bash
   docker compose down -v
   ```

## Deploying to Azure

1. **Authenticate** – run `az login` and `az account set --subscription <id>`.
2. **Bootstrap remote state (first time only)**:
   ```bash
   RESOURCE_GROUP=rg-azuretodo-dev \
   LOCATION=japaneast \
   STORAGE_ACCOUNT=azuretodotfstate \
   CONTAINER=tfstate \
   ./scripts/bootstrap_tf_state.sh
   ```
3. **Configure Terraform** – copy `infra/terraform/terraform.tfvars.example` to `terraform.tfvars`, filling in subscription/tenant IDs, `container_image`, Postgres admin credentials, and ACR metadata.
4. **Build & push the backend image** (ships linux/amd64 for Container Apps):
   ```bash
   ./scripts/build_and_push_backend.sh --acr-name <acr-name>
   ```
   Override `--image-name`/`--tag` if you need custom values; the script pushes both the git SHA and `latest` tags.
5. **Provision infrastructure**:
   ```bash
   (cd infra/terraform && terraform init -backend-config=... && terraform plan && terraform apply)
   ```
   Terraform outputs include the API FQDN, frontend endpoint, Key Vault, and Postgres hostnames.
6. **Upload the frontend** (optionally overriding the API base URL with the Container App FQDN):
   ```bash
   ./scripts/deploy_frontend.sh \
     --storage-account <storage-account> \
     --api-url https://<container-app-fqdn>
   ```
   Pass `--no-build` if you already have `frontend/dist`; `--resource-group`/`--subscription` forward to Azure CLI calls.
7. **Run database migrations** (once per environment):
   ```bash
   cd backend
   DATABASE_URL="postgresql+psycopg://<admin_login>:<admin_password>@<postgres_fqdn>:5432/<db_name>" \
     uv run alembic upgrade head
   ```
   Grab the credentials from your Key Vault or Terraform outputs; append `?sslmode=require` if your policy enforces TLS.

Subsequent releases typically run steps 4–6. Update `container_image` in `terraform.tfvars` whenever you push a new backend tag.

## Continuous Integration

GitHub Actions workflow `.github/workflows/ci.yml` executes on every push/PR to `main`:
- Backend job installs dependencies via `uv` and runs `uv run pytest`.
- Frontend job installs pnpm dependencies and runs `pnpm test`.

On successful pushes to `main`, the `deploy` job runs and:
- Builds a linux/amd64 backend image with Docker Buildx and pushes it to the configured ACR using the commit SHA for tagging.
- Runs `terraform apply` (with remote state) so the Container App pulls the new image and updated environment settings.
- Executes Alembic migrations against the managed PostgreSQL instance.
- Builds the Vite frontend and uploads the assets to the `$web` container of the storage account via `az storage blob upload-batch --auth-mode login`.

### Required GitHub secrets

| Secret | Description |
| --- | --- |
| `AZURE_CREDENTIALS` | Service principal JSON (`az ad sp create-for-rbac --sdk-auth`) including `clientId`, `clientSecret`, `tenantId`, and `subscriptionId`. |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription GUID (must match `subscriptionId` in the credentials JSON). |
| `AZURE_TENANT_ID` | Azure tenant GUID corresponding to the service principal. |
| `ACR_NAME` / `ACR_LOGIN_SERVER` | Existing Azure Container Registry name (e.g. `azuretodoregistry`) and login server (`azuretodoregistry.azurecr.io`). |
| `ACR_RESOURCE_GROUP` | Resource group that houses the ACR instance. |
| `TF_VAR_PREFIX` | Resource name prefix used by Terraform (e.g. `azuretodo`). |
| `TF_STATE_RESOURCE_GROUP` | Resource group hosting the Terraform remote state storage account. |
| `TF_STATE_STORAGE_ACCOUNT` | Storage account name for Terraform state. |
| `TF_STATE_CONTAINER` | Blob container name for Terraform state (e.g. `tfstate`). |
| `TF_STATE_KEY` | Blob key used for this workspace’s state file (e.g. `azure-todo-dev.tfstate`). |
| `POSTGRES_ADMIN_LOGIN` / `POSTGRES_ADMIN_PASSWORD` | Flexible Server admin username and password injected into Terraform and migrations. |
| `POSTGRES_DB_NAME` | Logical database name (defaults to `todoapp`). |
| `STORAGE_ACCOUNT` | Storage account used for the Static Website hosting the frontend. |

Optional secrets:
- `TF_VAR_custom_domain` if you configure a custom hostname for the static site.

The deployment job expects Terraform backend access and Azure CLI operations to succeed using the supplied service principal. Ensure the account has `Contributor` (or more restrictive, appropriately-scoped) rights on the resource group(s) hosting the stack.

> **Note:** The workflow automatically imports the existing resource group into Terraform state if it is missing. The name is derived from the lowercased, alphanumeric prefix (e.g. `azuretodo`) and the environment (`dev` by default), producing `rg-azuretodo-dev`. If you change those values, keep the naming convention consistent.

Fix failing jobs locally using the same commands before pushing changes.

## Documentation

- `PLANS.md` – living ExecPlan describing the full build.
- `AGENTS.md` – orientation + working agreements.
- `docs/architecture.md` – architecture overview + deployment workflow diagram.
- `infra/terraform/README.md` – Infrastructure-as-code usage + deployment notes.
- `scripts/bootstrap_tf_state.sh` – helper to create Terraform remote state RG/storage/container.

## Status

Phase 4 Terraform scaffolding is ready; next up is wiring pipelines + deployments per `PLANS.md`.
