# SevenzEA v1.43 — Reference Hybrid Active

## Purpose

v1.42 could remain inactive because its 12% spread/ATR hard limit was calculated from M1 ATR. A normal 27-point XAUUSD spread against a 121-point M1 ATR equals about 22%, so the volatility guard rejected the setup before the IQ engine could qualify it.

## Active model

- Direction inputs: M15, M5 and M1.
- Minimum direction agreement: two of three timeframes.
- Evaluation/execution cycle: once per new M5 bar.
- ADX floor: 14 on M5.
- RSI window: 30–70 on M1.
- Pullback allowance: 1.5 ATR from the M1 fast EMA.
- IQ gate: 60/100, four votes and an eight-point directional edge.
- Candle confirmation: optional for this active profile.

## Adaptive spread control

- Fixed XAUUSD ceiling: 35 points in the supplied presets.
- Spread surge veto: current spread must remain at or below 1.7 times its rolling 30-sample median after ten samples.
- Spread/ATR and ATR-spike checks use M5 ATR for the active profile.

This allows normal execution costs without turning the volatility guard off. The panel reports current spread, maximum spread and rolling median.

## Safety retained

- Auto-Trade is a true runtime arm and starts OFF after loading.
- Demo Minimum-Lot Mode cannot authorize a real account.
- Broker-aware `OrderCalcProfit` sizing remains active.
- One position per symbol, six trades per day, daily-loss, drawdown, loss-streak, news, margin, target and Friday protections remain active.
- Asia uses half risk; the active preset does not add an extra IQ penalty.

The reference EA's always-live default, rapid position stacking, 500-trade daily cap, disabled-news default, forced counter-trend entries and unconditional minimum-lot clamping were intentionally not copied.
