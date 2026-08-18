# Safety Model

SevenzEA starts in signal-only mode. Order execution requires explicit activation, and real-account trading requires a second explicit authorization.

The panel adds a third runtime lock: `AUTO-TRADE` starts OFF every time the EA loads. The Close All button requires a second click within five seconds. Reset Day cannot erase history-based loss or trade counters.

## Entry locks

- Emergency stop or pause-new-entries input.
- Execution disabled.
- Real account not authorized.
- MT5 Algo Trading disabled.
- Daily equity loss limit reached.
- Peak-equity drawdown limit reached.
- Daily trade count reached.
- Consecutive loss count reached.
- Existing SevenzEA position on the symbol.
- Cooldown, spread, day, session, or Friday protection fails.
- Calculated risk-based volume is below the broker minimum lot (unless the explicit override is enabled).
- Total SevenzEA open-position limit reached.
- Required order margin would reduce free margin below the configured reserve.
- Daily profit target reached when the target lock is enabled.
- Broker symbol mode does not allow the requested trade direction.

The daily equity baseline and peak-equity watermark are stored in MT5 terminal global variables using the account login and EA magic base. Restarting MT5 or reattaching the EA therefore does not reset those safety measurements.

## $50 daily target

`InpDailyProfitTargetMoney=50.00` is measured in the account deposit currency. `InpRequireUsdAccount=true` blocks Auto-Trade unless the account currency is USD, making the target exactly $50. v1.30 sends the position-close request when equity reaches the $50 target plus the configured execution buffer. SevenzEA then disarms Auto-Trade and blocks new orders for the rest of that broker-server day. This target is not a guaranteed realized return.

v1.43 retains the configurable $2 equity buffer before sending the target close request, then reports realized P&L separately. It lowers risk after consecutive losses, applies a 50% risk factor in the Asia window, and blocks guarded high-impact USD/CNY/JPY/AUD news, abnormal ATR conditions, fixed spread excess and spread surges. The active profile measures execution cost against M5 ATR rather than M1 ATR.

`InpDemoMinLotMode` applies only to Demo/Contest accounts. When calculated risk volume is below the broker minimum, it may use the minimum lot and reports the larger actual estimated stop risk. It never authorizes a real account and should not be copied into a real-account preset without a separate risk review.

The IQ score never bypasses a safety lock. A 100/100 setup is still rejected when execution is disarmed, the daily target/loss limit is reached, a news blackout is active, the spread/ATR guard fails, margin is insufficient, a position already exists, or any manual/real-account lock is active.

Safety locks block new entries; they do not forcibly close an existing position. Existing positions continue to receive break-even and trailing-stop management.

## Recommended release gate

1. Compile with zero MetaEditor errors and warnings.
2. Backtest each symbol with realistic spread and commission.
3. Run out-of-sample and forward demo tests.
4. Confirm symbol suffixes, tick value, minimum lot, stop level, server timezone and filling mode with the target broker.
5. Keep `InpAllowRealAccount=false` until the forward-demo results meet a written acceptance rule.
