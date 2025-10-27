# ExecPlan: Azure Todo Stack

This plan explains how to build and deploy a full-stack to-do application consisting of a Vite/React/ShadCN frontend, a FastAPI backend with authentication/logging/database support, and a Terraform-based Azure deployment. Treat this file as the source of truth—if details change, update every section.

---

## Purpose & Intent

Deliver a demo-quality app that lets a signed-in user manage to-dos from a responsive web UI backed by FastAPI, persists data in Azure PostgreSQL, enforces JWT authentication, and can be provisioned end-to-end with Terraform. Success is measured by being able to:
1. Run the stack locally with seeded data, log in, and perform CRUD actions with visible logs.
2. Deploy identical infrastructure and app artifacts to a personal Azure subscription via `terraform apply` plus documented deployment commands.

---

## Living-Document Rules

- Always restate newly discovered constraints inside this file; do not assume prior context.
- At every major stopping point, update Concrete Steps, Validation, and Decision Log.
- Keep commands copy/paste-ready with explicit working directories.
- When work is incomplete, add TODOs or blocked notes so the next agent knows what remains.

---

## Requirements & Success Criteria

1. **Frontend**: Vite + React 18 + TypeScript + Tailwind + ShadCN UI kit. Implements auth screens (sign in/register), to-do list with filters, optimistic mutations via TanStack Query, and client-side form validation via Zod/react-hook-form.
2. **Backend**: FastAPI app exposing REST endpoints for auth (`/auth/register`, `/auth/token`, `/auth/me`) and todos (`/todos` CRUD). Uses SQLModel + Alembic with PostgreSQL, issues JWT access tokens signed via symmetric secret, integrates structlog (JSON) with request IDs, and exposes `/healthz`.
3. **Testing**: Backend pytest suite covering auth + CRUD; frontend Vitest covering components/state; optional Playwright smoke.
4. **Infrastructure**: Terraform >=1.6 with azurerm provider + remote state (Azure Storage). Resources: resource group, Log Analytics workspace, Azure Container Apps for API, Azure Static Web Apps (or Storage+CDN) for frontend, Azure Database for PostgreSQL Flexible Server, Key Vault for secrets, managed identity, and Application Insights/monitoring.
5. **Automation**: Document local dev scripts, `.env.example`, database migration workflow, Terraform workspace usage, and Azure authentication (Azure CLI + service principal).

---

## Risks & Unknowns

- Azure service quotas or region availability could block provisioning; plan defaults to `japaneast`.
- Container Apps vs App Service decision: Container Apps preferred for managed identity; App Service is fallback.
- ShadCN requires Tailwind + PostCSS config; ensure CLI runs post-scripts correctly.
- Secrets management must work locally (dotenv) and in Azure (Key Vault with references into Container App).

---

## Context and Orientation

- Repository root currently contains `.gitignore`, `AGENTS.md`, and this `PLANS.md`.
- Target structure after scaffolding:
  - `frontend/` – Vite React app.
  - `backend/` – FastAPI project (`pyproject.toml`, `app/`, `tests/`).
  - `infra/terraform/` – Terraform root with modules.
  - `docs/` – architecture notes.
- Tooling expectations: Node 20+, pnpm, Python 3.11 with `uv`, Terraform 1.6+, Azure CLI logged in to correct subscription.

---

## Plan of Work

### Current Focus (2025-10-27)
- [x] Phase 5 – Add helper scripts for backend image builds/pushes and frontend static uploads, including Azure CLI login guidance.
- [x] Phase 6 – Flesh out README + docs/architecture.md with deployment workflow, environment variables, and diagrams/notes.

### Phase 0 – Prereqs & Repo Scaffolding
1. Add `README.md`, `docs/architecture.md`, `.env.example`, backend/frontend `.env` templates.
2. Decide package managers (`pnpm` frontend, `uv` backend). Document installation commands.

### Phase 1 – Backend Foundation
1. Scaffold FastAPI app under `backend/` with structure:
   ```
   backend/
     app/__init__.py
     app/main.py
     app/config.py
     app/db.py
     app/models.py
     app/schemas.py
     app/auth.py
     app/api/routes/*.py
     app/logging.py
     scripts/seed.py
     tests/
   ```
2. Configure `pyproject.toml` (FastAPI, uvicorn, SQLModel, Alembic, psycopg, python-jose, passlib[bcrypt], structlog, httpx, pytest, pytest-asyncio, faker, coverage).
3. Implement config loading (Pydantic BaseSettings) for DB URL, JWT secret, log level, token lifetime.
4. Implement SQLModel models: `User`, `Todo`. Add Alembic env referencing SQLModel metadata.
5. Implement auth utilities (hashing via passlib, JWT encode/decode via python-jose). Provide OAuth2 password flow dependencies.
6. Add routers: `auth.py`, `todos.py`, `health.py`. Register in `main.py` with CORS for frontend origins.
7. Add logging via structlog middleware capturing `request_id` and `user_id`.
8. Provide tests covering auth, todo CRUD, 401 cases, healthz. Use test database (sqlite or ephemeral postgres) with fixtures.
9. Provide Makefile/Justfile targets: `dev`, `test`, `lint`, `migrate`.

### Phase 2 – Frontend Implementation
1. Initialize Vite React TS project in `frontend/`.
2. Add Tailwind, ShadCN CLI, Radix UI primitives, lucide icons, TanStack Query, axios, react-hook-form, zod, jotai or zustand for auth store, clsx/cva.
3. Configure environment typing (`src/env.d.ts`), absolute imports, and theme provider.
4. Implement UI shell (navbar with profile dropdown, notifications, theme toggle). Provide `RequestID` propagation by generating UUID per session.
5. Screens/components:
   - Auth pages (SignIn, Register) with client validation + API integration.
   - Dashboard listing todos with filters (all/active/completed), ability to add/edit/delete with optimistic updates.
   - Settings/profile page hitting `/auth/me`.
6. API client: axios instance with base URL `VITE_API_BASE_URL`, attaches bearer token, handles 401 by resetting auth.
7. Testing: configure Vitest + Testing Library + MSW. Provide tests for auth form validation and todo list interactions.
8. Build scripts: `pnpm dev`, `pnpm test`, `pnpm lint`, `pnpm build`. Document environment variables in `.env.example`.

### Phase 3 – Integration & Local Developer Experience
1. Create `docker-compose.yml` (services: `db`, `backend`, `frontend`, optional `traefik`). Provide `.env` for compose.
2. Add seed data script to create demo users/todos; run via `uv run scripts/seed.py` or docker exec.
3. Provide local run instructions: `make dev` (runs backend via uvicorn, frontend via Vite, Postgres via docker).
4. Document request flow and logging expectations.

### Phase 4 – Terraform Infrastructure
1. Structure Terraform root under `infra/terraform/`:
   ```
   backend.tf
   providers.tf
   variables.tf
   outputs.tf
   main.tf
   terraform.tfvars.example
   modules/
     resource_group
     log_analytics
     postgres
     key_vault
     container_app
     static_site
     container_registry
   ```
2. Remote state: Azure Storage account (document creation). `backend.tf` uses `azurerm` backend.
3. Modules details:
   - `resource_group`: create RG with name prefix variable.
   - `log_analytics`: workspace for diagnostics and Container App logs.
   - `postgres`: flexible server + database, private access optional, outputs connection string secret.
   - `key_vault`: stores JWT secret, DB credentials. Access policy for Container App managed identity.
   - `container_app`: deploys backend container image, attaches Log Analytics + identities, environment variables referencing Key Vault secrets.
   - `static_site`: either Azure Static Web App or Storage static website + CDN. Document whichever chosen with instructions.
   - `container_registry`: ACR to build/push backend images.
4. Provide variables for `subscription_id`, `tenant_id`, `location`, `env`, `container_image`, `frontend_source`, `custom_domain`.
5. Add `infra/terraform/README.md` describing workspace flow, remote-state prerequisites, and apply instructions.

### Phase 5 – Deployment Workflow
1. Document Azure CLI login + subscription set (`az login`, `az account set`).
2. Provide script `scripts/build_and_push_backend.sh` to tag/push backend image to ACR referencing current commit SHA.
3. Provide script `scripts/deploy_frontend.sh` to build Vite app and upload to Static Web resource.
4. Outline CI/CD (GitHub Actions) future work; optional stub pipeline.

### Phase 6 – Polishing & Docs
1. Update `README.md` with architecture, local dev, testing, deployment, troubleshooting.
2. Fill `docs/architecture.md` with diagrams/mermaid showing React -> FastAPI -> Postgres + Azure resources.
3. Ensure `.env.example`, `backend/.env.example`, `frontend/.env.example`, `infra/terraform/terraform.tfvars.example` are current.
4. Record outcomes in section below after each phase.

---

## Concrete Steps

> Run commands from repo root unless specified. Replace placeholders in angle brackets.

### Tool Install (once per machine)
- Node 20+, pnpm `npm install -g pnpm`.
- Python 3.11, install `uv` (`pip install uv` or `pipx install uv`).
- Terraform >= 1.6, Azure CLI (`brew install azure-cli`).

### Repo Setup
```bash
mkdir -p backend frontend infra/terraform docs scripts
cp .env.example backend/.env.example
cp .env.example frontend/.env.example
```

### Backend Commands
```bash
cd backend
uv init --package-name todo_api
uv add fastapi uvicorn[standard] sqlmodel sqlalchemy psycopg[binary] alembic python-jose[cryptography] passlib[bcrypt] structlog pydantic-settings email-validator
uv add --dev pytest pytest-asyncio httpx faker coverage
uv run alembic init migrations
uv run alembic revision --autogenerate -m "init"
uv run alembic upgrade head
uv run pytest
uv run uvicorn app.main:app --reload
```

### Frontend Commands
```bash
cd frontend
pnpm create vite@latest . --template react-ts
pnpm install
pnpm install -D tailwindcss postcss autoprefixer @types/node prettier eslint-config-prettier @testing-library/react @testing-library/jest-dom @testing-library/user-event vitest jsdom msw
pnpm install @tanstack/react-query axios zod react-hook-form jotai clsx class-variance-authority lucide-react sonner
npx tailwindcss init -p
pnpm dlx shadcn-ui@latest init
pnpm shadcn add button input form card textarea checkbox dropdown-menu avatar sheet dialog toast
pnpm test
pnpm build
```

### Local Integration
- Copy docker env template: `cp backend/.env.docker.example backend/.env.docker`.
- Start the stack: `./scripts/dev.sh` (accepts passthrough flags), then visit http://localhost:5173 and http://localhost:8000/docs.
- Tear down: `docker compose down -v`.

### Terraform Workflow
```bash
cd infra/terraform
cat > backend.tf <<'HCL'
terraform {
  backend "azurerm" {}
}
HCL
terraform init -backend-config="resource_group_name=<rg>" -backend-config="storage_account_name=<storage>" -backend-config="container_name=terraform" -backend-config="key=todoapp.tfstate"
terraform fmt
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Deployment Steps
1. Build backend image and push to ACR:
   ```bash
   ./scripts/build_and_push_backend.sh --acr-name <acr_name>
   ```
   (Override `--tag` or `--image-name` as needed and update `container_image` in `terraform.tfvars`.)
2. Build frontend and upload to Static Web/Storage:
   ```bash
   ./scripts/deploy_frontend.sh \
     --storage-account <storage_account> \
     --api-url https://<container_app_fqdn>
   ```
   Pass `--no-build` if `frontend/dist` already exists.
3. Run Alembic migrations against the managed Postgres instance:
   ```bash
   cd backend
   DATABASE_URL="postgresql+psycopg://<admin_login>:<admin_password>@<postgres_fqdn>:5432/<db_name>" \
     uv run alembic upgrade head
   ```
   Use the Terraform outputs/Key Vault secrets and add `?sslmode=require` if necessary.
4. Rerun `terraform apply` to reference new artifact tags/urls.

---

## Validation and Acceptance

- **Backend**: `uv run pytest` passes; manual tests hitting `/auth/register`, `/auth/token`, `/todos` succeed; JSON logs contain `request_id`.
- **Frontend**: `pnpm test` passes; manual run `pnpm dev` allows registration/login/todo CRUD with optimistic updates.
- **Integration**: docker compose environment works end-to-end; user actions persisted in Postgres; both services respect `.env`.
- **Terraform**: `terraform plan` clean after apply; outputs include API FQDN, frontend URL, Key Vault name, Postgres host.
- **Azure smoke**: After deployment, STATIC_WEB_URL loads app, API health endpoint responds 200 via HTTPS, Key Vault secrets accessible by Container App.

---

## Idempotence and Recovery

- Alembic migrations may be rerun safely using `uv run alembic upgrade head`; use new revision to roll forward.
- Docker compose can be restarted via `docker compose down -v && docker compose up --build` to reset DB.
- Terraform operations are idempotent; use workspaces for `dev`, `prod`. To recover failed apply, fix configuration and rerun `terraform apply`, or use `terraform state rm` cautiously per HashiCorp guidance.
- Deployment scripts tag images with commit SHA; redeploying same SHA is safe but requires updating Terraform variable if underlying image changes.

---

## Artifacts and Notes

- Store first successful `uv run pytest` and `terraform apply` outputs in `docs/notes.md` for auditing.
- Capture sample structlog entry:
  ```json
  {"timestamp":"2024-05-06T12:00:00Z","level":"info","event":"todo_created","request_id":"...","user_id":"..."}
  ```
- Maintain architecture diagram (Mermaid) inside `docs/architecture.md` showing Browser → Static Web → FastAPI Container App → Postgres/Key Vault/Log Analytics.

---

## Interfaces and Dependencies

### Backend API Surface
- `POST /auth/register` body `{email, password, full_name}` → 201.
- `POST /auth/token` (OAuth2 password) returns `{access_token, token_type}` (Bearer).
- `GET /auth/me` returns user profile.
- `GET /todos` returns list of todos for authenticated user.
- `POST /todos` create todo.
- `PATCH /todos/{id}` update title/description/is_completed.
- `DELETE /todos/{id}` remove todo.
- `GET /healthz` readiness probe.

### Data Models
- `User`: `id UUID`, `email str unique`, `password_hash str`, `full_name str`, timestamps.
- `Todo`: `id UUID`, `owner_id UUID FK`, `title str`, `description Optional[str]`, `is_completed bool`, timestamps.

### Auth & Security
- Hash passwords with bcrypt via passlib.
- JWT claims: `sub`, `iat`, `exp`. Access token lifetime 60 minutes; refresh token optional future work.
- CORS: allow `http://localhost:5173` and Azure Static Web hostname.

### Logging & Observability
- structlog processors: add timestamps, level, event, contextual fields (`request_id`, `user_id`, `path`, `status_code`).
- On Azure, Container App sends logs to Log Analytics workspace provided via Terraform outputs.
- Add Application Insights for additional telemetry (optional stretch if Container Apps + Dapr scenario).

### Terraform Interfaces
- Each module exposes variables/outputs documented in `README`s. Example `modules/container_app` inputs: `name`, `resource_group`, `location`, `image`, `env_variables`, `secret_environment_variables`, `log_workspace_id`, `log_workspace_key`.
- Remote state backend requires storage account + container created manually (document command `az storage account create ...`).
- Use terraform variable `deploy_environment` to namespace resources (e.g., `demo`, `prod`).

---

## Outcomes & Retrospective

- 2024-05-06: Phase 0 scaffolding complete (repo structure, env templates, README/doc stubs). Backend Phase 1 delivered FastAPI project with auth, todos, SQLModel/Alembic baseline plus pytest coverage. Next focus: polish backend logging/metrics and begin frontend scaffold.
- 2024-05-07: Phase 2 implemented Vite/React frontend with ShadCN-inspired component library, auth pages, todo dashboard, theming, axios/query clients, and Vitest coverage. Ready to integrate with backend & refine UX.
- 2024-05-07: Step 2 next actions & Phase 3 completed (GitHub Actions CI plus docker-compose stack/scripts, README updates). Local integration loop is automated; Terraform build-out is next.
- Later phases should append dated bullet summaries with gaps + next steps.

---

## Decision Log

- Decision: Use SQLModel + Alembic for ORM/migrations to keep FastAPI integration ergonomics high while maintaining SQLAlchemy compatibility.
  Rationale: SQLModel offers Pydantic-style models with SQLAlchemy core enabling type safety and schema generation.
  Date/Author: 2024-05-06/Codex

- Decision: Target Azure Container Apps for the backend and Azure Static Web Apps (storage fallback) for the frontend.
  Rationale: Container Apps support managed identities + secrets and scale-to-zero; Static Web Apps provide global CDN and easy integration.
  Date/Author: 2024-05-06/Codex

- Decision: Grant the Terraform runner `Key Vault Secrets Officer` on provisioned vaults using RBAC assignments managed in Terraform.
  Rationale: The CI service principal needs create/update privileges to manage secrets (`azurerm_key_vault_secret`) without manual role configuration.
  Date/Author: 2025-10-27/Codex

- Decision: Adopt pnpm + Vite for frontend and uv for backend dependency management.
  Rationale: pnpm is fast with workspace support; uv keeps Python deps reproducible without Poetry overhead.
  Date/Author: 2024-05-06/Codex

- Decision: Use GitHub Actions CI to gate backend pytest and frontend pnpm test on every push/PR.
  Rationale: Keeps core quality checks automated without waiting for Terraform/infra pieces, using the same commands developers run locally.
  Date/Author: 2024-05-07/Codex

- Decision: Standardize local integration with docker-compose plus helper script, mirroring Azure deployment topology (Postgres + FastAPI + Vite).
  Rationale: Provides a reproducible dev loop without installing Postgres locally and simplifies onboarding for multi-service work.
  Date/Author: 2024-05-07/Codex

- Decision: Use React Query + custom AuthProvider/axios interceptors with ShadCN-influenced components for the frontend.
  Rationale: React Query handles optimistic CRUD syncing with the FastAPI API, while a focused auth context keeps token management and 401 recovery centralized; ShadCN primitives keep the UI consistent without relying on the CLI.
  Date/Author: 2024-05-07/Codex

- Decision: Container Apps use the managed identity + ACR login server for image pulls, and backend images are built/pushed as linux/amd64.
  Rationale: Without passing the registry server Terraform could not create the Container App, and Azure requires amd64 images for Container Apps.
  Date/Author: 2025-10-26/Codex

- Decision: Extended Key Vault RBAC propagation wait times in both GitHub Actions workflow (up to 5 minutes with verification) and Terraform (120s) to address 403 Forbidden errors when creating secrets.
  Rationale: Azure RBAC can take several minutes to propagate, especially for Key Vault operations. The workflow now waits 60s after creating role assignments, then polls for up to 20 attempts (5 minutes total) to verify access. Terraform waits 120s before attempting secret operations.
  Date/Author: 2025-10-27/Codex

Add future decisions below with the same template.

---

## Update Log

- 2024-05-06: Initial ExecPlan authored to guide full-stack + Terraform implementation (Codex).
- 2024-05-06: Executed Phase 0 + Phase 1 backend scope; updated Outcomes (Codex).
- 2024-05-07: Completed Phase 2 frontend scaffold with auth/todo flows, theming, tests, and updated docs (Codex).
- 2024-05-07: Added GitHub Actions CI, docker-compose stack, and README/plan updates for Phase 3 integration (Codex).
- 2025-10-26: Infra fix – Container App now references the registry login server, linux/amd64 backend image pushed, and `terraform apply` succeeds end-to-end (Codex).
- 2025-10-27: Delivered Phase 5/6 artifacts – deployment helper scripts, Azure deployment docs, and refreshed architecture overview (Codex).
- 2025-10-27: Resolved production CORS + Postgres issues, introduced regex support, refreshed connection strings, and verified registration/login flows against Azure (Codex).
- 2025-10-27: Fixed GitHub Actions CI workflow Key Vault RBAC propagation issues by extending wait times and adding verification polling. Increased Terraform time_sleep to 120s for more reliable secret creation (Codex).
