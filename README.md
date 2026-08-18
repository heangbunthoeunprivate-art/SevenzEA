# SevenzEA v1.44 — Bridge Ready

SevenzEA is a standalone MQL5 Expert Advisor for MetaTrader 5 focused on XAUUSD. v1.44 keeps the v1.43 trading and safety architecture and adds optional, read-only telemetry for SE7EN GOLD IQ through the new SevenzEA Bridge.

## Trading design

- Market: XAUUSD/Gold only by default. Broker suffixes such as `XAUUSD.a` are supported through `InpSymbols`.
- Profiles: Reference Hybrid Active (`M1` signal + `M5` confirmation + `M15` anchor, evaluated once per M5 bar) and Intraday (`M15` entry + `H1` confirmation + `H4` anchor).
- Explainable IQ engine: every setup receives separate Long and Short scores from nine confluence checks.
- Regime detection: ADX classifies Trend, Range or Transition; the uncertain Transition zone is blocked by default.
- Trend entries: entry/confirmation EMA alignment, H1/H4 anchor bias, ADX/DI, RSI, MACD, candle body, structure and anti-chase distance.
- Range entries: Bollinger rejection, RSI extreme, wick/body rejection, low ADX, MACD turn, structure and higher-timeframe conflict checks.
- Hard vetoes: higher-timeframe conflict, weak directional edge, insufficient votes and insufficient IQ score.
- Broker-aware sizing: `OrderCalcProfit` calculates the exact estimated stop-loss amount using the broker's symbol contract before every order.
- Demo Minimum-Lot Mode can lift a sub-minimum calculated volume to the broker's minimum on non-real accounts only, with the actual estimated risk shown on the panel.
- Exits: ATR-based stop loss/take profit, break-even and ATR trailing stop.
- Asia context uses 00:00–06:00 UTC with half risk. v1.43 removes the extra Asia IQ penalty from the active preset while retaining the news and spread guards.
- High-impact calendar protection covers USD plus CNY/JPY/AUD when Asia protection is enabled.
- On-chart control panel shows live bias, quality, ADX, RSI, ATR, spread, session, daily P&L, positions, balance/equity, daily target, win rate, profit factor, average P&L and safety status.
- Panel controls: Pause/Resume, Scalping toggle, Auto-Trade arm, Quality filter, double-confirm Close All and protected Reset Day.
- Optional Bridge telemetry sends IQ, regime, session, news, execution and performance status to a local authenticated service. It is disabled by default and exposes no remote trade commands.

## Safety locks

The default preset cannot place orders. Two separate inputs protect a real account:

1. `InpEnableOrderExecution=true` enables order placement.
2. `InpAllowRealAccount=true` additionally authorizes a real account.

The on-chart `AUTO-TRADE` button is a third runtime lock. It cannot bypass either input lock.

Other controls include daily-loss and equity-drawdown limits, spread filter, cooldown, maximum trades per day, consecutive-loss lock, trading-session filter, Friday protection, emergency stop, and one-position-per-symbol.

### v1.20 XAUUSD and daily-target upgrade

- XAUUSD-only safety mode enabled by default.
- Fixed daily profit target: $50. `InpRequireUsdAccount=true` blocks Auto-Trade on non-USD accounts so the target remains unambiguous.
- New entries lock after the target is reached.
- Open SevenzEA positions close when the target is reached if `InpCloseAtDailyTarget=true`.
- Target progress uses the change in account equity from the protected daily baseline.

### v1.10 reliability foundation

- Safety day baseline and peak equity persist across MT5/EA restarts.
- Independent cooldown per symbol for true multi-symbol operation.
- Separate spread limits for metals and Forex.
- Maximum total SevenzEA positions.
- Free-margin reserve validation before every order.
- Optional daily-profit target lock.
- Broker trade-direction and symbol availability validation.

> No EA can guarantee profit. Compile and test this EA in MT5 Strategy Tester and on a demo account before enabling real-account execution.

The daily target is a stop condition, not a promise that the EA will earn $50 every day.

### v1.30 Safety Pro

This release adds all eight production-safety upgrades: high-impact USD news blackout and countdown, $2 target execution buffer with realized-P&L tracking, adaptive loss risk, OrderCheck preflight, ATR/spread volatility protection, transaction-driven broker status, UTC London/New York session filtering, and expanded panel telemetry. See [docs/V1_30_UPGRADE.md](docs/V1_30_UPGRADE.md).

### v1.40 IQ + Confluence Pro

This release adds explainable nine-factor scoring, separate Long/Short scores, a minimum directional edge, higher-timeframe vetoes, Trend/Range/Transition classification, MACD and candle-quality confirmation, anti-chase protection, conservative Asia-session risk, and multi-currency news protection. See [docs/V1_40_IQ_CONFLUENCE.md](docs/V1_40_IQ_CONFLUENCE.md).

### v1.41 Balanced IQ

This release retunes the entry gate from 78/6/15 to a more practical 70-point score, five confluence votes and a 10-point directional edge. Transition, higher-timeframe, news, spread, volatility, loss and account safety vetoes remain active. The panel now reports Scalping and Intraday decisions independently. See [docs/V1_41_BALANCED_IQ.md](docs/V1_41_BALANCED_IQ.md).

### v1.42 Active Execution

This release adds M1/M5 active scalping, active 65/4/8 IQ defaults, broker-aware money-risk sizing, explicit `LOT<MIN`/risk diagnostics and a non-real-account Demo Minimum-Lot Mode. It retains the one-position, six-trade, target, news, session, volatility and drawdown locks. See [docs/V1_42_ACTIVE_EXECUTION.md](docs/V1_42_ACTIVE_EXECUTION.md).

### v1.43 Reference Hybrid Active

This release fixes the M1 spread/ATR blocker by evaluating the active profile once per M5 bar and using M5 ATR for execution-cost protection. It adds two-of-three M15/M5/M1 alignment, a 14 ADX floor, 30–70 RSI window, 1.5 ATR pullback allowance, a 60-point IQ floor and a 1.7× rolling-median spread-surge veto. It does not copy the reference bot's unsafe always-live behavior, 500-trade cap, rapid stacking or forced minimum-lot sizing. See [docs/V1_43_REFERENCE_HYBRID_ACTIVE.md](docs/V1_43_REFERENCE_HYBRID_ACTIVE.md).

### v1.44 Bridge Ready

This release adds a disabled-by-default Bearer-authenticated telemetry client and a separate Python Bridge. The Bridge merges EA IQ telemetry with the locally logged-in MT5 terminal's XAUUSD quote, account, position and daily-deal data. The public surface is read-only: it has no order, close, account-switch or settings routes. See [docs/BRIDGE_SETUP_KH.md](docs/BRIDGE_SETUP_KH.md).

## Install

1. Copy `Experts/SevenzEA.mq5` to `MT5 Data Folder/MQL5/Experts/SevenzEA.mq5`.
2. Open MetaEditor, compile the file, and confirm zero errors.
3. Restart or refresh MT5 Navigator.
4. Attach the EA to one chart. The chart symbol does not limit scanning.
5. Enter the broker's exact symbol names in `InpSymbols` (including suffixes such as `XAUUSD.a`).
6. Load `Presets/SevenzEA_Safe_Start.set` for signal-only setup, or `Presets/SevenzEA_v1.43_Reference_Hybrid_Demo.set` for Demo execution. The Demo preset cannot authorize a real account.
7. Enable Algo Trading only after Strategy Tester and demo validation.

Khmer setup instructions are in [docs/SETUP_KH.md](docs/SETUP_KH.md). Strategy and safety details are in [docs/STRATEGY.md](docs/STRATEGY.md) and [docs/SAFETY.md](docs/SAFETY.md).

## Repository layout

```text
Experts/SevenzEA.mq5             Main EA source
bridge/                          Read-only MT5/website telemetry service
Presets/SevenzEA_Safe_Start.set Safe starting inputs
docs/STRATEGY.md                 Signal and regime rules
docs/SAFETY.md                   Safety-lock behavior
docs/SETUP_KH.md                 Khmer installation guide
docs/BRIDGE_SETUP_KH.md          Khmer Bridge installation guide
```
