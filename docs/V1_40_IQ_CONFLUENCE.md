# SevenzEA v1.40 — IQ + Confluence Pro

## What “IQ” means

This EA uses transparent, deterministic rules. It does not claim to predict the market with artificial intelligence. Every decision can be inspected through its Long score, Short score, vote count, regime and veto reason.

## Decision layers

1. **Regime IQ** — classifies Trend, Range or uncertain Transition from confirmation-timeframe ADX.
2. **Multi-timeframe direction** — entry EMA alignment, confirmation alignment and an H1/H4 EMA-200 anchor.
3. **Momentum** — DI dominance, RSI position and MACD direction/turn.
4. **Price action** — minimum candle body, wick rejection and two-candle market structure.
5. **Location** — Bollinger position for ranges and maximum ATR distance from the fast EMA for trends.
6. **Conflict veto** — blocks a setup when the higher timeframe opposes it or Long and Short scores are too close.
7. **Quality gate** — requires 78/100 and six confluence votes by default.
8. **Session intelligence** — Asia requires 83/100 and uses half normal risk; London/New York use the base threshold and risk.

## Panel fields

- `IQ Bias`: qualified direction or watch direction.
- `Score`: chosen setup score out of 100.
- `Votes`: passed confluence checks versus the configured minimum.
- `Regime`: Trend, Range or Transition.
- `L / S`: independent Long and Short scores.
- `IQ Gate`: the active veto or `Passed`.

## Safety behavior retained

The $50 daily stop target, one-position maximum, adaptive loss reduction, news blackout, OrderCheck preflight, ATR/spread protection, cooldown, drawdown locks, target buffer and manual Auto-Trade lock remain active.

## Validation requirement

Compile in MetaEditor and confirm zero errors. Then backtest using the broker's real-tick model and exact XAUUSD symbol, followed by demo forward testing. A high confluence score is a rule match, not a profit guarantee.
