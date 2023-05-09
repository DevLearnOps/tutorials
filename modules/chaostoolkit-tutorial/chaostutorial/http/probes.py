"""Probes for chaostutorial module"""
from chaoslib.types import Configuration
from chaoslib.exceptions import ActivityFailed
from logzero import logger
from typing import Any, List
import requests


__all__ = [
    "request_duration",
    "response_mime_type",
]


def request_duration(
    url: str, method: str = "GET", timeout: int = 5, configuration: Configuration = None
) -> float:
    if method == "GET":
        response = requests.get(url, timeout=timeout)
        return response.elapsed.total_seconds() * 1000

    raise ActivityFailed(f"Request method unsupported: {method}")


def response_mime_type(
    url: str, method: str = "GET", timeout: int = 5, configuration: Configuration = None
) -> float:
    if method == "GET":
        response = requests.get(url, timeout=timeout)
        return response.headers.get("Content-Type")

    raise ActivityFailed(f"Request method unsupported: {method}")
