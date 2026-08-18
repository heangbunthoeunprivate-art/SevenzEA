from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

from .config import settings

try:
    import MetaTrader5 as mt5  # type: ignore
except ImportError:  # Allows Linux CI and documentation builds.
    mt5 = None


def _iso(timestamp: int | float | None) -> str | None:
    if not timestamp:
        return None
    return datetime.fromtimestamp(timestamp, tz=timezone.utc).isoformat()


class MT5Reader:
    def __init__(self) -> None:
        self._initialized = False
        self._last_error = "MT5 module not loaded"

    def connect(self) -> bool:
        if mt5 is None:
            self._last_error = "MetaTrader5 Python package is unavailable"
            return False
        if self._initialized and mt5.terminal_info() is not None:
            return True

        kwargs: dict[str, Any] = {}
        if settings.terminal_path:
            kwargs["path"] = settings.terminal_path
        if settings.login:
            kwargs["login"] = settings.login
        if settings.server:
            kwargs["server"] = settings.server

        self._initialized = bool(mt5.initialize(**kwargs))
        if not self._initialized:
            self._last_error = f"MT5 initialize failed: {mt5.last_error()}"
        return self._initialized

    def _symbol(self, preferred: str | None) -> str | None:
        if mt5 is None:
            return None
        candidates = [preferred, "XAUUSD", "GOLD"]
        for candidate in candidates:
            if not candidate:
                continue
            info = mt5.symbol_info(candidate)
            if info is not None:
                if not info.visible:
                    mt5.symbol_select(candidate, True)
                return candidate
        for item in mt5.symbols_get(group="*XAU*") or ():
            if mt5.symbol_select(item.name, True):
                return item.name
        return None

    def read(self, preferred_symbol: str | None = None) -> dict[str, Any]:
        if not self.connect() or mt5 is None:
            return {"connected": False, "error": self._last_error}

        account = mt5.account_info()
        terminal = mt5.terminal_info()
        symbol = self._symbol(preferred_symbol)
        info = mt5.symbol_info(symbol) if symbol else None
        tick = mt5.symbol_info_tick(symbol) if symbol else None

        positions = mt5.positions_get(symbol=symbol) if symbol else mt5.positions_get()
        open_pnl = sum(float(item.profit) for item in positions or ())

        now = datetime.now(timezone.utc)
        day_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        deals = mt5.history_deals_get(day_start, now) or ()
        exits = [item for item in deals if int(item.entry) in (1, 3)]
        closed_pnl = sum(float(item.profit + item.swap + item.commission) for item in exits)
        wins = sum(1 for item in exits if float(item.profit + item.swap + item.commission) > 0)
        gross_profit = sum(max(0.0, float(item.profit + item.swap + item.commission)) for item in exits)
        gross_loss = abs(sum(min(0.0, float(item.profit + item.swap + item.commission)) for item in exits))

        recent = []
        for item in reversed(exits[-6:]):
            pnl = float(item.profit + item.swap + item.commission)
            recent.append(
                {
                    "time": _iso(item.time),
                    "signal": "BUY" if int(item.type) == 0 else "SELL",
                    "profit": round(pnl, 2),
                    "ticket": int(item.ticket),
                }
            )

        spread = None
        if info is not None and tick is not None and float(info.point) > 0:
            spread = round((float(tick.ask) - float(tick.bid)) / float(info.point))

        return {
            "connected": True,
            "terminal": {
                "connected": bool(terminal.connected) if terminal else False,
                "tradeAllowed": bool(terminal.trade_allowed) if terminal else False,
                "company": str(terminal.company) if terminal else "",
            },
            "account": {
                "login": int(account.login) if account else None,
                "server": str(account.server) if account else "",
                "currency": str(account.currency) if account else "",
                "balance": float(account.balance) if account else None,
                "equity": float(account.equity) if account else None,
                "marginFree": float(account.margin_free) if account else None,
                "openPnl": round(open_pnl, 2),
            },
            "market": {
                "xauusd": {
                    "symbol": symbol,
                    "price": float(tick.bid) if tick else None,
                    "ask": float(tick.ask) if tick else None,
                    "spread": spread,
                    "time": _iso(tick.time) if tick else None,
                }
            },
            "performance": {
                "dayPnl": round(closed_pnl, 2),
                "trades": len(exits),
                "winRate": round(100.0 * wins / len(exits), 2) if exits else 0.0,
                "profitFactor": round(gross_profit / gross_loss, 2) if gross_loss else (99.0 if gross_profit else 0.0),
                "openPnl": round(open_pnl, 2),
            },
            "recentSignals": recent,
            "readAt": now.isoformat(),
            "historyWindowHours": int((now - day_start) / timedelta(hours=1)),
        }


mt5_reader = MT5Reader()

