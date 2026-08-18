from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")


def _integer(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except ValueError:
        return default


@dataclass(frozen=True)
class Settings:
    access_key: str = os.getenv("SEVENZ_BRIDGE_ACCESS_KEY", "").strip()
    host: str = os.getenv("SEVENZ_BRIDGE_HOST", "127.0.0.1").strip()
    port: int = _integer("SEVENZ_BRIDGE_PORT", 8787)
    allowed_origins: tuple[str, ...] = tuple(
        item.strip()
        for item in os.getenv("SEVENZ_BRIDGE_ALLOWED_ORIGINS", "").split(",")
        if item.strip()
    )
    terminal_path: str = os.getenv("SEVENZ_MT5_TERMINAL_PATH", "").strip()
    login: int | None = _integer("SEVENZ_MT5_LOGIN", 0) or None
    server: str = os.getenv("SEVENZ_MT5_SERVER", "").strip()
    telemetry_max_age_seconds: int = max(5, _integer("SEVENZ_TELEMETRY_MAX_AGE_SECONDS", 20))


settings = Settings()


def validate_settings() -> None:
    if len(settings.access_key) < 24:
        raise RuntimeError(
            "SEVENZ_BRIDGE_ACCESS_KEY must be configured with at least 24 characters. "
            "Run scripts/setup_windows.ps1 first."
        )

