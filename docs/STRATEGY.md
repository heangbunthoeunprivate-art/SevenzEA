# SevenzEA Strategy Specification

## Profiles

| Profile | Entry timeframe | Confirmation timeframe | Default stop | Default target |
| --- | --- | --- | --- | --- |
| Reference Hybrid Active | M1 signal, M5 evaluation | M5 confirmation (M15 anchor) | 1.40 ATR | 1.80 ATR |
| Intraday | M15 | H1 | 1.80 ATR | 2.60 ATR |

Reference Hybrid Active is evaluated once per newly opened M5 bar and uses closed M1/M5/M15 data. Intraday signals are evaluated once per M15 bar.

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

Reference Hybrid Active requires at least two of the M15/M5/M1 directions to agree, ADX 14 or higher, RSI inside 30–70 and price within 1.5 ATR of the M1 fast EMA. Candle confirmation is optional in this profile. Its defaults are 60/100, four votes and an eight-point directional edge. Asia uses the same IQ threshold but half risk. It does not guarantee a trade count or profit every day.

The active cost guard uses M5 ATR instead of M1 ATR. A fixed 35-point XAUUSD spread limit remains active, and the order is also blocked when the current spread exceeds 1.7 times its rolling median after warm-up.

## Session context

- Asia: 00:00–06:00 UTC and 50% normal risk.
- London: 07:00–16:00 UTC.
- New York: 12:00–21:00 UTC.

The safety preset enables all three windows. USD, CNY, JPY and AUD high-impact calendar events are guarded with the configured blackout period.

The default configuration allows only one SevenzEA position per symbol, so a Scalping and Intraday trade cannot overlap on the same market.

## Important optimization rule

This edition is tuned structurally for XAUUSD-only operation. Broker symbol specifications, spread, tick value and server time still differ, so validate the exact broker symbol and conditions with out-of-sample and forward testing.
