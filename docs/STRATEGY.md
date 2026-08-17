# SevenzEA Strategy Specification

## Profiles

| Profile | Entry timeframe | Confirmation timeframe | Default stop | Default target |
| --- | --- | --- | --- | --- |
| Active Scalping | M1 | M5 (M15 anchor) | 1.40 ATR | 1.80 ATR |
| Intraday | M15 | H1 | 1.80 ATR | 2.60 ATR |

Signals are evaluated once per newly opened entry-timeframe bar and use the last fully closed candle.

## Automatic regime selection

- `ADX >= InpTrendAdxThreshold`: trend regime.
- `ADX <= InpRangeAdxCeiling`: range regime.
- Values between the two thresholds: transition regime, blocked by default.

## IQ + Confluence decision

The engine calculates independent Long and Short scores from nine weighted checks. Trend scoring uses entry EMA alignment, confirmation-timeframe alignment, H1/H4 anchor direction, ADX/DI strength, RSI, MACD, candle body, two-candle structure and distance from the fast EMA. Range scoring uses Bollinger rejection, RSI extreme, wick/body rejection, range ADX, MACD turn, two-candle structure, confirmation/anchor non-conflict and price location inside the bands.

An entry must satisfy all of these gates:

1. A mandatory Trend or Range trigger exists on the last closed candle.
2. The higher-timeframe veto does not conflict with the direction.
3. The selected direction leads the opposite score by at least `InpMinDirectionalEdge`.
4. At least `InpMinConfluenceVotes` checks pass.
5. The IQ score reaches `InpQualityThreshold`; Asia adds `InpAsiaQualityBonus`.

Active defaults are 65/100, four votes and an eight-point directional edge. Asia adds five points, making its default threshold 70. The M1 entry profile increases evaluation opportunities while retaining the transition and higher-timeframe vetoes. It does not guarantee a trade count or profit every day.

## Session context

- Asia: 00:00–06:00 UTC, 50% normal risk and an extra five IQ points.
- London: 07:00–16:00 UTC.
- New York: 12:00–21:00 UTC.

The safety preset enables all three windows. USD, CNY, JPY and AUD high-impact calendar events are guarded with the configured blackout period.

The default configuration allows only one SevenzEA position per symbol, so a Scalping and Intraday trade cannot overlap on the same market.

## Important optimization rule

This edition is tuned structurally for XAUUSD-only operation. Broker symbol specifications, spread, tick value and server time still differ, so validate the exact broker symbol and conditions with out-of-sample and forward testing.
