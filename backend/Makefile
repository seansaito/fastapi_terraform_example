.PHONY: dev test lint migrations upgrade

VENV ?= .venv
APP ?= app.main:app

install:
	uv sync

dev:
	uv run uvicorn $(APP) --reload --port 8000

test:
	uv run pytest

migrate:
	uv run alembic revision --autogenerate -m "$(m)"

upgrade:
	uv run alembic upgrade head
