# Changelog

## 1.44 — Bridge Ready

- Added optional read-only EA telemetry with Bearer authentication.
- Added a local FastAPI Bridge that merges EA IQ status with the logged-in MT5 terminal snapshot.
- Added `/v1/health`, `/v1/ea/telemetry` and `/v1/snapshot`; no remote execution routes exist.
- Added Windows setup, start and health-check scripts with automatic secret generation.
- Added Khmer setup guidance for MT5 WebRequest and managed HTTPS tunnel configuration.
- Kept v1.43 signal, execution, risk and safety behavior unchanged; Bridge telemetry is disabled by default.

## 1.43 — Reference Hybrid Active

- Added M15/M5/M1 two-of-three direction alignment for the active profile.
- Evaluates active entries once per M5 bar while retaining the closed M1 signal input.
- Uses M5 ATR for active volatility and spread/ATR validation, fixing the overly strict M1 cost ratio.
- Added a rolling-median spread-surge veto with a 1.7× default multiplier.
- Added active defaults: ADX 14, RSI 30–70, pullback distance 1.5 ATR and IQ 60.
- Removed the extra Asia IQ penalty from the active preset while retaining half risk and news protection.
- Kept true Auto-Trade arming, one-position-per-symbol, broker-aware risk sizing and all real-account locks.

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
