import os

import structlog
import asyncio
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route
from starlette.background import BackgroundTask

logger = structlog.get_logger("sampleapp-backend")


async def health(request):
    return JSONResponse({"status": "healthy"})


async def greet(request):
    msg = "Hello from backend service!"
    return JSONResponse({"msg": msg})


async def fail_server(request):
    """Fail webserver on demand"""
    logger.warning("Request received to fail webservice. Shutting down...")

    # not so graceful termination
    async def exit_app():
        asyncio.get_running_loop().stop()

    task = BackgroundTask(exit_app)
    return JSONResponse({"status": "ok"}, background=task)


app = Starlette(
    debug=bool(os.getenv("DEBUG", False)),
    routes=[
        Route("/health", health),
        Route("/greet", greet),
        Route("/_chaos/fail", fail_server, methods=["POST"]),
    ],
)
