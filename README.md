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

## Continuous Integration

GitHub Actions workflow `.github/workflows/ci.yml` executes on every push/PR to `main`:
- Backend job installs dependencies via `uv` and runs `uv run pytest`.
- Frontend job installs pnpm dependencies and runs `pnpm test`.

Fix failing jobs locally using the same commands before pushing changes.

## Documentation

- `PLANS.md` – living ExecPlan describing the full build.
- `AGENTS.md` – orientation + working agreements.
- `docs/architecture.md` – broader design/diagrams (to be completed).
- `infra/terraform/README.md` – Infrastructure-as-code usage + deployment notes.
- `scripts/bootstrap_tf_state.sh` – helper to create Terraform remote state RG/storage/container.

## Status

Phase 4 Terraform scaffolding is ready; next up is wiring pipelines + deployments per `PLANS.md`.
