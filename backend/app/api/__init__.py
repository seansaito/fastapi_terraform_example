from fastapi import APIRouter

from .routes import auth, health, todos

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(todos.router)

__all__ = ["api_router"]
