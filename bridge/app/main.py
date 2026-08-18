from __future__ import annotations

import hmac
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import Any

from fastapi import Depends, FastAPI, Header, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import settings, validate_settings
from .mt5_reader import mt5_reader
from .state import telemetry_store


@asynccontextmanager
async def lifespan(_: FastAPI):
    validate_settings()
    yield


app = FastAPI(
    title="SevenzEA Bridge",
    version="1.0.0",
    docs_url=None,
    redoc_url=None,
    openapi_url=None,
    lifespan=lifespan,
)

if settings.allowed_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=list(settings.allowed_origins),
        allow_credentials=False,
        allow_methods=["GET", "POST"],
        allow_headers=["Authorization", "Content-Type"],
    )


def authorize(authorization: str | None = Header(default=None)) -> None:
    expected = f"Bearer {settings.access_key}"
    if not authorization or not hmac.compare_digest(authorization, expected):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid bearer token")


def _merge(base: dict[str, Any], overlay: dict[str, Any]) -> dict[str, Any]:
    result = dict(base)
    for key, value in overlay.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = _merge(result[key], value)
        else:
            result[key] = value
    return result


@app.exception_handler(Exception)
async def unhandled_error(_: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(
        status_code=500,
        content={"ok": False, "detail": "Bridge internal error", "type": type(exc).__name__},
    )


@app.get("/v1/health", dependencies=[Depends(authorize)])
def health() -> dict[str, Any]:
    telemetry, received_at = telemetry_store.snapshot()
    age = (datetime.now(timezone.utc) - received_at).total_seconds() if received_at else None
    return {
        "ok": True,
        "service": "SevenzEA Bridge",
        "version": "1.0.0",
        "eaTelemetry": {
            "received": telemetry is not None,
            "fresh": age is not None and age <= settings.telemetry_max_age_seconds,
            "ageSeconds": round(age, 2) if age is not None else None,
        },
    }


@app.post("/v1/ea/telemetry", dependencies=[Depends(authorize)])
async def receive_telemetry(request: Request) -> dict[str, Any]:
    payload = await request.json()
    if not isinstance(payload, dict) or not payload.get("ea"):
        raise HTTPException(status_code=422, detail="Telemetry payload must include ea")
    received_at = telemetry_store.update(payload)
    return {"ok": True, "receivedAt": received_at.isoformat()}


@app.get("/v1/snapshot", dependencies=[Depends(authorize)])
def snapshot() -> dict[str, Any]:
    telemetry, received_at = telemetry_store.snapshot()
    preferred_symbol = None
    if telemetry:
        preferred_symbol = str(telemetry.get("symbol") or "") or None
    mt5_snapshot = mt5_reader.read(preferred_symbol)

    merged = _merge(mt5_snapshot, telemetry or {})
    age = (datetime.now(timezone.utc) - received_at).total_seconds() if received_at else None
    merged["bridge"] = {
        "online": True,
        "version": "1.0.0",
        "eaTelemetryFresh": age is not None and age <= settings.telemetry_max_age_seconds,
        "eaTelemetryAgeSeconds": round(age, 2) if age is not None else None,
        "receivedAt": received_at.isoformat() if received_at else None,
    }
    return merged
