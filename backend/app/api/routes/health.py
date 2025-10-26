from fastapi import APIRouter

router = APIRouter(prefix="/healthz", tags=["health"])


@router.get("", summary="Liveness/Readiness probe")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}
