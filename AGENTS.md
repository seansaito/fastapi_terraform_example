# Repo Mission

Build a demo-quality yet production-influenced full-stack stack composed of:
- A React + Vite + TypeScript frontend with ShadCN-inspired components for a minimalist to-do experience.
- A FastAPI backend that exposes CRUD routes, simple JWT-based authentication, structured logging, and a relational database layer.
- A Terraform deployment suite that provisions the Azure resources required to run the app end to end (resource group, networking, compute target, database, secret storage, and logging hooks).

# Tech Orientation
- **Frontend**: React 18, Vite, TypeScript, Tailwind/ShadCN for styling, tanstack query for data fetching, and zod for schema validation.
- **Backend**: FastAPI, Pydantic/SQLModel (or SQLAlchemy) backed by PostgreSQL, authentication powered by OAuth2 password flow with JWTs, uvicorn for local dev.
- **Observability**: Use structlog or Python logging with JSON formatting; propagate request IDs from frontend to backend where possible.
- **Infrastructure**: Terraform targeting Azure (use azurerm provider). Baseline resources include RG, Container App or App Service for API, Static Web App or Storage+CDN for frontend, managed PostgreSQL (Flexible Server), Key Vault/Secrets, Log Analytics workspace, and any supporting storage/backend state.

# Roles & Expectations
1. **Planner Agent** – owns PLANS.md, scopes work, keeps ExecPlans current. Always start multi-hour tasks with a plan that a novice can execute.
2. **Frontend Agent** – implements UI/UX, keeps components accessible, wires API calls, and mirrors backend contracts specified in the plan.
3. **Backend Agent** – defines FastAPI routers, database models, migrations, auth, and logging. Ensures endpoints match OpenAPI descriptions in the plan.
4. **Infra Agent** – authors Terraform modules, remote state strategy, CI deploy steps, and documents required Azure configuration.

Agents may be the same person across roles, but responsibilities stay explicit. Hand off work via PLANS.md updates and clear TODOs.

# ExecPlans Usage
- Trigger an ExecPlan for anything that spans roles, touches infrastructure, or exceeds ~30 minutes of effort.
- Keep PLANS.md self-contained: restate repo state, commands, acceptance criteria, and decision logs.
- While executing, update Concrete Steps and Validation as you go; do not wait until the end.
- Close each milestone with outcomes and open questions.

# Working Agreements
- Prefer `uv` / `pip` for Python deps, `npm` or `pnpm` for frontend, and `terraform` CLI (min v1.6).
- Every service change needs an accompanying test or manual verification notes.
- Document environment variables, secrets, and Azure prerequisites inside PLANS.md and README updates.
- Before pushing infra, run `terraform fmt`, `terraform validate`, and plan against the dev workspace.

# Definition of Done
- Frontend: `npm run build` passes and main use-cases manually verified.
- Backend: `uv run pytest` (or equivalent) passes, FastAPI OpenAPI reflects new routes, logging/auth documented.
- Infra: `terraform plan` clean, linting/formatting applied, and deployment instructions verified.

# Decision Log Convention
When you make a non-trivial decision, record it in PLANS.md as:
```
- Decision: <summary>
  Rationale: <why>
  Date/Author: <YYYY-MM-DD>/<name>
```

Use this AGENTS.md as a quick orientation before diving into PLANS.md for detailed execution steps.
