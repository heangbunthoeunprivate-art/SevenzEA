# របៀបដំឡើង SevenzEA ក្នុង MT5

## 1. ដាក់ Source Code

1. បើក MT5 ហើយចុច `File > Open Data Folder`។
2. ចូល `MQL5 > Experts`។
3. ចម្លង `SevenzEA.mq5` ចូល Folder នេះ។
4. បើក MetaEditor ហើយចុច Compile។ ត្រូវឃើញ `0 errors` មុន Test។

## 2. កំណត់ Symbol

ដាក់ឈ្មោះ Gold Symbol ឱ្យដូច Broker ពិតៗក្នុង `InpSymbols`។ ឧទាហរណ៍ Broker ខ្លះប្រើ `XAUUSD.a`, `XAUUSDm` ឬ `GOLD` មិនមែន `XAUUSD` ទេ។ Version នេះបើក `InpXauOnlyMode=true` ដូច្នេះវាមិន Trade Forex ទេ។

Daily Target កំណត់ `InpDailyProfitTargetMoney=50.00` និង `InpRequireUsdAccount=true` ដើម្បីធានាថា Account Currency ជា USD ហើយ Target មានន័យថា $50 ក្នុងមួយថ្ងៃ។ ពេល Equity កើនដល់ Target EA នឹងបិទ Auto-Trade និងមិនបើក Order ថ្មីទៀតក្នុងថ្ងៃនោះ។

## 5. Safety Pro v1.30

- News Guard ផ្អាក Trade 30 នាទីមុន និងក្រោយ USD High-impact news។ Panel បង្ហាញ Countdown តាម Broker server time។
- Target close ប្រើ buffer $2 ដើម្បីកាត់បន្ថយផលប៉ះពាល់ Slippage ហើយ Panel បង្ហាញ Realized និង Equity P&L ដាច់ពីគ្នា។
- ក្រោយខាត 1 Trade Risk ចុះទៅ 75%; ក្រោយខាត 2 Trade ចុះទៅ 50%; ខាត 3 ជាប់គ្នា EA Lock។
- EA Trade តែក្នុង London 07:00–16:00 UTC ឬ New York 12:00–21:00 UTC។
- Strategy Tester អាចមិនមាន MT5 Economic Calendar។ ត្រូវ Forward Test លើ Demo ហើយមើល News line លើ Panel មុនបើក Real Account។

## 6. IQ + Confluence Pro v1.40

- EA គណនា Long Score និង Short Score ដាច់ពីគ្នា ដោយប្រើ EMA Multi-Timeframe, ADX/DI, RSI, MACD, Candle, Structure, Bollinger Band និង ATR distance។
- Default ត្រូវការ Score យ៉ាងតិច 78/100, Confluence 6 និង Directional Edge 15 ទើបអាច Entry។
- Transition Regime និង Higher-Timeframe Conflict ត្រូវបាន Veto មិនឱ្យបើក Order។
- Asia Session គឺ 00:00–06:00 UTC (07:00–13:00 ម៉ោងកម្ពុជា)។ EA ប្រើ Risk 50% និងទាមទារ Score 83/100 នៅ Session នេះ។
- News Guard គ្រប់គ្រង USD, CNY, JPY និង AUD High-impact news។
- Panel បង្ហាញ IQ Bias, Score, Votes, Regime, Long/Short Score និងមូលហេតុដែល Signal ត្រូវ Block។

## 7. Balanced IQ v1.41

- Score Default បន្ថយពី 78 មក 70។ Asia Session ត្រូវការ 75 ព្រោះមាន Bonus 5។
- Confluence Votes បន្ថយពី 6 មក 5 និង Directional Edge ពី 15 មក 10។
- Transition Regime, Higher-Timeframe Veto, News Guard, Spread/ATR Guard និង Safety Locks នៅតែ ON។
- Panel បង្ហាញ `SCALP` និង `INTRA` ដាច់ពីគ្នា។ Gate code: `TRANS` = Transition, `HTF` = Higher-Timeframe conflict, `EDGE` = Direction conflict, `V4/5` = Votes ខ្វះ, `Q65/70` = Score ខ្វះ និង `PASS` = Signal ឆ្លង IQ gate។
- Balanced thresholds របស់ v1.41 ត្រូវបានរក្សាទុកក្នុង Changelog; សម្រាប់ Test ថ្មីប្រើ v1.42 Active Demo preset ខាងក្រោម។

## 8. Active Execution v1.42

- `InpUseM1ActiveScalp=true` ប្រើ M1 Entry, M5 Confirmation និង M15 Anchor។ Chart អាចទុកនៅ M15 ដដែល។
- Active IQ Default គឺ Score 65, Votes 4 និង Directional Edge 8។ Asia ត្រូវការ Score 70។
- Lot គណនាតាម `OrderCalcProfit` របស់ Broker ដើម្បីឱ្យ Estimated Stop Risk ត្រឹមត្រូវជាង Tick Formula ទូទៅ។
- Demo preset `SevenzEA_v1.42_Active_Demo.set` មាន `InpDemoMinLotMode=true`។ បើ Calculated Lot តូចជាង 0.01 វាអាចប្រើ 0.01 លើ Demo និងបង្ហាញ Risk ពិតនៅ `Exec` line។
- `LOT<MIN` មានន័យថា Lot តូចជាង Broker minimum ហើយ EA បាន Block។ `DEMO MIN 0.01 risk $...` មានន័យថា Demo Mode បានប្រើ Minimum Lot។
- ក្រោយ Load preset ឬ Compile ត្រូវបើក MT5 Algo Trading និងចុច `AUTO-TRADE: ON` វិញ។

## 3. Safety Lock ដំបូង

- ទុក `InpEnableOrderExecution=false` ដើម្បីមើល Signal ដោយមិនបើក Order។
- ទុក `InpAllowRealAccount=false` ពេល Backtest និង Demo។
- បើចង់ Demo Auto Trade សូមប្ដូរតែ `InpEnableOrderExecution=true`។
- សម្រាប់ Real ត្រូវប្ដូរទាំង `InpEnableOrderExecution=true` និង `InpAllowRealAccount=true` បន្ទាប់ពី Test ជោគជ័យ។

## 4. Strategy Tester

Test XAUUSD និង Forex ម្ដងមួយ Symbol។ ប្រើ Real Ticks, Spread/Commission របស់ Broker និងរយៈពេលច្រើនខែ។ លទ្ធផល Backtest មិនធានាចំណេញពេល Live ទេ ដូច្នេះត្រូវ Forward Test លើ Demo បន្ថែម។
