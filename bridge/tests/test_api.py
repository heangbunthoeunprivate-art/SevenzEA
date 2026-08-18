from __future__ import annotations

import os

os.environ["SEVENZ_BRIDGE_ACCESS_KEY"] = "test-key-that-is-longer-than-24-characters"

from fastapi.testclient import TestClient

from app.main import app


KEY = os.environ["SEVENZ_BRIDGE_ACCESS_KEY"]
AUTH = {"Authorization": f"Bearer {KEY}"}


def test_auth_is_required() -> None:
    with TestClient(app) as client:
        response = client.get("/v1/health")
    assert response.status_code == 401


def test_telemetry_round_trip() -> None:
    telemetry = {
        "ea": {"name": "SevenzEA", "version": "1.45"},
        "symbol": "XAUUSD",
        "signal": {
            "bias": "SELL",
            "level": "STRONG",
            "profile": "SCALP",
            "score": 72,
            "progress": 100,
            "votes": 5,
            "requiredVotes": 4,
            "threshold": 60,
            "qualified": True,
            "regime": "TREND",
            "directionalEdge": 24,
            "nextGate": "All signal gates passed",
        },
        "plan": {"ready": True, "entry": 4337.2, "stopLoss": 4333.2, "takeProfit": 4342.4, "riskReward": 1.3},
        "market": {"session": "LONDON+NY", "atrM5": 263.6},
        "execution": {"autoTrade": "ON", "status": "AUTO-TRADE armed"},
    }

    with TestClient(app) as client:
        accepted = client.post("/v1/ea/telemetry", headers=AUTH, json=telemetry)
        snapshot = client.get("/v1/snapshot", headers=AUTH)

    assert accepted.status_code == 200
    assert snapshot.status_code == 200
    payload = snapshot.json()
    assert payload["signal"]["bias"] == "SELL"
    assert payload["signal"]["level"] == "STRONG"
    assert payload["signal"]["nextGate"] == "All signal gates passed"
    assert payload["signal"]["qualified"] is True
    assert payload["plan"]["riskReward"] == 1.3
    assert payload["bridge"]["eaTelemetryFresh"] is True
    assert KEY not in snapshot.text


def test_bad_telemetry_is_rejected() -> None:
    with TestClient(app) as client:
        response = client.post("/v1/ea/telemetry", headers=AUTH, json={"signal": {}})
    assert response.status_code == 422
