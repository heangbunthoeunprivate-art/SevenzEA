from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone
from threading import Lock
from typing import Any


class TelemetryStore:
    def __init__(self) -> None:
        self._lock = Lock()
        self._payload: dict[str, Any] | None = None
        self._received_at: datetime | None = None

    def update(self, payload: dict[str, Any]) -> datetime:
        received_at = datetime.now(timezone.utc)
        with self._lock:
            self._payload = deepcopy(payload)
            self._received_at = received_at
        return received_at

    def snapshot(self) -> tuple[dict[str, Any] | None, datetime | None]:
        with self._lock:
            return deepcopy(self._payload), self._received_at


telemetry_store = TelemetryStore()

