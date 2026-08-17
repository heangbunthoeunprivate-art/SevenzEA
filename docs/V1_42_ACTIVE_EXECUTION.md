# SevenzEA v1.42 — Active Execution

## Objective

v1.42 addresses two blockers observed during Demo testing: the M5/M15 profile produced too few candidate bars, and a valid signal could be rejected silently when risk-based volume fell below the broker's 0.01 minimum.

## Active signal profile

- Entry: M1 closed candle.
- Confirmation: M5.
- Direction anchor: M15 EMA-200.
- Base IQ gate: 65/100.
- Minimum votes: 4.
- Directional edge: 8.
- Transition and higher-timeframe conflict vetoes remain enabled.

Intraday remains M15/H1 with an H4 anchor. `InpUseM1ActiveScalp=false` restores the prior M5/M15 scalping profile.

## Broker-aware execution

Before sending an order, the EA asks MT5 to estimate the stop-loss result for one lot using `OrderCalcProfit`, then sizes volume from the configured money-risk budget. The final normalized lot is checked again to show its estimated stop risk.

When volume is below the broker minimum:

- Safe/real behavior: block with `LOT<MIN` unless the user explicitly enables the existing override.
- Active Demo preset: `InpDemoMinLotMode=true` permits the broker minimum only on Demo/Contest accounts and displays `DEMO MIN ... risk $...`.

Demo Minimum-Lot Mode can exceed the requested percentage risk because the broker cannot execute a smaller lot. It does not operate on a real account.

## Panel execution line

The `Exec` line reports the most recent volume decision, estimated risk, margin/preflight rejection or server result. This closes the v1.41 diagnostic gap where an invalid calculated volume was printed only to the Experts log.

## Limits retained

Maximum one open position, six completed trades per day, adaptive loss protection, $50 target stop, news blackout, volatility/spread guard, cooldown, Friday protection and real-account authorization remain active. No trade count or profit is guaranteed.
