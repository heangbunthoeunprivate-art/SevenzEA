# SevenzEA v1.41 — Balanced IQ

## Purpose

v1.40 was intentionally very selective and could complete a liquid trading day without finding one eligible setup. v1.41 keeps the same confluence model and safety architecture but moves the entry gate to a practical balanced profile.

## Balanced defaults

| Setting | v1.40 | v1.41 |
| --- | ---: | ---: |
| Base IQ score | 78 | 70 |
| Asia IQ score | 83 | 75 |
| Minimum votes | 6 | 5 |
| Directional edge | 15 | 10 |

The change increases opportunity frequency. It does not promise a trade count, win rate or $50 profit per day.

## Safety retained

- Transition regime remains blocked.
- Higher-timeframe conflict remains blocked.
- One-position maximum, risk sizing and consecutive-loss reduction remain active.
- USD/CNY/JPY/AUD news, spread/ATR, daily-loss, equity-drawdown and target locks remain active.
- Asia retains the 50% session risk factor.

## Panel diagnostics

SCALP shows the M5 entry/M15 confirmation decision. INTRA shows the M15 entry/H1 confirmation decision. Each line displays its own direction, quality score, vote count and regime, preventing one profile's status from being mistaken for the other.

Gate codes are `TRANS`, `HTF`, `EDGE`, `WAIT`, `Vx/5`, `Qx/threshold` and `PASS`.
