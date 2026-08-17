# Changelog

## 1.42 — Active Execution

- Added M1 entry/M5 confirmation/M15 anchor active scalping.
- Retuned active IQ defaults to 65 score, four votes and an eight-point directional edge.
- Replaced generic tick-value sizing with broker-aware `OrderCalcProfit` risk calculation.
- Added non-real-account Demo Minimum-Lot Mode for small demo balances.
- Added panel execution diagnostics for lot, estimated risk, `LOT<MIN`, margin, preflight and server rejection.
- Aligned the source default to disable the broker-server-hour filter while retaining UTC liquid sessions.

## 1.41 — Balanced IQ

- Retuned the entry threshold to 70/100, five votes and a 10-point directional edge.
- Asia now requires 75/100 while retaining its 50% risk factor.
- Kept the Transition and higher-timeframe conflict vetoes enabled.
- Split the panel into independent SCALP and INTRA summaries.
- Added concise gate diagnostics: TRANS, HTF, EDGE, vote shortage, quality shortage and PASS.

## 1.40 — IQ + Confluence Pro

- Added explainable 100-point Long/Short scoring with nine confluence factors.
- Added Trend, Range and blocked Transition regime classification.
- Added higher-timeframe, directional-edge, vote-count and quality vetoes.
- Added MACD, candle body, wick rejection, two-candle structure and anti-chase checks.
- Added conservative Asia session (00:00–06:00 UTC), 50% session risk and +5 IQ requirement.
- Expanded the high-impact calendar guard to USD, CNY, JPY and AUD.
- Expanded the panel with IQ bias, vote count, regime, Long/Short scores and veto reason.
- Retained the $50 daily target stop and all v1.30 execution safety locks.

## 1.30 — Safety Pro

- Added economic-calendar protection, target buffer, adaptive loss risk, order preflight, volatility checks, transaction telemetry and London/New York filtering.
