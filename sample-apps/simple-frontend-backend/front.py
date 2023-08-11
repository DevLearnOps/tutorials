import os

import requests
from requests.exceptions import ConnectionError
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route

BACKEND_URL = os.getenv("BACK_URL")
if not BACKEND_URL:
    raise ValueError(
        "Unable to start application: missing environment variable BACK_URL"
    )


async def health(request):
    return JSONResponse({"status": "healthy"})


async def homepage(request):
    try:
        response = requests.get(f"{BACKEND_URL}/greet", timeout=5)
    except ConnectionError:
        response = None

    if response and response.status_code == 200:
        return JSONResponse(
            {
                "message": response.json().get("msg"),
                "status": "ok",
            }
        )

    return JSONResponse(
        {
            "message": "Hello there!",
            "status": "Could not reach backend service",
        }
    )


app = Starlette(
    debug=bool(os.getenv("DEBUG", False)),
    routes=[
        Route("/health", health),
        Route("/", homepage),
    ],
)
