import uuid
from typing import Callable

import structlog
from fastapi import Request, Response

from . import logging as logging_utils


class RequestIDMiddleware:
    """Ensures every request has a request ID and binds it to the log context."""

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):  # type: ignore[override]
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request = Request(scope, receive=receive)
        request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
        logging_utils.bind_request_context(request_id=request_id)

        async def send_wrapper(message):
            if message.get("type") == "http.response.start":
                headers = message.setdefault("headers", [])
                headers.append((b"x-request-id", request_id.encode()))
            await send(message)

        try:
            await self.app(scope, receive, send_wrapper)
        finally:
            logging_utils.clear_request_context()


async def log_requests(request: Request, call_next: Callable[[Request], Response]) -> Response:
    logger = structlog.get_logger().bind(path=request.url.path, method=request.method)
    response = await call_next(request)
    logger.info("request.complete", status_code=response.status_code)
    return response
