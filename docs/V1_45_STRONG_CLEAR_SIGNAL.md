# SevenzEA v1.45 — Strong Clear Signal

v1.45 makes the signal state easier to understand without weakening order safety.

## Signal ladder

- `WAIT`: market data is incomplete, direction is conflicted, or confluence is still below the watch floor.
- `EARLY`: a directional bias exists and IQ is building, but at least one entry gate is still missing.
- `READY`: direction, IQ threshold and required confluence votes pass on closed-bar data.
- `STRONG`: READY plus stronger IQ, one extra vote and a wider Long/Short directional edge.
- `LOCKED`: the technical setup passes, but the high-impact News Guard blocks entry.

Default display thresholds are:

- Watch floor: 45 IQ
- Execution floor: 60 IQ and 4 votes
- Strong floor: at least 75 IQ, 5 votes and a 15-point directional edge

The execution floor remains controlled by `InpQualityThreshold`, `InpMinConfluenceVotes` and `InpMinDirectionalEdge`. The new level labels do not bypass these inputs.

## Clearer multi-timeframe analysis

The Bridge now evaluates and reports each row independently:

- M1 trigger with M5 confirmation
- M5 structure with M15 confirmation
- M15 entry with H1 confirmation
- H1 trend with H4 anchor

Primary signal selection prioritizes a setup that has an executable direction and passed gates before comparing raw IQ scores. This prevents a high-scoring WAIT setup from hiding a qualified setup.

## Trade plan telemetry

Entry, Stop Loss, Take Profit and Risk/Reward are released only when the signal is qualified and News Guard is clear. Prices use the broker's current Bid/Ask, symbol digits, stop-level rules and the same ATR multipliers used by SevenzEA execution.

## Safety behavior

v1.45 does not reduce or bypass:

- closed-bar evaluation
- higher-timeframe conflict veto
- IQ and vote requirements
- spread and volatility guards
- News Guard
- daily-loss, drawdown and consecutive-loss locks
- one-position and cooldown controls
- real-account authorization locks

`STRONG` describes the amount of confluence, not a guarantee of profit. Validate the EA in Strategy Tester and on Demo before enabling real-account execution.
