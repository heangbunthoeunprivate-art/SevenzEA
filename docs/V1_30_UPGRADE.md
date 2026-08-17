# SevenzEA v1.30 — XAUUSD Safety Pro

## Included upgrades

1. **USD high-impact news guard** — reads the MT5 Economic Calendar and blocks entries 30 minutes before and after high-impact USD events. Calendar time is broker trade-server time. A real account fails closed when the calendar is unavailable; Strategy Tester fails open and reports that calendar data is unavailable.
2. **Realized $50 target** — an open position is closed when daily equity reaches the $50 target plus a $2 execution buffer. The EA records realized P&L and locks the day after target handling.
3. **Adaptive loss guard** — risk falls to 75% after one consecutive loss and 50% after two. The existing third-loss lock remains active. No martingale or lot increase is used.
4. **Order preflight** — every market order is checked with `OrderCheck` after margin, direction, stop and volume validation.
5. **XAU volatility guard** — blocks entries when the current ATR is more than 2.2 times its 50-bar average or when spread exceeds 12% of ATR.
6. **Live transaction tracking** — `OnTradeTransaction` records broker request results, fills and closes directly on the panel.
7. **Liquid-session filter** — trades only during London 07:00–16:00 UTC or New York 12:00–21:00 UTC by default.
8. **Panel news countdown** — shows the next high-impact USD event, blackout state, ATR spike ratio, risk factor, realized/equity target progress and the latest trade-server event.

## Important limitations

- The MT5 Economic Calendar may be unavailable in Strategy Tester or from some broker environments. Always inspect the panel before enabling a real account.
- A $2 target buffer reduces but cannot eliminate execution slippage. A $50 realized result is not guaranteed.
- London/New York hours are UTC inputs. Adjust them only if your written test plan requires a different window.

