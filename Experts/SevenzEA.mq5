#property copyright "SevenzEA"
#property version   "1.42"
#property description "XAUUSD Active Execution: M1/M5 scalp, broker-aware risk and visible order diagnostics"
#property strict

#include <Trade/Trade.mqh>

enum ENUM_SEVENZ_PROFILE
  {
   PROFILE_SCALPING = 0,
   PROFILE_INTRADAY = 1,
   PROFILE_BOTH     = 2
  };

enum ENUM_SEVENZ_RISK_MODE
  {
   RISK_FIXED_LOT   = 0,
   RISK_PERCENT     = 1
  };

input group "=== Symbols and profiles ==="
input string              InpSymbols                 = "XAUUSD";
input bool                InpXauOnlyMode             = true;
input ENUM_SEVENZ_PROFILE InpProfile                 = PROFILE_BOTH;
input bool                InpUseM1ActiveScalp        = true;
input int                 InpTimerSeconds            = 2;
input long                InpMagicBase               = 770100;

input group "=== Order execution safety locks ==="
input bool                InpEnableOrderExecution    = false;
input bool                InpAllowRealAccount        = false;
input bool                InpEmergencyStop           = false;
input int                 InpMaxTradesPerDay         = 6;
input int                 InpMaxOpenPositions        = 1;
input int                 InpMaxConsecutiveLosses    = 3;
input double              InpMaxDailyLossPercent     = 2.0;
input double              InpMaxEquityDrawdownPct    = 5.0;
input bool                InpStopAtDailyProfitTarget = true;
input bool                InpCloseAtDailyTarget      = true;
input bool                InpRequireUsdAccount       = true;
input double              InpTargetCloseBufferMoney = 2.00;
input int                 InpCooldownMinutes         = 20;
input int                 InpMaxForexSpreadPoints    = 35;
input int                 InpMaxMetalSpreadPoints    = 250;
input int                 InpMaxSlippagePoints       = 20;
input bool                InpOnePositionPerSymbol    = true;

input group "=== Position sizing ==="
input ENUM_SEVENZ_RISK_MODE InpRiskMode              = RISK_PERCENT;
input double              InpFixedLot                = 0.01;
input double              InpRiskPerTradePercent     = 0.50;
input double              InpMaximumLot              = 0.10;
input bool                InpAllowMinLotRiskOverride = false;
input bool                InpDemoMinLotMode          = false;
input double              InpMinFreeMarginPercent    = 30.0;

input group "=== Adaptive loss guard ==="
input bool                InpUseAdaptiveLossGuard    = true;
input double              InpRiskAfterOneLoss        = 0.75;
input double              InpRiskAfterTwoLosses      = 0.50;

input group "=== Trading hours (broker/server time) ==="
input bool                InpUseSessionFilter        = false;
input int                 InpSessionStartHour        = 7;
input int                 InpSessionEndHour          = 20;
input bool                InpTradeMonday             = true;
input bool                InpTradeTuesday            = true;
input bool                InpTradeWednesday          = true;
input bool                InpTradeThursday           = true;
input bool                InpTradeFriday             = true;
input bool                InpFridayCloseProtection   = true;
input int                 InpFridayStopHour           = 18;
input bool                InpUseLiquidSessions       = true;
input bool                InpUseAsiaSession          = true;
input int                 InpAsiaStartUtc            = 0;
input int                 InpAsiaEndUtc              = 6;
input double              InpAsiaRiskFactor          = 0.50;
input int                 InpAsiaQualityBonus        = 5;
input int                 InpLondonStartUtc          = 7;
input int                 InpLondonEndUtc            = 16;
input int                 InpNewYorkStartUtc         = 12;
input int                 InpNewYorkEndUtc           = 21;

input group "=== High-impact news guard ==="
input bool                InpUseNewsGuard            = true;
input bool                InpGuardAsiaCurrencies     = true;
input int                 InpNewsMinutesBefore       = 30;
input int                 InpNewsMinutesAfter        = 30;
input int                 InpNewsRefreshSeconds      = 60;
input bool                InpNewsFailClosedOnReal    = true;

input group "=== XAUUSD volatility guard ==="
input bool                InpUseVolatilityGuard      = true;
input int                 InpAtrAverageBars          = 50;
input double              InpMaxAtrSpikeRatio        = 2.20;
input double              InpMaxSpreadToAtrRatio     = 0.12;

input group "=== Hybrid regime and entries ==="
input int                 InpFastEmaPeriod           = 20;
input int                 InpSlowEmaPeriod           = 50;
input int                 InpConfirmEmaPeriod        = 200;
input int                 InpAdxPeriod               = 14;
input double              InpTrendAdxThreshold       = 23.0;
input int                 InpRsiPeriod               = 14;
input double              InpTrendRsiBuyMin          = 52.0;
input double              InpTrendRsiSellMax         = 48.0;
input double              InpRangeRsiBuyMax          = 32.0;
input double              InpRangeRsiSellMin         = 68.0;
input int                 InpBandsPeriod             = 20;
input double              InpBandsDeviation          = 2.0;
input int                 InpAtrPeriod               = 14;

input group "=== IQ + Confluence engine ==="
input bool                InpUseConfluenceEngine     = true;
input int                 InpMinConfluenceVotes      = 4;
input int                 InpMinDirectionalEdge      = 8;
input bool                InpBlockTransitionRegime  = true;
input double              InpRangeAdxCeiling         = 19.0;
input bool                InpUseHigherTfVeto         = true;
input bool                InpUseMacdConfirmation     = true;
input int                 InpMacdFastPeriod          = 12;
input int                 InpMacdSlowPeriod          = 26;
input int                 InpMacdSignalPeriod        = 9;
input double              InpMinCandleBodyAtr        = 0.12;
input double              InpMaxEntryDistanceAtr     = 0.90;

input group "=== Stops and management ==="
input double              InpScalpStopAtr            = 1.40;
input double              InpScalpTakeAtr            = 1.80;
input double              InpIntradayStopAtr         = 1.80;
input double              InpIntradayTakeAtr         = 2.60;
input bool                InpUseBreakEven            = true;
input double              InpBreakEvenAtR            = 1.00;
input int                 InpBreakEvenOffsetPoints   = 5;
input bool                InpUseAtrTrailing          = true;
input double              InpTrailStartR             = 1.40;
input double              InpTrailAtrMultiplier      = 1.20;

input group "=== Manual protection ==="
input bool                InpPauseNewEntries         = false;
input string              InpOrderComment            = "SevenzEA-v1.42";

input group "=== On-chart control panel ==="
input bool                InpShowControlPanel        = true;
input ENUM_BASE_CORNER    InpPanelCorner             = CORNER_LEFT_UPPER;
input int                 InpPanelX                  = 12;
input int                 InpPanelY                  = 28;
input int                 InpPanelWidth              = 300;
input int                 InpQualityThreshold        = 65;
input double              InpDailyProfitTargetMoney  = 50.00;

struct SymbolState
  {
   string   symbol;
   datetime scalp_bar;
   datetime intraday_bar;
   datetime last_trade;
  };

struct SignalResult
  {
   int      direction;       // 1 buy, -1 sell, 0 no signal
   bool     trending;
   double   atr;
   int      quality;
   int      votes;
   int      long_score;
   int      short_score;
   string   regime;
   string   veto;
   string   reason;
  };

CTrade      g_trade;
SymbolState g_states[];
double      g_peakEquity       = 0.0;
double      g_dayStartEquity   = 0.0;
int         g_dayKey           = -1;
string      g_status           = "Starting";
bool        g_runtimePaused    = false;
bool        g_runtimeScalp     = true;
bool        g_runtimeAutoTrade = false;
bool        g_runtimeQuality   = true;
datetime    g_closeArmUntil    = 0;
int         g_targetHandledDay = -1;
datetime    g_lastNewsRefresh  = 0;
datetime    g_newsEventTime    = 0;
string      g_newsEventName    = "Calendar loading";
bool        g_newsBlocked      = false;
bool        g_newsAvailable    = false;
string      g_lastTradeEvent   = "No trade event yet";
double      g_lastRiskFactor   = 1.0;
double      g_lastAtrRatio     = 0.0;
double      g_lastSpreadAtr    = 0.0;
int         g_lastIqScore      = 0;
int         g_lastIqVotes      = 0;
int         g_lastLongScore    = 0;
int         g_lastShortScore   = 0;
string      g_lastRegime       = "LOADING";
string      g_lastIqVeto       = "Market data loading";
string      g_lastVolumeReason = "Waiting for qualified order";
double      g_lastVolume       = 0.0;
double      g_lastRiskMoney    = 0.0;

#define PANEL_PREFIX "SEVENZ_PANEL_"

int OnInit()
  {
   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;

   if(!BuildSymbolList())
     {
      Print("SevenzEA: no valid symbols in InpSymbols.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_trade.SetDeviationInPoints(InpMaxSlippagePoints);
   g_trade.SetAsyncMode(false);
   g_peakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   LoadSafetyState();
   EventSetTimer(InpTimerSeconds);
   g_runtimeScalp = (InpProfile == PROFILE_SCALPING || InpProfile == PROFILE_BOTH);
   CreateControlPanel();
   UpdateChartStatus();
   UpdateNewsGuard(true);
   Print("SevenzEA v1.42 XAUUSD Active Execution initialized. Symbols=", ArraySize(g_states),
         " execution=", InpEnableOrderExecution,
         " realAllowed=", InpAllowRealAccount);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   PersistSafetyState();
   Comment("");
   ObjectsDeleteAll(0, PANEL_PREFIX);
  }

void OnTick()
  {
   ManageOpenPositions();
  }

void OnTimer()
  {
   RefreshDailyState();
   UpdateNewsGuard(false);
   ManageOpenPositions();
   EnforceDailyProfitTarget();

   string lockReason;
   if(!MayEvaluateEntries(lockReason))
     {
      g_status = lockReason;
      UpdateChartStatus();
      return;
     }

   for(int i=0; i<ArraySize(g_states); i++)
     {
      const string symbol = g_states[i].symbol;
      if(InpProfile == PROFILE_SCALPING || InpProfile == PROFILE_BOTH)
         ProcessProfile(i, symbol, PROFILE_SCALPING, ScalpEntryTimeframe(), ScalpConfirmTimeframe());

      if(InpProfile == PROFILE_INTRADAY || InpProfile == PROFILE_BOTH)
         ProcessProfile(i, symbol, PROFILE_INTRADAY, PERIOD_M15, PERIOD_H1);
     }

   UpdateChartStatus();
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(trans.type == TRADE_TRANSACTION_REQUEST && IsOurMagic((long)request.magic))
     {
      g_lastTradeEvent = "Request " + IntegerToString((long)result.retcode) + ": " + result.comment;
      if(result.retcode != TRADE_RETCODE_DONE && result.retcode != TRADE_RETCODE_PLACED)
         g_status = "SERVER: " + result.comment;
     }

   if(trans.type != TRADE_TRANSACTION_DEAL_ADD || trans.deal == 0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   const long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
   if(!IsOurMagic(magic)) return;

   const ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   const string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
   const double price = HistoryDealGetDouble(trans.deal, DEAL_PRICE);
   const double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT) +
                         HistoryDealGetDouble(trans.deal, DEAL_SWAP) +
                         HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
   if(entry == DEAL_ENTRY_IN)
      g_lastTradeEvent = symbol + " filled @ " + DoubleToString(price, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
   else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
      g_lastTradeEvent = symbol + " closed " + SignedMoney(profit);
   UpdateChartStatus();
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK || StringFind(sparam, PANEL_PREFIX) != 0)
      return;

   if(sparam == PANEL_PREFIX + "BTN_PAUSE")
     {
      g_runtimePaused = !g_runtimePaused;
      g_status = (g_runtimePaused ? "PAUSED from panel" : "LIVE scanning resumed");
     }
   else if(sparam == PANEL_PREFIX + "BTN_SCALP")
     {
      g_runtimeScalp = !g_runtimeScalp;
      g_status = (g_runtimeScalp ? "Scalping profile enabled" : "Scalping profile disabled");
     }
   else if(sparam == PANEL_PREFIX + "BTN_AUTO")
     {
      if(!InpEnableOrderExecution)
         g_status = "LOCKED: enable order execution in EA inputs";
      else if((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL &&
              !InpAllowRealAccount)
         g_status = "LOCKED: real-account input is OFF";
      else
        {
         g_runtimeAutoTrade = !g_runtimeAutoTrade;
         g_status = (g_runtimeAutoTrade ? "AUTO-TRADE armed" : "AUTO-TRADE disarmed");
        }
     }
   else if(sparam == PANEL_PREFIX + "BTN_QUALITY")
     {
      g_runtimeQuality = !g_runtimeQuality;
      g_status = (g_runtimeQuality ? "Quality filter enabled" : "Quality filter disabled");
     }
   else if(sparam == PANEL_PREFIX + "BTN_CLOSE")
     {
      if(TimeCurrent() <= g_closeArmUntil)
        {
         CloseAllSevenzPositions();
         g_closeArmUntil = 0;
        }
      else
        {
         g_closeArmUntil = TimeCurrent() + 5;
         g_status = "Click CLOSE ALL again within 5 seconds";
        }
     }
   else if(sparam == PANEL_PREFIX + "BTN_RESET")
     {
      g_status = "Safety counters use trade history and cannot be bypassed";
     }

   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   UpdateChartStatus();
  }

bool BuildSymbolList()
  {
   string parts[];
   const int count = StringSplit(InpSymbols, ',', parts);
   if(count <= 0)
      return false;

   ArrayResize(g_states, 0);
   for(int i=0; i<count; i++)
     {
      string symbol = parts[i];
      StringTrimLeft(symbol);
      StringTrimRight(symbol);
      if(symbol == "")
         continue;

      if(InpXauOnlyMode && !IsGoldSymbol(symbol))
        {
         Print("SevenzEA XAUUSD Edition: skipped non-gold symbol: ", symbol);
         continue;
        }

      if(!SymbolSelect(symbol, true))
        {
         Print("SevenzEA: symbol unavailable: ", symbol,
               ". Use the broker's exact symbol name/suffix.");
         continue;
        }

      const int n = ArraySize(g_states);
      ArrayResize(g_states, n + 1);
      g_states[n].symbol       = symbol;
      g_states[n].scalp_bar    = 0;
      g_states[n].intraday_bar = 0;
      g_states[n].last_trade   = 0;
     }
   return ArraySize(g_states) > 0;
  }

void ProcessProfile(const int stateIndex,
                    const string symbol,
                    const ENUM_SEVENZ_PROFILE profile,
                    const ENUM_TIMEFRAMES entryTf,
                    const ENUM_TIMEFRAMES confirmTf)
  {
   const string profileName = (profile == PROFILE_SCALPING ?
                               (InpUseM1ActiveScalp ? "M1SCALP" : "M5SCALP") : "INTRA");
   const datetime currentBar = iTime(symbol, entryTf, 0);
   if(currentBar <= 0)
      return;

   if(profile == PROFILE_SCALPING && g_states[stateIndex].scalp_bar == currentBar)
      return;
   if(profile == PROFILE_INTRADAY && g_states[stateIndex].intraday_bar == currentBar)
      return;

   if(profile == PROFILE_SCALPING && !g_runtimeScalp)
      return;

   if(InpOnePositionPerSymbol && HasOurPosition(symbol))
      return;

   if((TimeCurrent() - g_states[stateIndex].last_trade) < InpCooldownMinutes * 60)
      return;

   const int spread = (int)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   const int maxSpread = MaxSpreadForSymbol(symbol);
   if(spread <= 0 || spread > maxSpread)
     {
      Print(symbol, ": blocked by spread ", spread, "/", maxSpread, " points");
      return;
     }

   string volatilityReason;
   if(!VolatilityAllowed(symbol, entryTf, volatilityReason))
     {
      g_status = symbol + " " + profileName + " blocked: " + volatilityReason;
      return;
     }

   SignalResult signal;
   if(!BuildSignal(symbol, entryTf, confirmTf, signal))
      return;

   g_lastIqScore = signal.quality;
   g_lastIqVotes = signal.votes;
   g_lastLongScore = signal.long_score;
   g_lastShortScore = signal.short_score;
   g_lastRegime = signal.regime;
   g_lastIqVeto = signal.veto;

   if(profile == PROFILE_SCALPING) g_states[stateIndex].scalp_bar = currentBar;
   else                            g_states[stateIndex].intraday_bar = currentBar;

   if(signal.direction == 0)
     {
      g_status = symbol + " " + profileName + " wait: " + signal.veto;
      return;
     }

   if(InpUseConfluenceEngine && signal.votes < InpMinConfluenceVotes)
     {
      g_status = symbol + " " + profileName + " blocked: votes " + IntegerToString(signal.votes) + "/" +
                 IntegerToString(InpMinConfluenceVotes);
      return;
     }

   const int requiredQuality = (int)MathMin(100.0, (double)(InpQualityThreshold +
                                            (IsAsiaSession() ? InpAsiaQualityBonus : 0)));
   if(g_runtimeQuality && signal.quality < requiredQuality)
     {
      g_status = symbol + " " + profileName + " blocked: IQ " + IntegerToString(signal.quality) + "/" +
                 IntegerToString(requiredQuality);
      return;
     }

   string safetyReason;
   if(!MayPlaceOrder(symbol, safetyReason))
     {
      g_status = profileName + ": " + safetyReason;
      Print(symbol, ": signal blocked: ", safetyReason);
      return;
     }

   ExecuteSignal(symbol, stateIndex, profile, signal);
  }

bool BuildSignal(const string symbol,
                 const ENUM_TIMEFRAMES entryTf,
                 const ENUM_TIMEFRAMES confirmTf,
                 SignalResult &out)
  {
   out.direction = 0;
   out.trending  = false;
   out.atr       = 0.0;
   out.quality   = 0;
   out.votes     = 0;
   out.long_score = 0;
   out.short_score = 0;
   out.regime    = "UNKNOWN";
   out.veto      = "No qualified setup";
   out.reason    = "";

   const ENUM_TIMEFRAMES anchorTf = AnchorTimeframe(confirmTf);
   double fast[3], slow[3], confirmFast[3], confirmSlow[3], anchorEma[3];
   double adx[3], plusDi[3], minusDi[3], rsi[3], atr[3];
   double bandBase[3], bandUpper[3], bandLower[3];
   double macdMain[3], macdSignal[3];
   MqlRates rates[3], confirmRates[3], anchorRates[3];
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(confirmRates, true);
   ArraySetAsSeries(anchorRates, true);

   if(!ReadMA(symbol, entryTf, InpFastEmaPeriod, fast) ||
      !ReadMA(symbol, entryTf, InpSlowEmaPeriod, slow) ||
      !ReadMA(symbol, confirmTf, InpFastEmaPeriod, confirmFast) ||
      !ReadMA(symbol, confirmTf, InpSlowEmaPeriod, confirmSlow) ||
      !ReadMA(symbol, anchorTf, InpConfirmEmaPeriod, anchorEma) ||
      !ReadADX(symbol, confirmTf, adx, plusDi, minusDi) ||
      !ReadRSI(symbol, entryTf, rsi) ||
      !ReadATR(symbol, entryTf, atr) ||
      !ReadBands(symbol, entryTf, bandBase, bandUpper, bandLower) ||
      !ReadMACD(symbol, entryTf, macdMain, macdSignal) ||
      CopyRates(symbol, entryTf, 0, 3, rates) < 3 ||
      CopyRates(symbol, confirmTf, 0, 3, confirmRates) < 3 ||
      CopyRates(symbol, anchorTf, 0, 3, anchorRates) < 3)
      return false;

   const double close1 = rates[1].close;
   const double open1  = rates[1].open;
   const double high1  = rates[1].high;
   const double low1   = rates[1].low;
   out.atr             = atr[1];
   out.trending        = adx[1] >= InpTrendAdxThreshold;

   if(out.atr <= 0.0)
      return false;

   const bool transition = adx[1] > InpRangeAdxCeiling && adx[1] < InpTrendAdxThreshold;
   out.regime = (out.trending ? "TREND" : transition ? "TRANSITION" : "RANGE");
   if(InpUseConfluenceEngine && InpBlockTransitionRegime && transition)
     {
      out.veto = "Transition regime veto";
      return true;
     }

   const double body = MathAbs(close1 - open1);
   const double upperWick = high1 - MathMax(open1, close1);
   const double lowerWick = MathMin(open1, close1) - low1;
   const bool bullishBody = close1 > open1 && body >= out.atr * InpMinCandleBodyAtr;
   const bool bearishBody = close1 < open1 && body >= out.atr * InpMinCandleBodyAtr;
   const bool notChasedBuy = MathAbs(close1 - fast[1]) <= out.atr * InpMaxEntryDistanceAtr;
   const bool notChasedSell = notChasedBuy;

   const bool entryBuy = fast[1] > slow[1] && close1 > fast[1];
   const bool entrySell = fast[1] < slow[1] && close1 < fast[1];
   const bool confirmBuy = confirmFast[1] > confirmSlow[1] &&
                           confirmRates[1].close > confirmFast[1];
   const bool confirmSell = confirmFast[1] < confirmSlow[1] &&
                            confirmRates[1].close < confirmFast[1];
   const bool anchorBuy = anchorRates[1].close > anchorEma[1] && anchorEma[1] >= anchorEma[2];
   const bool anchorSell = anchorRates[1].close < anchorEma[1] && anchorEma[1] <= anchorEma[2];
   const bool diBuy = plusDi[1] > minusDi[1] && plusDi[1] - minusDi[1] >= 3.0;
   const bool diSell = minusDi[1] > plusDi[1] && minusDi[1] - plusDi[1] >= 3.0;
   const bool momentumBuy = rsi[1] >= InpTrendRsiBuyMin && rsi[1] < 70.0;
   const bool momentumSell = rsi[1] <= InpTrendRsiSellMax && rsi[1] > 30.0;
   const bool macdBuy = macdMain[1] > macdSignal[1] && macdMain[1] >= macdMain[2];
   const bool macdSell = macdMain[1] < macdSignal[1] && macdMain[1] <= macdMain[2];
   const bool structureBuy = high1 > rates[2].high && low1 >= rates[2].low;
   const bool structureSell = low1 < rates[2].low && high1 <= rates[2].high;

   int buyScore = 0, sellScore = 0, buyVotes = 0, sellVotes = 0;
   bool buyCandidate = false, sellCandidate = false;

   if(out.trending)
     {
      AddConfluence(entryBuy, 15, buyScore, buyVotes);
      AddConfluence(confirmBuy, 15, buyScore, buyVotes);
      AddConfluence(anchorBuy, 15, buyScore, buyVotes);
      AddConfluence(diBuy, 15, buyScore, buyVotes);
      AddConfluence(momentumBuy, 10, buyScore, buyVotes);
      AddConfluence(InpUseMacdConfirmation && macdBuy, 10, buyScore, buyVotes);
      AddConfluence(bullishBody, 10, buyScore, buyVotes);
      AddConfluence(structureBuy, 5, buyScore, buyVotes);
      AddConfluence(notChasedBuy, 5, buyScore, buyVotes);

      AddConfluence(entrySell, 15, sellScore, sellVotes);
      AddConfluence(confirmSell, 15, sellScore, sellVotes);
      AddConfluence(anchorSell, 15, sellScore, sellVotes);
      AddConfluence(diSell, 15, sellScore, sellVotes);
      AddConfluence(momentumSell, 10, sellScore, sellVotes);
      AddConfluence(InpUseMacdConfirmation && macdSell, 10, sellScore, sellVotes);
      AddConfluence(bearishBody, 10, sellScore, sellVotes);
      AddConfluence(structureSell, 5, sellScore, sellVotes);
      AddConfluence(notChasedSell, 5, sellScore, sellVotes);

      buyCandidate = entryBuy && confirmBuy && bullishBody && momentumBuy;
      sellCandidate = entrySell && confirmSell && bearishBody && momentumSell;
     }
   else
     {
      const bool bandBuy = low1 <= bandLower[1] && close1 > bandLower[1];
      const bool bandSell = high1 >= bandUpper[1] && close1 < bandUpper[1];
      const bool rangeRsiBuy = rsi[1] <= InpRangeRsiBuyMax;
      const bool rangeRsiSell = rsi[1] >= InpRangeRsiSellMin;
      const bool rejectionBuy = bullishBody && lowerWick >= body * 0.50;
      const bool rejectionSell = bearishBody && upperWick >= body * 0.50;
      const bool rangeMacdBuy = macdMain[1] > macdSignal[1] || macdMain[1] > macdMain[2];
      const bool rangeMacdSell = macdMain[1] < macdSignal[1] || macdMain[1] < macdMain[2];
      const bool notOpposedBuy = !confirmSell;
      const bool notOpposedSell = !confirmBuy;
      const bool anchorNotOpposedBuy = !anchorSell;
      const bool anchorNotOpposedSell = !anchorBuy;

      AddConfluence(bandBuy, 20, buyScore, buyVotes);
      AddConfluence(rangeRsiBuy, 15, buyScore, buyVotes);
      AddConfluence(rejectionBuy, 12, buyScore, buyVotes);
      AddConfluence(adx[1] <= InpRangeAdxCeiling, 13, buyScore, buyVotes);
      AddConfluence(InpUseMacdConfirmation && rangeMacdBuy, 10, buyScore, buyVotes);
      AddConfluence(structureBuy, 10, buyScore, buyVotes);
      AddConfluence(notOpposedBuy, 8, buyScore, buyVotes);
      AddConfluence(anchorNotOpposedBuy, 7, buyScore, buyVotes);
      AddConfluence(close1 <= bandBase[1], 5, buyScore, buyVotes);

      AddConfluence(bandSell, 20, sellScore, sellVotes);
      AddConfluence(rangeRsiSell, 15, sellScore, sellVotes);
      AddConfluence(rejectionSell, 12, sellScore, sellVotes);
      AddConfluence(adx[1] <= InpRangeAdxCeiling, 13, sellScore, sellVotes);
      AddConfluence(InpUseMacdConfirmation && rangeMacdSell, 10, sellScore, sellVotes);
      AddConfluence(structureSell, 10, sellScore, sellVotes);
      AddConfluence(notOpposedSell, 8, sellScore, sellVotes);
      AddConfluence(anchorNotOpposedSell, 7, sellScore, sellVotes);
      AddConfluence(close1 >= bandBase[1], 5, sellScore, sellVotes);

      buyCandidate = bandBuy && rangeRsiBuy && bullishBody;
      sellCandidate = bandSell && rangeRsiSell && bearishBody;
     }

   out.long_score = (int)MathMin(100.0, (double)buyScore);
   out.short_score = (int)MathMin(100.0, (double)sellScore);
   const bool buyVeto = InpUseHigherTfVeto &&
                        (out.trending ? !anchorBuy : anchorSell);
   const bool sellVeto = InpUseHigherTfVeto &&
                         (out.trending ? !anchorSell : anchorBuy);

   if(buyCandidate && !buyVeto && buyScore >= sellScore + InpMinDirectionalEdge)
     {
      out.direction = 1;
      out.quality = out.long_score;
      out.votes = buyVotes;
      out.reason = (out.trending ? "IQ-trend-buy" : "IQ-range-buy");
      out.veto = "Passed";
     }
   else if(sellCandidate && !sellVeto && sellScore >= buyScore + InpMinDirectionalEdge)
     {
      out.direction = -1;
      out.quality = out.short_score;
      out.votes = sellVotes;
      out.reason = (out.trending ? "IQ-trend-sell" : "IQ-range-sell");
      out.veto = "Passed";
     }
   else if((buyCandidate && buyVeto) || (sellCandidate && sellVeto))
      out.veto = "Higher-timeframe conflict veto";
   else if(buyCandidate || sellCandidate)
      out.veto = "Directional score conflict veto";

   if(out.direction == 0)
     {
      out.quality = (int)MathMax((double)out.long_score, (double)out.short_score);
      out.votes = (out.long_score >= out.short_score ? buyVotes : sellVotes);
     }

   if(!InpUseConfluenceEngine)
     {
      out.votes = MathMax(buyVotes, sellVotes);
      if(out.direction == 0)
        {
         if(buyCandidate) { out.direction = 1; out.quality = out.long_score; out.reason = "legacy-buy"; }
         else if(sellCandidate) { out.direction = -1; out.quality = out.short_score; out.reason = "legacy-sell"; }
        }
     }
   return true;
  }

void AddConfluence(const bool condition, const int weight, int &score, int &votes)
  {
   if(!condition) return;
   score += weight;
   votes++;
  }

ENUM_TIMEFRAMES AnchorTimeframe(const ENUM_TIMEFRAMES confirmTf)
  {
   if(confirmTf <= PERIOD_M5) return PERIOD_M15;
   if(confirmTf <= PERIOD_M15) return PERIOD_H1;
   if(confirmTf <= PERIOD_H1) return PERIOD_H4;
   return PERIOD_D1;
  }

ENUM_TIMEFRAMES ScalpEntryTimeframe()
  {
   return (InpUseM1ActiveScalp ? PERIOD_M1 : PERIOD_M5);
  }

ENUM_TIMEFRAMES ScalpConfirmTimeframe()
  {
   return (InpUseM1ActiveScalp ? PERIOD_M5 : PERIOD_M15);
  }

void ExecuteSignal(const string symbol,
                   const int symbolIndex,
                   const ENUM_SEVENZ_PROFILE profile,
                   const SignalResult &signal)
  {
   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick))
      return;

   const double stopAtr = (profile == PROFILE_SCALPING ? InpScalpStopAtr : InpIntradayStopAtr);
   const double takeAtr = (profile == PROFILE_SCALPING ? InpScalpTakeAtr : InpIntradayTakeAtr);
   const double entry   = (signal.direction > 0 ? tick.ask : tick.bid);
   double sl = (signal.direction > 0 ? entry - signal.atr * stopAtr : entry + signal.atr * stopAtr);
   double tp = (signal.direction > 0 ? entry + signal.atr * takeAtr : entry - signal.atr * takeAtr);

   if(!RespectStopLevel(symbol, entry, signal.direction, sl, tp))
      return;

   string volumeReason;
   const double volume = CalculateVolume(symbol, signal.direction, entry, sl, volumeReason);
   g_lastVolumeReason = volumeReason;
   if(volume <= 0.0)
     {
      g_status = symbol + " blocked: " + volumeReason;
      g_lastTradeEvent = g_status;
      Print(g_status);
      return;
     }

   string executionReason;
   if(!CanTradeDirection(symbol, signal.direction, executionReason) ||
      !HasMarginCapacity(symbol, signal.direction, volume, entry, executionReason))
     {
      g_status = symbol + " blocked: " + executionReason;
      g_lastVolumeReason = executionReason;
      Print(g_status);
      return;
     }

   const long magic = MagicFor(symbolIndex, profile);
   g_trade.SetExpertMagicNumber(magic);
   g_trade.SetTypeFilling(FillingModeForSymbol(symbol));

   const int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   const string comment = InpOrderComment + " " +
                          (profile == PROFILE_SCALPING ? "SCALP" : "INTRA") + " " + signal.reason;

   if(!PreflightOrder(symbol, signal.direction, volume, entry, sl, tp, magic, comment, executionReason))
     {
      g_status = symbol + " preflight blocked: " + executionReason;
      g_lastTradeEvent = g_status;
      g_lastVolumeReason = executionReason;
      Print(g_status);
      return;
     }

   bool sent = false;
   if(signal.direction > 0)
      sent = g_trade.Buy(volume, symbol, 0.0, sl, tp, comment);
   else
      sent = g_trade.Sell(volume, symbol, 0.0, sl, tp, comment);

   if(sent)
     {
      g_states[symbolIndex].last_trade = TimeCurrent();
      g_status = symbol + " order opened: " + signal.reason;
      g_lastVolumeReason = "OPEN " + DoubleToString(volume, 2) + " lot; risk " +
                           "$" + DoubleToString(g_lastRiskMoney, 2);
      Print(g_status, " lot=", DoubleToString(volume, 2),
            " SL=", DoubleToString(sl, digits), " TP=", DoubleToString(tp, digits));
     }
   else
     {
      g_status = symbol + " order failed";
      g_lastVolumeReason = "SERVER: " + g_trade.ResultRetcodeDescription();
      Print(g_status, ": ", g_trade.ResultRetcode(), " ", g_trade.ResultRetcodeDescription());
     }
  }

bool MayEvaluateEntries(string &reason)
  {
   if(g_runtimePaused)
     {
      reason = "PAUSED: panel pause is active";
      return false;
     }
   if(InpEmergencyStop)
     {
      reason = "LOCKED: emergency stop";
      return false;
     }
   if(InpPauseNewEntries)
     {
      reason = "PAUSED: new entries disabled";
      return false;
     }
   if(InpUseNewsGuard && NewsGuardBlocksTrading(reason))
      return false;
   if(!IsTradingDayAndHour())
     {
      reason = "WAIT: outside trading session";
      return false;
     }
   reason = "READY";
   return true;
  }

bool MayPlaceOrder(const string symbol, string &reason)
  {
   if(!g_runtimeAutoTrade)
     {
      reason = "SIGNAL ONLY: AUTO-TRADE button is OFF";
      return false;
     }
   if(!InpEnableOrderExecution)
     {
      reason = "SIGNAL ONLY: execution lock is OFF";
      return false;
     }

   if(InpRequireUsdAccount && AccountInfoString(ACCOUNT_CURRENCY) != "USD")
     {
      reason = "LOCKED: $50 target requires a USD account";
      return false;
     }

   const ENUM_ACCOUNT_TRADE_MODE mode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   if(mode == ACCOUNT_TRADE_MODE_REAL && !InpAllowRealAccount)
     {
      reason = "LOCKED: real account is not authorized";
      return false;
     }

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      reason = "LOCKED: MT5 Algo Trading is disabled";
      return false;
     }

   const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > g_peakEquity)
      g_peakEquity = equity;

   const double drawdownPct = (g_peakEquity > 0.0 ? 100.0 * (g_peakEquity - equity) / g_peakEquity : 0.0);
   if(drawdownPct >= InpMaxEquityDrawdownPct)
     {
      reason = "LOCKED: maximum equity drawdown reached";
      return false;
     }

   const double dailyLossPct = (g_dayStartEquity > 0.0 ?
                                100.0 * (g_dayStartEquity - equity) / g_dayStartEquity : 0.0);
   if(dailyLossPct >= InpMaxDailyLossPercent)
     {
      reason = "LOCKED: daily loss limit reached";
      return false;
     }

   int trades = 0, consecutiveLosses = 0;
   double closedPnl = 0.0;
   ReadTodayStats(trades, consecutiveLosses, closedPnl);
   if(trades >= InpMaxTradesPerDay)
     {
      reason = "LOCKED: daily trade limit reached";
      return false;
     }
   if(CountOurOpenPositions() >= InpMaxOpenPositions)
     {
      reason = "LOCKED: maximum open positions reached";
      return false;
     }
   if(consecutiveLosses >= InpMaxConsecutiveLosses)
     {
      reason = "LOCKED: consecutive-loss limit reached";
      return false;
     }

   const double dailyGainMoney = equity - g_dayStartEquity;
   if(InpStopAtDailyProfitTarget && dailyGainMoney >= InpDailyProfitTargetMoney)
     {
      reason = "LOCKED: daily profit target reached";
      return false;
     }
   if(g_targetHandledDay == g_dayKey)
     {
      reason = "LOCKED: daily target already completed";
      return false;
     }
   if(InpOnePositionPerSymbol && HasOurPosition(symbol))
     {
      reason = "WAIT: position already open for symbol";
      return false;
     }

   reason = "AUTHORIZED";
   return true;
  }

bool IsTradingDayAndHour()
  {
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);
   if(now.day_of_week == 0 || now.day_of_week == 6)
      return false;
   if(now.day_of_week == 1 && !InpTradeMonday) return false;
   if(now.day_of_week == 2 && !InpTradeTuesday) return false;
   if(now.day_of_week == 3 && !InpTradeWednesday) return false;
   if(now.day_of_week == 4 && !InpTradeThursday) return false;
   if(now.day_of_week == 5 && !InpTradeFriday) return false;
   if(InpFridayCloseProtection && now.day_of_week == 5 && now.hour >= InpFridayStopHour)
      return false;
   bool serverSession = true;
   if(InpUseSessionFilter)
     {
      if(InpSessionStartHour < InpSessionEndHour)
         serverSession = now.hour >= InpSessionStartHour && now.hour < InpSessionEndHour;
      else
         serverSession = now.hour >= InpSessionStartHour || now.hour < InpSessionEndHour;
     }

   bool liquidSession = true;
   if(InpUseLiquidSessions)
     {
      MqlDateTime utc;
      TimeToStruct(TimeGMT(), utc);
      const bool asia = InpUseAsiaSession && HourInWindow(utc.hour, InpAsiaStartUtc, InpAsiaEndUtc);
      const bool london = HourInWindow(utc.hour, InpLondonStartUtc, InpLondonEndUtc);
      const bool newYork = HourInWindow(utc.hour, InpNewYorkStartUtc, InpNewYorkEndUtc);
      liquidSession = asia || london || newYork;
     }
   return serverSession && liquidSession;
  }

bool HourInWindow(const int hour, const int startHour, const int endHour)
  {
   if(startHour < endHour) return hour >= startHour && hour < endHour;
   return hour >= startHour || hour < endHour;
  }

bool IsAsiaSession()
  {
   if(!InpUseLiquidSessions || !InpUseAsiaSession) return false;
   MqlDateTime utc;
   TimeToStruct(TimeGMT(), utc);
   return HourInWindow(utc.hour, InpAsiaStartUtc, InpAsiaEndUtc);
  }

string CurrentSessionName()
  {
   MqlDateTime utc;
   TimeToStruct(TimeGMT(), utc);
   const bool asia = InpUseAsiaSession && HourInWindow(utc.hour, InpAsiaStartUtc, InpAsiaEndUtc);
   const bool london = HourInWindow(utc.hour, InpLondonStartUtc, InpLondonEndUtc);
   const bool newYork = HourInWindow(utc.hour, InpNewYorkStartUtc, InpNewYorkEndUtc);
   if(london && newYork) return "LONDON+NY";
   if(newYork) return "NEW YORK";
   if(london) return "LONDON";
   if(asia) return "ASIA";
   return "CLOSED";
  }

void UpdateNewsGuard(const bool force)
  {
   if(!InpUseNewsGuard)
     {
      g_newsAvailable = true;
      g_newsBlocked = false;
      g_newsEventName = "News guard disabled";
      g_newsEventTime = 0;
      return;
     }

   if((bool)MQLInfoInteger(MQL_TESTER))
     {
      g_newsAvailable = false;
      g_newsBlocked = false;
      g_newsEventName = "Tester: calendar unavailable";
      g_newsEventTime = 0;
      return;
     }

   const datetime now = TimeTradeServer();
   if(!force && g_lastNewsRefresh > 0 && (now - g_lastNewsRefresh) < InpNewsRefreshSeconds)
      return;
   g_lastNewsRefresh = now;
   g_newsBlocked = false;
   g_newsAvailable = false;
   g_newsEventName = "No upcoming guarded event";
   g_newsEventTime = 0;

   const datetime fromTime = now - InpNewsMinutesAfter * 60;
   const datetime toTime = now + 24 * 60 * 60;
   string currencies[4] = {"USD", "CNY", "JPY", "AUD"};
   const int currencyCount = (InpGuardAsiaCurrencies ? 4 : 1);
   bool allCalendarsAvailable = true;
   int calendarError = 0;
   datetime nearestFuture = 0;
   string nearestName = "";

   for(int c=0; c<currencyCount; c++)
     {
      MqlCalendarValue values[];
      ResetLastError();
      const int count = CalendarValueHistory(values, fromTime, toTime, "", currencies[c]);
      if(count < 0)
        {
         allCalendarsAvailable = false;
         calendarError = GetLastError();
         continue;
        }

      for(int i=0; i<count; i++)
        {
         MqlCalendarEvent event;
         if(!CalendarEventById(values[i].event_id, event)) continue;
         if(event.importance != CALENDAR_IMPORTANCE_HIGH) continue;

         const datetime eventTime = values[i].time;
         const string eventLabel = currencies[c] + " " + event.name;
         const bool inBeforeWindow = eventTime >= now &&
                                     eventTime <= now + InpNewsMinutesBefore * 60;
         const bool inAfterWindow = eventTime < now &&
                                    eventTime >= now - InpNewsMinutesAfter * 60;
         if(inBeforeWindow || inAfterWindow)
           {
            if(!g_newsBlocked || MathAbs((double)(eventTime - now)) <
                                MathAbs((double)(g_newsEventTime - now)))
              {
               g_newsEventTime = eventTime;
               g_newsEventName = eventLabel;
              }
            g_newsBlocked = true;
           }
         if(eventTime >= now && (nearestFuture == 0 || eventTime < nearestFuture))
           {
            nearestFuture = eventTime;
            nearestName = eventLabel;
           }
        }
     }

   g_newsAvailable = allCalendarsAvailable;
   if(!g_newsBlocked && nearestFuture > 0)
     {
      g_newsEventTime = nearestFuture;
      g_newsEventName = nearestName;
     }

   if(!allCalendarsAvailable)
     {
      const ENUM_ACCOUNT_TRADE_MODE mode =
         (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
      if(mode == ACCOUNT_TRADE_MODE_REAL && InpNewsFailClosedOnReal)
        {
         g_newsBlocked = true;
         g_newsEventTime = 0;
         g_newsEventName = "Calendar unavailable (" + IntegerToString(calendarError) + ")";
        }
     }
  }

bool NewsGuardBlocksTrading(string &reason)
  {
   UpdateNewsGuard(false);
   if(g_newsBlocked)
     {
      reason = "NEWS GUARD: " + g_newsEventName;
      return true;
     }
   if(!g_newsAvailable)
     {
      const ENUM_ACCOUNT_TRADE_MODE mode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
      if(mode == ACCOUNT_TRADE_MODE_REAL && InpNewsFailClosedOnReal)
        {
         reason = "NEWS GUARD: calendar unavailable (fail-closed)";
         return true;
        }
     }
   return false;
  }

string NewsCountdownText()
  {
   if(!InpUseNewsGuard) return "News      OFF";
   if(!g_newsAvailable)
      return "News      " + g_newsEventName;
   if(g_newsEventTime <= 0)
      return "News      no guarded event / 24h";

   string eventName = g_newsEventName;
   if(StringLen(eventName) > 22) eventName = StringSubstr(eventName, 0, 22);
   const int seconds = (int)(g_newsEventTime - TimeTradeServer());
   if(g_newsBlocked)
      return "News      BLOCKED: " + eventName;
   if(seconds <= 0)
      return "News      cooldown: " + eventName;
   const int hours = seconds / 3600;
   const int minutes = (seconds % 3600) / 60;
   return "News      " + eventName + " in " + IntegerToString(hours) + "h " + IntegerToString(minutes) + "m";
  }

bool VolatilityAllowed(const string symbol, const ENUM_TIMEFRAMES tf, string &reason)
  {
   if(!InpUseVolatilityGuard)
     {
      reason = "volatility guard disabled";
      return true;
     }

   const int handle = iATR(symbol, tf, InpAtrPeriod);
   if(handle == INVALID_HANDLE)
     {
      reason = "ATR handle unavailable";
      return false;
     }
   double values[];
   ArrayResize(values, InpAtrAverageBars);
   ArraySetAsSeries(values, true);
   const int copied = CopyBuffer(handle, 0, 1, InpAtrAverageBars, values);
   IndicatorRelease(handle);
   if(copied < InpAtrAverageBars)
     {
      reason = "ATR history not ready";
      return false;
     }

   double average = 0.0;
   for(int i=0; i<copied; i++) average += values[i];
   average /= copied;
   const double currentAtr = values[0];
   if(currentAtr <= 0.0 || average <= 0.0)
     {
      reason = "invalid ATR data";
      return false;
     }

   const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   const double spreadPrice = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * point;
   g_lastAtrRatio = currentAtr / average;
   g_lastSpreadAtr = spreadPrice / currentAtr;
   if(g_lastAtrRatio > InpMaxAtrSpikeRatio)
     {
      reason = "ATR spike " + DoubleToString(g_lastAtrRatio, 2) + "x";
      return false;
     }
   if(g_lastSpreadAtr > InpMaxSpreadToAtrRatio)
     {
      reason = "spread/ATR " + DoubleToString(100.0 * g_lastSpreadAtr, 1) + "%";
      return false;
     }
   reason = "volatility normal";
   return true;
  }

void ManageOpenPositions()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;

      const long magic = PositionGetInteger(POSITION_MAGIC);
      if(!IsOurMagic(magic))
         continue;

      const string symbol = PositionGetString(POSITION_SYMBOL);
      const ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      const double open = PositionGetDouble(POSITION_PRICE_OPEN);
      const double currentSl = PositionGetDouble(POSITION_SL);
      const double currentTp = PositionGetDouble(POSITION_TP);
      MqlTick tick;
      if(!SymbolInfoTick(symbol, tick))
         continue;

      const double price = (type == POSITION_TYPE_BUY ? tick.bid : tick.ask);
      const string positionComment = PositionGetString(POSITION_COMMENT);
      const bool scalpPosition = StringFind(positionComment, "SCALP") >= 0;
      const double configuredRr = (scalpPosition ?
                                   InpScalpTakeAtr / InpScalpStopAtr :
                                   InpIntradayTakeAtr / InpIntradayStopAtr);
      const double targetDistance = MathAbs(currentTp - open);
      const double initialRisk = (currentTp > 0.0 && configuredRr > 0.0 ?
                                  targetDistance / configuredRr :
                                  MathAbs(open - currentSl));
      if(initialRisk <= 0.0)
         continue;

      const double profitDistance = (type == POSITION_TYPE_BUY ? price - open : open - price);
      double newSl = currentSl;

      if(InpUseBreakEven && profitDistance >= initialRisk * InpBreakEvenAtR)
        {
         const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
         const double be = (type == POSITION_TYPE_BUY ?
                            open + InpBreakEvenOffsetPoints * point :
                            open - InpBreakEvenOffsetPoints * point);
         if(type == POSITION_TYPE_BUY && (newSl < be || newSl == 0.0)) newSl = be;
         if(type == POSITION_TYPE_SELL && (newSl > be || newSl == 0.0)) newSl = be;
        }

      if(InpUseAtrTrailing && profitDistance >= initialRisk * InpTrailStartR)
        {
         double atr[3];
         const ENUM_TIMEFRAMES trailTf = (scalpPosition ? ScalpEntryTimeframe() : PERIOD_M15);
         if(ReadATR(symbol, trailTf, atr))
           {
            const double trail = (type == POSITION_TYPE_BUY ?
                                  price - atr[1] * InpTrailAtrMultiplier :
                                  price + atr[1] * InpTrailAtrMultiplier);
            if(type == POSITION_TYPE_BUY && trail > newSl) newSl = trail;
            if(type == POSITION_TYPE_SELL && (trail < newSl || newSl == 0.0)) newSl = trail;
           }
        }

      if(MathAbs(newSl - currentSl) > SymbolInfoDouble(symbol, SYMBOL_POINT))
        {
         const int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         g_trade.SetExpertMagicNumber(magic);
         if(!g_trade.PositionModify(ticket, NormalizeDouble(newSl, digits), currentTp))
            Print(symbol, ": stop update failed: ", g_trade.ResultRetcodeDescription());
        }
     }
  }

double CalculateVolume(const string symbol, const int direction,
                       const double entry, const double sl, string &reason)
  {
   reason = "VOLUME DATA ERROR";
   g_lastVolume = 0.0;
   g_lastRiskMoney = 0.0;
   const double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   const double brokerMaxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   const double maxLot = MathMin(brokerMaxLot, InpMaximumLot);
   const double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(minLot <= 0.0 || maxLot < minLot || lotStep <= 0.0)
     {
      reason = "INVALID BROKER LOT SPEC";
      return 0.0;
     }
   if(entry <= 0.0 || sl <= 0.0 || MathAbs(entry - sl) <= 0.0)
     {
      reason = "INVALID ENTRY/SL";
      return 0.0;
     }

   const ENUM_ORDER_TYPE orderType = (direction > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   g_lastRiskFactor = CombinedRiskFactor();
   double rawVolume = InpFixedLot * g_lastRiskFactor;
   double riskBudget = 0.0;
   if(InpRiskMode == RISK_PERCENT)
     {
      const double referenceVolume = MathMax(minLot, MathMin(1.0, brokerMaxLot));
      double lossReference = 0.0;
      ResetLastError();
      if(!OrderCalcProfit(orderType, symbol, referenceVolume, entry, sl, lossReference))
        {
         reason = "RISK CALC ERROR " + IntegerToString(GetLastError());
         return 0.0;
        }
      lossReference = MathAbs(lossReference);
      if(lossReference <= 0.0)
        {
         reason = "INVALID BROKER RISK VALUE";
         return 0.0;
        }
      riskBudget = AccountInfoDouble(ACCOUNT_EQUITY) *
                   InpRiskPerTradePercent / 100.0 * g_lastRiskFactor;
      rawVolume = riskBudget * referenceVolume / lossReference;
     }

   if(rawVolume <= 0.0)
     {
      reason = "NON-POSITIVE LOT";
      return 0.0;
     }

   bool minLotApplied = false;
   const ENUM_ACCOUNT_TRADE_MODE accountMode =
      (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   const bool demoMinAllowed = InpDemoMinLotMode && accountMode != ACCOUNT_TRADE_MODE_REAL;
   if(rawVolume < minLot)
     {
      if(!demoMinAllowed && !InpAllowMinLotRiskOverride)
        {
         reason = "LOT<MIN " + DoubleToString(rawVolume, 4) + "/" +
                  DoubleToString(minLot, 2);
         return 0.0;
        }
      rawVolume = minLot;
      minLotApplied = true;
     }

   const bool maximumApplied = rawVolume > maxLot;
   double volume = MathMin(rawVolume, maxLot);
   volume = MathFloor((volume + 1e-12) / lotStep) * lotStep;
   if(volume < minLot)
     {
      reason = "LOT STEP BELOW MIN";
      return 0.0;
     }
   const int volumeDigits = (lotStep >= 1.0 ? 0 : lotStep >= 0.1 ? 1 : lotStep >= 0.01 ? 2 : 3);
   volume = NormalizeDouble(volume, volumeDigits);

   double estimatedPnl = 0.0;
   if(!OrderCalcProfit(orderType, symbol, volume, entry, sl, estimatedPnl))
     {
      reason = "FINAL RISK CALC ERROR " + IntegerToString(GetLastError());
      return 0.0;
     }
   g_lastVolume = volume;
   g_lastRiskMoney = MathAbs(estimatedPnl);
   reason = (minLotApplied ? "DEMO MIN " : maximumApplied ? "MAX CAP " : "LOT ") +
            DoubleToString(volume, volumeDigits) + " risk $" +
            DoubleToString(g_lastRiskMoney, 2);
   if(InpRiskMode == RISK_PERCENT && riskBudget > 0.0)
      reason += "/$" + DoubleToString(riskBudget, 2);
   return volume;
  }

double AdaptiveRiskFactor()
  {
   if(!InpUseAdaptiveLossGuard) return 1.0;
   int trades = 0, losses = 0;
   double pnl = 0.0;
   ReadTodayStats(trades, losses, pnl);
   if(losses >= 2) return InpRiskAfterTwoLosses;
   if(losses == 1) return InpRiskAfterOneLoss;
   return 1.0;
  }

double CombinedRiskFactor()
  {
   const double sessionFactor = (IsAsiaSession() ? InpAsiaRiskFactor : 1.0);
   return MathMin(1.0, AdaptiveRiskFactor() * sessionFactor);
  }

bool RespectStopLevel(const string symbol,
                      const double entry,
                      const int direction,
                      double &sl,
                      double &tp)
  {
   const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   const int stopLevel = (int)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const double minimum = MathMax(stopLevel * point, 2.0 * point);
   if(direction > 0)
     {
      if(entry - sl < minimum) sl = entry - minimum;
      if(tp - entry < minimum) tp = entry + minimum;
     }
   else
     {
      if(sl - entry < minimum) sl = entry + minimum;
      if(entry - tp < minimum) tp = entry - minimum;
     }
   return sl > 0.0 && tp > 0.0;
  }

bool HasOurPosition(const string symbol)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) == symbol &&
         IsOurMagic(PositionGetInteger(POSITION_MAGIC)))
         return true;
     }
   return false;
  }

int CountOurOpenPositions()
  {
   int count = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(IsOurMagic(PositionGetInteger(POSITION_MAGIC))) count++;
     }
   return count;
  }

bool IsMetalSymbol(const string symbol)
  {
   string upper = symbol;
   StringToUpper(upper);
   return IsGoldSymbol(upper) || StringFind(upper, "XAG") >= 0 ||
          StringFind(upper, "SILVER") >= 0;
  }

bool IsGoldSymbol(const string symbol)
  {
   string upper = symbol;
   StringToUpper(upper);
   return StringFind(upper, "XAU") >= 0 || StringFind(upper, "GOLD") >= 0;
  }

int MaxSpreadForSymbol(const string symbol)
  {
   return (IsMetalSymbol(symbol) ? InpMaxMetalSpreadPoints : InpMaxForexSpreadPoints);
  }

bool CanTradeDirection(const string symbol, const int direction, string &reason)
  {
   const ENUM_SYMBOL_TRADE_MODE mode = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE);
   if(mode == SYMBOL_TRADE_MODE_DISABLED || mode == SYMBOL_TRADE_MODE_CLOSEONLY)
     {
      reason = "symbol is not open for new trades";
      return false;
     }
   if(direction > 0 && mode == SYMBOL_TRADE_MODE_SHORTONLY)
     {
      reason = "symbol is short-only";
      return false;
     }
   if(direction < 0 && mode == SYMBOL_TRADE_MODE_LONGONLY)
     {
      reason = "symbol is long-only";
      return false;
     }
   reason = "trade direction allowed";
   return true;
  }

bool HasMarginCapacity(const string symbol, const int direction, const double volume,
                       const double price, string &reason)
  {
   const ENUM_ORDER_TYPE type = (direction > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   double requiredMargin = 0.0;
   if(!OrderCalcMargin(type, symbol, volume, price, requiredMargin))
     {
      reason = "margin calculation failed";
      return false;
     }
   const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   const double remainingFree = AccountInfoDouble(ACCOUNT_MARGIN_FREE) - requiredMargin;
   const double minimumFree = equity * InpMinFreeMarginPercent / 100.0;
   if(remainingFree < minimumFree)
     {
      reason = "free-margin reserve would be too low";
      return false;
     }
   reason = "margin capacity passed";
   return true;
  }

ENUM_ORDER_TYPE_FILLING FillingModeForSymbol(const string symbol)
  {
   const long flags = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
   if((flags & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC) return ORDER_FILLING_IOC;
   if((flags & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK) return ORDER_FILLING_FOK;
   return ORDER_FILLING_RETURN;
  }

bool PreflightOrder(const string symbol, const int direction, const double volume,
                    const double price, const double sl, const double tp,
                    const long magic, const string comment, string &reason)
  {
   MqlTradeRequest request = {};
   MqlTradeCheckResult check = {};
   request.action = TRADE_ACTION_DEAL;
   request.magic = (ulong)magic;
   request.symbol = symbol;
   request.volume = volume;
   request.type = (direction > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = (ulong)InpMaxSlippagePoints;
   request.type_filling = FillingModeForSymbol(symbol);
   request.type_time = ORDER_TIME_GTC;
   request.comment = comment;

   ResetLastError();
   if(!OrderCheck(request, check))
     {
      reason = "OrderCheck failed " + IntegerToString(GetLastError()) + ": " + check.comment;
      return false;
     }
   if(check.retcode != 0 && check.retcode != TRADE_RETCODE_DONE && check.retcode != TRADE_RETCODE_PLACED)
     {
      reason = "server check " + IntegerToString((long)check.retcode) + ": " + check.comment;
      return false;
     }
   reason = "OrderCheck passed";
   return true;
  }

long MagicFor(const int symbolIndex, const ENUM_SEVENZ_PROFILE profile)
  {
   return InpMagicBase + symbolIndex * 10 + (profile == PROFILE_SCALPING ? 1 : 2);
  }

bool IsOurMagic(const long magic)
  {
   return magic >= InpMagicBase && magic < InpMagicBase + 1000;
  }

void RefreshDailyState()
  {
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);
   const int key = now.year * 10000 + now.mon * 100 + now.day;
   if(key != g_dayKey)
      ResetDailyState();
   const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > g_peakEquity)
     {
      g_peakEquity = equity;
      GlobalVariableSet(SafetyKey("PEAK"), g_peakEquity);
     }
  }

void ResetDailyState()
  {
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);
   g_dayKey = now.year * 10000 + now.mon * 100 + now.day;
   g_targetHandledDay = -1;
   g_peakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   int trades = 0, losses = 0;
   double closedPnl = 0.0;
   ReadTodayStats(trades, losses, closedPnl);
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY) - closedPnl;
   if(g_dayStartEquity <= 0.0)
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   PersistSafetyState();
  }

string SafetyKey(const string suffix)
  {
   return "SEVENZ_" + IntegerToString((long)AccountInfoInteger(ACCOUNT_LOGIN)) + "_" +
          IntegerToString(InpMagicBase) + "_" + suffix;
  }

void LoadSafetyState()
  {
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);
   const int todayKey = now.year * 10000 + now.mon * 100 + now.day;
   const bool sameDay = GlobalVariableCheck(SafetyKey("DAY")) &&
                        (int)GlobalVariableGet(SafetyKey("DAY")) == todayKey;
   if(sameDay && GlobalVariableCheck(SafetyKey("BASE")))
     {
      g_dayKey = todayKey;
      g_dayStartEquity = GlobalVariableGet(SafetyKey("BASE"));
      if(GlobalVariableCheck(SafetyKey("PEAK")))
         g_peakEquity = MathMax(g_peakEquity, GlobalVariableGet(SafetyKey("PEAK")));
      if(GlobalVariableCheck(SafetyKey("TARGET")) &&
         (int)GlobalVariableGet(SafetyKey("TARGET")) == todayKey)
         g_targetHandledDay = todayKey;
     }
   else
      ResetDailyState();
   PersistSafetyState();
  }

void PersistSafetyState()
  {
   GlobalVariableSet(SafetyKey("DAY"), (double)g_dayKey);
   GlobalVariableSet(SafetyKey("BASE"), g_dayStartEquity);
   GlobalVariableSet(SafetyKey("PEAK"), g_peakEquity);
   GlobalVariableSet(SafetyKey("TARGET"), (double)g_targetHandledDay);
  }

void EnforceDailyProfitTarget()
  {
   if(!InpStopAtDailyProfitTarget || g_dayStartEquity <= 0.0) return;
   if(g_targetHandledDay == g_dayKey)
     {
      g_runtimeAutoTrade = false;
      if(InpCloseAtDailyTarget && CountOurOpenPositions() > 0)
         CloseAllSevenzPositions();
      return;
     }

   int trades = 0, losses = 0;
   double realizedPnl = 0.0;
   ReadTodayStats(trades, losses, realizedPnl);
   const double dayEquityProfit = AccountInfoDouble(ACCOUNT_EQUITY) - g_dayStartEquity;
   const bool realizedReached = realizedPnl >= InpDailyProfitTargetMoney;
   const bool bufferedEquityReached = CountOurOpenPositions() > 0 &&
                                      dayEquityProfit >= InpDailyProfitTargetMoney + InpTargetCloseBufferMoney;
   if(!realizedReached && !bufferedEquityReached) return;

   g_runtimeAutoTrade = false;
   g_targetHandledDay = g_dayKey;
   PersistSafetyState();
   if(bufferedEquityReached && InpCloseAtDailyTarget)
      CloseAllSevenzPositions();
   g_status = "TARGET LOCKED: realized " + SignedMoney(realizedPnl) +
              " / " + DoubleToString(InpDailyProfitTargetMoney, 2);
  }

bool ValidateInputs()
  {
   const bool valid =
      InpTimerSeconds >= 1 &&
      InpMagicBase >= 1 &&
      InpMaxTradesPerDay >= 1 &&
      InpMaxOpenPositions >= 1 &&
      InpMaxConsecutiveLosses >= 1 &&
      InpMaxDailyLossPercent > 0.0 &&
      InpMaxEquityDrawdownPct > 0.0 &&
      InpTargetCloseBufferMoney >= 0.0 &&
      InpCooldownMinutes >= 0 &&
      InpMaxForexSpreadPoints > 0 && InpMaxMetalSpreadPoints > 0 &&
      InpFixedLot > 0.0 &&
      InpRiskPerTradePercent > 0.0 && InpRiskPerTradePercent <= 5.0 &&
      InpMaximumLot > 0.0 &&
      InpMinFreeMarginPercent >= 0.0 && InpMinFreeMarginPercent < 100.0 &&
      InpRiskAfterOneLoss > 0.0 && InpRiskAfterOneLoss <= 1.0 &&
      InpRiskAfterTwoLosses > 0.0 && InpRiskAfterTwoLosses <= InpRiskAfterOneLoss &&
      InpAsiaStartUtc >= 0 && InpAsiaStartUtc <= 23 &&
      InpAsiaEndUtc >= 0 && InpAsiaEndUtc <= 23 &&
      InpAsiaRiskFactor > 0.0 && InpAsiaRiskFactor <= 1.0 &&
      InpAsiaQualityBonus >= 0 && InpAsiaQualityBonus <= 20 &&
      InpLondonStartUtc >= 0 && InpLondonStartUtc <= 23 &&
      InpLondonEndUtc >= 0 && InpLondonEndUtc <= 23 &&
      InpNewYorkStartUtc >= 0 && InpNewYorkStartUtc <= 23 &&
      InpNewYorkEndUtc >= 0 && InpNewYorkEndUtc <= 23 &&
      InpNewsMinutesBefore >= 0 && InpNewsMinutesAfter >= 0 &&
      InpNewsRefreshSeconds >= 10 &&
      InpAtrAverageBars >= 10 && InpMaxAtrSpikeRatio > 1.0 &&
      InpMaxSpreadToAtrRatio > 0.0 && InpMaxSpreadToAtrRatio < 1.0 &&
      InpQualityThreshold >= 0 && InpQualityThreshold <= 100 &&
      InpDailyProfitTargetMoney > 0.0 &&
      InpFastEmaPeriod > 1 && InpSlowEmaPeriod > InpFastEmaPeriod &&
      InpConfirmEmaPeriod > InpSlowEmaPeriod &&
      InpTrendAdxThreshold > 0.0 && InpRangeAdxCeiling > 0.0 &&
      InpRangeAdxCeiling < InpTrendAdxThreshold &&
      InpMinConfluenceVotes >= 1 && InpMinConfluenceVotes <= 9 &&
      InpMinDirectionalEdge >= 0 && InpMinDirectionalEdge <= 50 &&
      InpMacdFastPeriod > 1 && InpMacdSlowPeriod > InpMacdFastPeriod &&
      InpMacdSignalPeriod > 1 &&
      InpMinCandleBodyAtr >= 0.0 && InpMinCandleBodyAtr < 1.0 &&
      InpMaxEntryDistanceAtr > 0.0 &&
      InpAtrPeriod > 1 &&
      InpScalpStopAtr > 0.0 && InpScalpTakeAtr > 0.0 &&
      InpIntradayStopAtr > 0.0 && InpIntradayTakeAtr > 0.0;
   if(!valid)
      Print("SevenzEA: invalid input configuration. Review risk, periods and safety limits.");
   return valid;
  }

datetime StartOfServerDay()
  {
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);
   now.hour = 0; now.min = 0; now.sec = 0;
   return StructToTime(now);
  }

void ReadTodayStats(int &trades, int &consecutiveLosses, double &closedPnl)
  {
   trades = 0; consecutiveLosses = 0; closedPnl = 0.0;
   if(!HistorySelect(StartOfServerDay(), TimeCurrent())) return;

   const int total = HistoryDealsTotal();
   for(int i=0; i<total; i++)
     {
      const ulong deal = HistoryDealGetTicket(i);
      if(deal == 0 || !IsOurMagic(HistoryDealGetInteger(deal, DEAL_MAGIC))) continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      trades++;
      closedPnl += HistoryDealGetDouble(deal, DEAL_PROFIT) +
                   HistoryDealGetDouble(deal, DEAL_SWAP) +
                   HistoryDealGetDouble(deal, DEAL_COMMISSION);
     }

   for(int i=total-1; i>=0; i--)
     {
      const ulong deal = HistoryDealGetTicket(i);
      if(deal == 0 || !IsOurMagic(HistoryDealGetInteger(deal, DEAL_MAGIC))) continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      const double pnl = HistoryDealGetDouble(deal, DEAL_PROFIT) +
                         HistoryDealGetDouble(deal, DEAL_SWAP) +
                         HistoryDealGetDouble(deal, DEAL_COMMISSION);
      if(pnl < 0.0) consecutiveLosses++;
      else break;
     }
  }

bool CopyIndicatorBuffer(const int handle, const int buffer, double &values[])
  {
   if(handle == INVALID_HANDLE) return false;
   ArraySetAsSeries(values, true);
   const bool ok = CopyBuffer(handle, buffer, 0, 3, values) == 3;
   IndicatorRelease(handle);
   return ok;
  }

bool ReadMA(const string symbol, const ENUM_TIMEFRAMES tf, const int period, double &values[])
  {
   return CopyIndicatorBuffer(iMA(symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE), 0, values);
  }

bool ReadRSI(const string symbol, const ENUM_TIMEFRAMES tf, double &values[])
  {
   return CopyIndicatorBuffer(iRSI(symbol, tf, InpRsiPeriod, PRICE_CLOSE), 0, values);
  }

bool ReadATR(const string symbol, const ENUM_TIMEFRAMES tf, double &values[])
  {
   return CopyIndicatorBuffer(iATR(symbol, tf, InpAtrPeriod), 0, values);
  }

bool ReadMACD(const string symbol, const ENUM_TIMEFRAMES tf,
              double &mainLine[], double &signalLine[])
  {
   const int handle = iMACD(symbol, tf, InpMacdFastPeriod, InpMacdSlowPeriod,
                            InpMacdSignalPeriod, PRICE_CLOSE);
   if(handle == INVALID_HANDLE) return false;
   ArraySetAsSeries(mainLine, true);
   ArraySetAsSeries(signalLine, true);
   const bool ok = CopyBuffer(handle, 0, 0, 3, mainLine) == 3 &&
                   CopyBuffer(handle, 1, 0, 3, signalLine) == 3;
   IndicatorRelease(handle);
   return ok;
  }

bool ReadADX(const string symbol, const ENUM_TIMEFRAMES tf,
             double &adx[], double &plusDi[], double &minusDi[])
  {
   const int handle = iADX(symbol, tf, InpAdxPeriod);
   if(handle == INVALID_HANDLE) return false;
   ArraySetAsSeries(adx, true);
   ArraySetAsSeries(plusDi, true);
   ArraySetAsSeries(minusDi, true);
   const bool ok = CopyBuffer(handle, 0, 0, 3, adx) == 3 &&
                   CopyBuffer(handle, 1, 0, 3, plusDi) == 3 &&
                   CopyBuffer(handle, 2, 0, 3, minusDi) == 3;
   IndicatorRelease(handle);
   return ok;
  }

bool ReadBands(const string symbol, const ENUM_TIMEFRAMES tf,
               double &base[], double &upper[], double &lower[])
  {
   const int handle = iBands(symbol, tf, InpBandsPeriod, 0, InpBandsDeviation, PRICE_CLOSE);
   if(handle == INVALID_HANDLE) return false;
   ArraySetAsSeries(base, true);
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   const bool ok = CopyBuffer(handle, 0, 0, 3, base) == 3 &&
                   CopyBuffer(handle, 1, 0, 3, upper) == 3 &&
                   CopyBuffer(handle, 2, 0, 3, lower) == 3;
   IndicatorRelease(handle);
   return ok;
  }

void UpdateChartStatus()
  {
   int trades = 0, losses = 0;
   double pnl = 0.0;
   ReadTodayStats(trades, losses, pnl);
   const string accountMode =
      ((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL ? "REAL" : "DEMO/CONTEST");
   Comment("SEVENZ EA v1.42 XAUUSD ACTIVE EXECUTION\n",
           "Account: ", accountMode, " | Execution: ", (InpEnableOrderExecution ? "ON" : "SIGNAL ONLY"), "\n",
           "Status: ", g_status, "\n",
           "Symbols: ", InpSymbols, "\n",
           "Today: ", trades, " trades | P/L ", DoubleToString(pnl, 2), " | Loss streak ", losses);
   UpdateControlPanel();
  }

void CreateControlPanel()
  {
   if(!InpShowControlPanel) return;

   PanelRect("BG", 0, 0, InpPanelWidth, 470, C'15,20,31', C'53,63,82');
   PanelLabel("TITLE", 12, 10, "SEVENZ EA v1.42 | ACTIVE EXEC", clrGold, 10);
   PanelLabel("LINE1", 12, 38, "Initializing market data...", clrSilver, 9);
   PanelLabel("LINE2", 12, 58, "ADX", clrSilver, 9);
   PanelLabel("LINE3", 12, 78, "RSI", clrSilver, 9);
   PanelLabel("LINE4", 12, 98, "ATR", clrSilver, 9);
   PanelLabel("LINE5", 12, 118, "Spread", clrSilver, 9);
   PanelLabel("LINE6", 12, 138, "Session", clrSilver, 9);
   PanelLabel("LINE7", 12, 158, "Day P&L", clrSilver, 9);
   PanelLabel("LINE8", 12, 178, "Open", clrSilver, 9);
   PanelLabel("LINE9", 12, 198, "Balance", clrSilver, 9);
   PanelLabel("LINE10", 12, 218, "Target", clrSilver, 9);
   PanelLabel("LINE11", 12, 238, "Stats", clrSilver, 9);
   PanelLabel("LINE12", 12, 258, "News", clrSilver, 9);
   PanelLabel("LINE13", 12, 278, "Trade event", clrSilver, 9);
   PanelLabel("LINE14", 12, 298, "Status", clrSilver, 9);
   PanelLabel("LINE15", 12, 318, "Execution", clrSilver, 9);

   const int buttonWidth = (InpPanelWidth - 34) / 2;
   PanelButton("BTN_PAUSE", 10, 350, buttonWidth, 26, "PAUSE", C'66,78,105');
   PanelButton("BTN_SCALP", 20 + buttonWidth, 350, buttonWidth, 26, "SCALP: ON", C'43,110,85');
   PanelButton("BTN_AUTO", 10, 384, buttonWidth, 26, "AUTO-TRADE: OFF", C'45,85,125');
   PanelButton("BTN_QUALITY", 20 + buttonWidth, 384, buttonWidth, 26, "QUALITY: ON", C'105,63,128');
   PanelButton("BTN_CLOSE", 10, 418, buttonWidth, 26, "CLOSE ALL", C'140,55,55');
   PanelButton("BTN_RESET", 20 + buttonWidth, 418, buttonWidth, 26, "RESET DAY", C'75,75,96');
   ChartRedraw(0);
  }

void UpdateControlPanel()
  {
   if(!InpShowControlPanel) return;

   const string symbol = PanelSymbol();
   double adx[3], plusDi[3], minusDi[3], rsi[3], atr[3];
   SignalResult scalpSignal, intradaySignal;
   double adxValue = 0.0, rsiValue = 0.0, atrPoints = 0.0;
   const ENUM_TIMEFRAMES scalpEntryTf = ScalpEntryTimeframe();
   const ENUM_TIMEFRAMES scalpConfirmTf = ScalpConfirmTimeframe();
   const bool scalpEnabled = g_runtimeScalp &&
                             (InpProfile == PROFILE_SCALPING || InpProfile == PROFILE_BOTH);
   const bool intradayEnabled = InpProfile == PROFILE_INTRADAY || InpProfile == PROFILE_BOTH;
   const bool scalpReady = scalpEnabled &&
                           BuildSignal(symbol, scalpEntryTf, scalpConfirmTf, scalpSignal);
   const bool intradayReady = intradayEnabled &&
                              BuildSignal(symbol, PERIOD_M15, PERIOD_H1, intradaySignal);
   const bool marketReady = ReadADX(symbol, scalpConfirmTf, adx, plusDi, minusDi) &&
                            ReadRSI(symbol, scalpEntryTf, rsi) &&
                            ReadATR(symbol, scalpEntryTf, atr);

   if(marketReady)
     {
      adxValue = adx[1]; rsiValue = rsi[1];
      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      atrPoints = (point > 0.0 ? atr[1] / point : 0.0);
     }

   int trades = 0, losses = 0;
   double pnl = 0.0;
   ReadTodayStats(trades, losses, pnl);
   int wins = 0;
   double grossProfit = 0.0, grossLoss = 0.0, averagePnl = 0.0;
   ReadPerformanceStats(wins, grossProfit, grossLoss, averagePnl);
   int openCount = 0;
   double openPnl = 0.0;
   ReadOpenStats(openCount, openPnl);
   const int spread = (int)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   const int maxSpread = MaxSpreadForSymbol(symbol);
   const bool activeSession = IsTradingDayAndHour();
   g_lastRiskFactor = CombinedRiskFactor();
   const int requiredQuality = (int)MathMin(100.0, (double)(InpQualityThreshold +
                                            (IsAsiaSession() ? InpAsiaQualityBonus : 0)));
   const string scalpLabel = (InpUseM1ActiveScalp ? "M1SCALP" : "M5SCALP");
   const string scalpLine = (scalpEnabled ? ProfilePanelSummary(scalpLabel, scalpSignal, scalpReady) : scalpLabel + " OFF");
   const string intradayLine = (intradayEnabled ? ProfilePanelSummary("INTRA", intradaySignal, intradayReady) : "INTRA     OFF");
   const string scalpGate = (scalpEnabled ? ProfileGateCode(scalpSignal, scalpReady, requiredQuality) : "OFF");
   const string intradayGate = (intradayEnabled ? ProfileGateCode(intradaySignal, intradayReady, requiredQuality) : "OFF");

   PanelSet("LINE1", scalpLine, ProfilePanelColor(scalpSignal, scalpReady));
   PanelSet("LINE2", intradayLine, ProfilePanelColor(intradaySignal, intradayReady));
   PanelSet("LINE3", "ADX/RSI   " + DoubleToString(adxValue, 1) + " / " + DoubleToString(rsiValue, 1), clrLightSteelBlue);
   PanelSet("LINE4", (InpUseM1ActiveScalp ? "ATR(M1)   " : "ATR(M5)   ") + DoubleToString(atrPoints, 1) + " pts  spike " + DoubleToString(g_lastAtrRatio, 2) + "x", g_lastAtrRatio <= InpMaxAtrSpikeRatio ? clrMediumSeaGreen : clrTomato);
   PanelSet("LINE5", "Spread    " + IntegerToString(spread) + " pts  (max " + IntegerToString(maxSpread) + ")",
            spread <= maxSpread ? clrMediumSeaGreen : clrTomato);
   PanelSet("LINE6", "Session   " + CurrentSessionName() +
            (IsAsiaSession() ? "  risk x" + DoubleToString(InpAsiaRiskFactor, 2) : ""),
            activeSession ? clrMediumSeaGreen : clrTomato);
   PanelSet("LINE7", "Day P&L   " + SignedMoney(pnl) + "   Trades " + IntegerToString(trades) + "/" + IntegerToString(InpMaxTradesPerDay), pnl >= 0 ? clrMediumSeaGreen : clrTomato);
   PanelSet("LINE8", "Open      " + IntegerToString(openCount) + " position(s)   PnL " + SignedMoney(openPnl), clrWhiteSmoke);
   PanelSet("LINE9", "Balance   " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "   Equity " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2), clrWhiteSmoke);
   const double targetMoney = InpDailyProfitTargetMoney;
   const double dayEquityPnl = AccountInfoDouble(ACCOUNT_EQUITY) - g_dayStartEquity;
   const double targetProgress = (targetMoney > 0.0 ? 100.0 * dayEquityPnl / targetMoney : 0.0);
   const double winRate = (trades > 0 ? 100.0 * wins / trades : 0.0);
   const double profitFactor = (grossLoss > 0.0 ? grossProfit / grossLoss : (grossProfit > 0.0 ? 99.0 : 0.0));
   PanelSet("LINE10", "Target    R " + SignedMoney(pnl) + "  E " + SignedMoney(dayEquityPnl) + " / +" + DoubleToString(targetMoney, 0) + "  (" + DoubleToString(targetProgress, 0) + "%)", clrGold);
   PanelSet("LINE11", "Stats     WR " + DoubleToString(winRate, 1) + "% PF " + DoubleToString(profitFactor, 2) + " Risk x" + DoubleToString(g_lastRiskFactor, 2), clrGoldenrod);
   PanelSet("LINE12", ShortPanelText(NewsCountdownText(), 43), g_newsBlocked ? clrTomato : clrMediumSeaGreen);
   PanelSet("LINE13", "Gate      S:" + scalpGate + "  I:" + intradayGate,
            (scalpGate == "PASS" || intradayGate == "PASS") ? clrMediumSeaGreen : clrLightSteelBlue);
   PanelSet("LINE14", "Status    " + ShortPanelText(g_status, 34), clrMediumSeaGreen);
   const bool executionBlocked = StringFind(g_lastVolumeReason, "ERROR") >= 0 ||
                                 StringFind(g_lastVolumeReason, "LOT<MIN") >= 0 ||
                                 StringFind(g_lastVolumeReason, "blocked") >= 0;
   PanelSet("LINE15", "Exec      " + ShortPanelText(g_lastVolumeReason, 34),
            executionBlocked ? clrTomato : clrMediumSeaGreen);

   PanelButtonText("BTN_PAUSE", g_runtimePaused ? "RESUME" : "PAUSE", g_runtimePaused ? C'165,105,38' : C'66,78,105');
   PanelButtonText("BTN_SCALP", string("SCALP: ") + (g_runtimeScalp ? "ON" : "OFF"), g_runtimeScalp ? C'43,110,85' : C'75,75,96');
   PanelButtonText("BTN_AUTO", string("AUTO-TRADE: ") + (g_runtimeAutoTrade ? "ON" : "OFF"), g_runtimeAutoTrade ? C'43,110,85' : C'45,85,125');
   PanelButtonText("BTN_QUALITY", string("QUALITY: ") + (g_runtimeQuality ? "ON" : "OFF"), g_runtimeQuality ? C'105,63,128' : C'75,75,96');
   PanelButtonText("BTN_CLOSE", TimeCurrent() <= g_closeArmUntil ? "CONFIRM CLOSE" : "CLOSE ALL", TimeCurrent() <= g_closeArmUntil ? C'190,85,40' : C'140,55,55');
   ChartRedraw(0);
  }

string ProfilePanelSummary(const string label, const SignalResult &signal, const bool ready)
  {
   if(!ready) return label + "     DATA WAIT";
   string bias = "WAIT";
   if(signal.direction > 0) bias = "BUY";
   else if(signal.direction < 0) bias = "SELL";
   else if(signal.long_score >= signal.short_score + InpMinDirectionalEdge) bias = "WATCH BUY";
   else if(signal.short_score >= signal.long_score + InpMinDirectionalEdge) bias = "WATCH SELL";
   return label + " " + bias + " Q" + IntegerToString(signal.quality) +
          " V" + IntegerToString(signal.votes) + "/" + IntegerToString(InpMinConfluenceVotes) +
          " " + signal.regime;
  }

string ProfileGateCode(const SignalResult &signal, const bool ready, const int requiredQuality)
  {
   if(!ready) return "DATA";
   if(signal.direction == 0)
     {
      if(StringFind(signal.veto, "Transition") >= 0) return "TRANS";
      if(StringFind(signal.veto, "Higher-timeframe") >= 0) return "HTF";
      if(StringFind(signal.veto, "Directional") >= 0) return "EDGE";
      return "WAIT";
     }
   if(InpUseConfluenceEngine && signal.votes < InpMinConfluenceVotes)
      return "V" + IntegerToString(signal.votes) + "/" + IntegerToString(InpMinConfluenceVotes);
   if(g_runtimeQuality && signal.quality < requiredQuality)
      return "Q" + IntegerToString(signal.quality) + "/" + IntegerToString(requiredQuality);
   return "PASS";
  }

color ProfilePanelColor(const SignalResult &signal, const bool ready)
  {
   if(!ready) return clrSilver;
   if(signal.direction > 0) return clrLimeGreen;
   if(signal.direction < 0) return clrTomato;
   if(signal.regime == "TRANSITION") return clrOrangeRed;
   return clrGold;
  }

string PanelSymbol()
  {
   for(int i=0; i<ArraySize(g_states); i++)
      if(g_states[i].symbol == _Symbol) return _Symbol;
   return (ArraySize(g_states) > 0 ? g_states[0].symbol : _Symbol);
  }

string ShortPanelText(const string value, const int maxLength)
  {
   if(StringLen(value) <= maxLength) return value;
   return StringSubstr(value, 0, maxLength - 3) + "...";
  }

void ReadOpenStats(int &count, double &pnl)
  {
   count = 0; pnl = 0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(!IsOurMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      count++;
      pnl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
  }

void ReadPerformanceStats(int &wins, double &grossProfit, double &grossLoss, double &averagePnl)
  {
   wins = 0; grossProfit = 0.0; grossLoss = 0.0; averagePnl = 0.0;
   if(!HistorySelect(StartOfServerDay(), TimeCurrent())) return;
   int count = 0;
   const int total = HistoryDealsTotal();
   for(int i=0; i<total; i++)
     {
      const ulong deal = HistoryDealGetTicket(i);
      if(deal == 0 || !IsOurMagic(HistoryDealGetInteger(deal, DEAL_MAGIC))) continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      const double pnl = HistoryDealGetDouble(deal, DEAL_PROFIT) +
                         HistoryDealGetDouble(deal, DEAL_SWAP) +
                         HistoryDealGetDouble(deal, DEAL_COMMISSION);
      count++;
      averagePnl += pnl;
      if(pnl > 0.0) { wins++; grossProfit += pnl; }
      else if(pnl < 0.0) grossLoss += MathAbs(pnl);
     }
   if(count > 0) averagePnl /= count;
  }

void CloseAllSevenzPositions()
  {
   int closed = 0, failed = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(!IsOurMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      if(g_trade.PositionClose(ticket)) closed++;
      else failed++;
     }
   g_status = "CLOSE ALL: " + IntegerToString(closed) + " closed, " + IntegerToString(failed) + " failed";
  }

string SignedMoney(const double value)
  {
   return (value >= 0.0 ? "+" : "") + DoubleToString(value, 2);
  }

void PanelRect(const string id, const int x, const int y, const int width, const int height,
               const color bg, const color border)
  {
   const string name = PANEL_PREFIX + id;
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX + x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY + y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void PanelLabel(const string id, const int x, const int y, const string text,
                const color textColor, const int fontSize)
  {
   const string name = PANEL_PREFIX + id;
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX + x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY + y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void PanelSet(const string id, const string text, const color textColor)
  {
   const string name = PANEL_PREFIX + id;
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
  }

void PanelButton(const string id, const int x, const int y, const int width, const int height,
                 const string text, const color bg)
  {
   const string name = PANEL_PREFIX + id;
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX + x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY + y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'95,105,125');
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void PanelButtonText(const string id, const string text, const color bg)
  {
   const string name = PANEL_PREFIX + id;
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
  }
