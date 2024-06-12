//+------------------------------------------------------------------+
//|                                                         Edge.mq5 |
//|                                    Copyright 2024, Kieran Green. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kieran Green"
#property link      "info.shoguntrading@gmail.com"
#property version   "1.00"

//+------------------------------------------------------------------+ 
//| Chart Properties                                                 | 
//+------------------------------------------------------------------+ 
bool ChartSetBackColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the chart background color 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartSetForeColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of axes, scale and OHLC line 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_FOREGROUND,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartSetGridColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set chart grid color 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_GRID,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }  
   return(true); 
}

bool ChartSetUpColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of up bar, its shadow and border of body of a bullish candlestick 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }  
   return(true); 
}

bool ChartSetDownColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of down bar, its shadow and border of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartSetBullColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bullish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BULL,clr)){ 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartSetBearColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }
   return(true); 
}

bool ChartSetVolumesColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_VOLUME,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }
   return(true); 
}

bool ChartSetAskLineColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_ASK,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }
   return(true); 
}
bool ChartSetBidLineColor(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_BID,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }
   return(true); 
}


//+------------------------------------------------------------------+
//| Includes and Enumerations                                                                  
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;
#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;
#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;
#include <Arrays\ArrayString.mqh>
CArrayString arrayString;
#include <Object.mqh>
CObject object;
#include <Arrays\Array.mqh>
#include <KG/FFCalendarDownload.mqh>



enum colorScheme
  {
   ENUM_DARK,     //Dark
   ENUM_MIDNIGHT, //Midnight
   ENUM_LIGHT     //Light
  };
enum tradeDirection
  {
   ENUM_LS,       //Long and Short
   ENUM_L,        //Long Only
   ENUM_S         //Short Only
  };
enum checkFrequency
  {
   ENUM_TICK,     //Every Tick
   ENUM_M1CLOSE   //M1 Close
  };
enum endSession
  {
   ENUM_CONT,     //Continue Sequence
   ENUM_PAUSE,    //Pause Sequence (No New Trades)
   ENUM_CLOSE     //Close All Trades
  };
enum eaRestart
  {
   ENUM_DAY,      //Restart Next Day (01:00)
   ENUM_HOURS     //Restart in Hours (Input Below)
  };
enum timeFrames
  {
   ENUM_M1,       //M1
   ENUM_M5,       //M5
   ENUM_M30,      //M30
   ENUM_H1,       //H1
   ENUM_H4        //H4
  };
enum emaPeriods
  {
   ENUM_EMAFAST,     //8-13-21     
   ENUM_EMAMID,      //9-21-55
   ENUM_EMAMIDSLOW,  //10-50-100
   ENUM_EMASLOW      //10-50-200
  };
enum trendRule
  {
   ENUM_TREND,       //Trend Only
   ENUM_RANGE,       //Range Only
   ENUM_TRENDRANGE,  //Range & Trend
   ENUM_COUNTERRANGE,//Range & Counter Trend 
   ENUM_COUNTERTREND //Counter Trend Only
  };
enum bbRule
  {
   ENUM_OFF,         //OFF
   ENUM_AVOID,       //Avoid Extreme Trend
   ENUM_COUNTERX     //Trade Counter Trend
  };
enum days
  {
   ENUM_MON,         //Monday
   ENUM_TUE,         //Tuesday
   ENUM_WED,         //Wednesday
   ENUM_THU,         //Thursday
   ENUM_FRI          //Friday
  };      

//+------------------------------------------------------------------+
//| Input Variables                                                                  
//+------------------------------------------------------------------+
input group          "GENERAL"
input bool           InpNewSeq               =     true;          //Allow New Sequence         
input int            InpMagicNumber          =     222011;        //Magic Number
input string         InpStratDescr           =     "";            //Strategy Description
input colorScheme    InpColorScheme          =     ENUM_MIDNIGHT; //Color Scheme 
input string         InpTradeComment         =     "";            //Trade Comment
input bool           InpRandEntry            =     false;         //Use Random Entry Delay
input bool           InpShowPanel            =     true;          //Show Panel      
   
input group          "SEQUENCE SETTING"
input int            InpATRPeriod            =     1000;          //ATR Period
input double         InpPipStep              =     10;            //Pip Step (negative means multiple of ATR)
input double         InpPipStepMulti         =     1.0;           //Pip Step Multiplier
input double         InpMaxPipStep           =     0;             //Max Pip Step (0=OFF - Negative=ATR)
input double         InpMinPipStep           =     0;             //Min Pip Step (0=OFF - Negative=ATR)
input int            InpDelayTradeSeq        =     0;             //Delay Trade Sequence
input tradeDirection InpTradeDirection       =     ENUM_LS;       //Trade Direction
input int            InpMaxPositions         =     30;            //Max Positions in One Direction
input bool           InpReverseSeq           =     false;         //Reverse Sequence Direction
input int            InpMinSeconds           =     0;             //Minimum Seconds Between Trades

input group          "TAKE PROFIT SETTINGS"
input double         InpStopLoss             =     0.0;           //Stop Loss (negative=ATR)
input double         InpTakeProfit           =     0.0;           //Take Profit (negative=ATR)
input int            InpLPMinimum            =     0;             //Lock Profit Minimum Trades
input double         InpLockProfit           =     5;             //Lock Profit (negative=ATR)
input checkFrequency InpLPCheck              =     ENUM_TICK;     //Lock Profit Check Frequency
input double         InpTrailingStop         =     2;             //Trailing Stop (negative=ATR)
input double         InpTrailingStep         =     1;             //Trailing Stop Check Pips (negative=ATR)
input checkFrequency InpTSCheck              =     ENUM_TICK;     //Trailing STop Check Frequecny               

input group          "LOT SIZE SETTINGS"
input bool           InpCompound             =     false;         //Compound Lot Size
input double         InpLotSize              =     0.10;          //Lot Size
input double         InpRisk                 =     0.0;           //Risk % Lot Size (Requires SL)
input double         InpLotMulitiplier       =     1.0;           //Lot Size Multiplier
input double         InpMaxLotSize           =     0.0;           //Max Lot Size (0=OFF)

input group          "CUSTOM TRADING SESSION"
input bool           InpCustomSession        =     false;         //Use Custom Session
input string         InpMonday               =     "00:00-00:00"; //- Monday   (0 = No Trading)
input string         InpTuesday              =     "00:00-00:00"; //- Tuesday  (0 = No Trading)
input string         InpWednesday            =     "00:00-00:00"; //- Wednesday(0 = No Trading)
input string         InpThursday             =     "00:00-00:00"; //- Thursday (0 = No Trading)
input string         InpFriday               =     "00:00-00:00"; //- Friday   (0 = No Trading)
input endSession     InpEndSession           =     ENUM_CONT;     //End Of Session Action
input bool           InpWeekendClose         =     false;         //Close For Weekend (Friday End Time)
input days           InpDayToClose           =     ENUM_FRI;      //Day to Close (21:00)
input days           InpDayToRestart         =     ENUM_MON;      //Day to Restart (21:00)

input group          "EQUITY PROTECTION SETTINGS"
input double         InpMaxLoss              =     0;             //Max Drawdown in Currency (Close this EA trades)
input eaRestart      InpEARestart            =     ENUM_DAY;      //Restart EA After Loss
input int            InpRestartHours         =     0;             //Restart in Hours
input double         InpDailyProfit          =     0;             //Daily Profit Target
input double         InpGlobalStop           =     0;             //Global Max Drawdown (Close all trades)  

input group          "RSI SETTINGS" 
input bool           InpUseRSI               =     false;         //Use RSI
input timeFrames     InpRsiTF                =     ENUM_M1;       //RSI timeFrame
input int            InpRSIPeriod            =     14;            //RSI Period
input int            InpRSILevel             =     80;            //RSI Upper Level

input group          "EMA SETTINGS" 
input bool           InpUseEMA               =     false;         //Use EMA
input timeFrames     InpEMATF                =     ENUM_M30;      //EMA TimeFrame
input emaPeriods     InpEMAPeriod            =     ENUM_EMAMID;   //EMA Period
input trendRule      InpEMARule              =     ENUM_TREND;    //EMA Trend Rule
input bool           InpEMACheck             =     false;         //Double Check First Trade (Delay Trade Sequence)    

input group          "ADX SETTINGS" 
input bool           InpUseADX               =     false;         //Use ADX
input timeFrames     InpADXTF                =     ENUM_M5;       //ADX TimeFrame
input int            InpADXPeriod            =     14;            //ADX Period
input double         InpADXThreshold         =     30;            //ADX Threshold
input trendRule      InpADXRule              =     ENUM_TREND;    //ADX Trend Rule
input bool           InpADXCheck             =     false;         //Double Check First Trade (Delay Trade Sequence)

input group          "BOLLINGER BANDS SETTINGS" 
input bbRule         InpUseBB                =     ENUM_OFF;      //Use Bollinger Bands
input timeFrames     InpBBTF                 =     ENUM_H1;       //BB TimeFrame
input int            InpBBPeriod             =     120;           //BB Period
input double         InpBBDeviation          =     1.5;           //BB Deviation

input group          "SAME PAIR/HEDGE FILTER"
input bool           InpSamePairDirection    =     false;         //Same Pair/Direction Filter
input bool           InpHedging              =     true;          //Allow Hedging
   
input group          "NEWS FILTER SETTINGS" 
input bool           InpUseNewsFilter        =     true;          //Use News Filter
input bool           InpUseUSDnews           =     true;          //Use USD News for non USD Pairs
input int            InpMinsBefore           =     120;           //Minutes Before News (Stop Trading)
input int            InpMinsAfter            =     120;           //Minutes After News (Resume Trading)
input endSession     InpNewsAction           =     ENUM_PAUSE;    //News Action
input bool           InpNewsInvert           =     false;         //News Invert - Trade Only News Session
input bool           InpUseNewsWindow        =     false;         //Use News Window (Prop Firm)
input int            InpNewsWindowStart      =     10;            //Start of News Window Minutes (Prop Firm)
input int            InpNewsWindowEnd        =     10;            //End of News Window Minutes (Prop Firm)

input group          "BACKTEST SETTINGS"
input int            InpMaxTradeDuration     =     0;             //Max Trade Duration Hours (0=OFF)


//+------------------------------------------------------------------+
//| Global Variables                                                                 
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

bool     can_trade, spread_ok, ema_check, adx_check, new_sequence, input_changed = false, fixed_SLTP;

double   bid, ask, max_spread, current_spread;
double   m1_close_price, input_lp;
double   buy_lotSize, sell_lotSize, max_lotSize, symbol_maxVol, buy_LP, sell_LP, buy_TS, sell_TS, buy_SL, sell_SL, buy_TP, sell_TP, breakEvenLineBuy, breakEvenLineSell;
double   buy_TS_check, sell_TS_check;
double   nextBuyPrice, nextSellPrice, last_open_price_buy, last_open_price_sell, buy_pipStep, sell_pipStep, prev_sell_pipStep, prev_buy_pipStep;
double   last_open_price, last_buy_pipStep, last_sell_pipStep, last_buy_vol, last_sell_vol, last_buy_price, last_sell_price;
double   totalSellPrice, totalBuyPrice, totalSellLots, totalBuyLots, last_volume_buy, last_volume_sell, last_volume;
int      last_position_type, m1_barsTotal;
int      cntBuy, cntSell;
string   buy_tradeComment, sell_tradeComment;

//virtual LP
double   v_buy_lotSize, v_sell_lotSize, v_buy_LP, v_sell_LP, v_breakEvenBuy, v_breakEvenSell;
double   v_totalSellPrice, v_totalBuyPrice, v_totalSellLots, v_totalBuyLots, v_last_volume_buy, v_last_volume_sell, v_last_volume, v_last_open_price_buy, v_last_open_price_sell;

//point conversions
double   pipStep_points, maxPipStep_points, minPipStep_points, sl_points, tp_points, lp_points, ts_points, tsPips_points;
double   pipStep_atr, maxPipStep_atr, minPipStep_atr, sl_atr, tp_atr, lp_atr, ts_atr, tsPips_atr;

//counters
int      DT_buyCount, DT_sellCount, DT_entrySellCount, DT_entryBuyCount, entrySellCount, entryBuyCount;
int      rand_buyCount, rand_sellCount, buy_check_count, sell_check_count;
int      seq_buyCount, seq_sellCount; 

//indicators
int      rsi_handle, emaS_handle, emaM_handle, emaF_handle, adx_handle, bb_handle, atr_handle;
double   rsi_buffer[], emaS_buffer[], emaM_buffer[], emaF_buffer[], adx_main_buffer[], adx_plus_buffer[], adx_minus_buffer[], bb_upper_buffer[], bb_lower_buffer[], atr_buffer[];
int      rsiUpper, rsiLower;

//custom session
ushort   sep_code;
string   mon_times[], tue_times[], wed_times[], thu_times[], fri_times[];
datetime mon_start, mon_stop, tue_start, tue_stop, wed_start, wed_stop, thu_start, thu_Stop, fri_start, fri_stop;
datetime day_start, day_end, weekendCloseTime, weekendRestartTime;
bool     closed_for_weekend, checkedSesh;
int      weekendCount;

//timeframe/periods variables
ENUM_TIMEFRAMES      rsiTF, emaTF, adxTF, bbTF; 
int      emaF_period, emaM_period, emaS_period; 


datetime time_now, next_buy_time, next_sell_time, last_buy_time, last_sell_time;


// Forex Factory News Variables
string   event_title[], event_country[], event_impact[];
datetime event_time[];
int      weeklyBarsTotal, newsWeekCount;
datetime news_stop, news_resume, news_windowStop, news_windowResume; 
bool     newsFilterCheck, newsWindowCheck, newsArrayCheck, can_trade_newsWindow; //newsWindowCheck = prop firm
string   baseCurrency = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
string   secondaryCurrency = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);


//backtest news variables
int      daily_barsTotal, array_oor;
datetime newsTime, bt_newsStop, bt_newsResume, bt_newsPropStop, bt_newsPropResume;
string   newsName;
static const bool IsTester = MQLInfoInteger(MQL_TESTER);
bool     usd_oor, gbp_oor, eur_oor, aud_oor, nzd_oor, cad_oor, jpy_oor, chf_oor;
bool     insideNewsFilter, outsideCustomSession, can_check_news=true, skipNextTick;

//Same pair/direction filter
bool     sameSymBuy, sameSymSell; 
long     buyMagic, sellMagic;
int      symBuyCount, symSellCount;
datetime samePair_next_check;

//Equity Protection
bool     epHit, profitReached;
datetime eaRestartTime;
double   totalDailyProfit, runningPL;
string   profitMessage = "Daily Profit Target Reached. EA Stopped.";

//Backtest Settings
int      durationCount, H1_bars_total;

//Object String Names
string beBuy = "beBuy", beSell = "beSell", lpBuy = "lpBuy", lpSell="lpSell";
string v_beBuy="v_beBuy", v_beSell="v_beSell", v_lpBuy="v_lpBuy", v_lpSell="v_lpSell";
//Panel string names
string   border="border", client="client", nav="nav", nav_brdr="nav_brdr", ea_name="ea_name", ea_v="ea_v";
string   div_1="div1",div_2="div2",div_3="div3",div_4="div4", news_brdr="nws_brdr", news_bg="nws_bg", ea_d="ea_d", ea_dText="ea_dText";
string   box1="box1",box2="box2",box3="3",box4="box4",box5="box5",box6="box6",box7="box7",box8="box8";
string   oProf="openProf",oProfC="oProfC", currTime="currTime",sesh="sesh",sesh1="sesh1",dts="dts", seshcontent="";
string   cBal="cBal",cBalC="cBalC",cEquity="cEquity",cEquityC="cEquityC",atr="atr",atrC="atrC",lots_str="lots",lotsC="lotsC",mLot="mLot",mLotC="mLotC";
string   newsHead="newsHead",nws1="nws1",nws1T="nws1T",nws2="nws2",nws2T="nws2T",nws3="nws3",nws3T="nws3T";

//GUI Panel variables
double   balance;
datetime nextSeshCheck;
string   lotsize_str, maxLots_str;
int      newsCounter;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   TesterHideIndicators(true);
//---
   trade.SetExpertMagicNumber(InpMagicNumber);
//---      
   weeklyBarsTotal   =  iBars(_Symbol,PERIOD_W1); 
   daily_barsTotal   =  iBars(_Symbol,PERIOD_D1);
   H1_bars_total     =  iBars(_Symbol,PERIOD_H1);
   m1_barsTotal      =  iBars(_Symbol,PERIOD_M1);  
//---  
   if(InpNewSeq==true){new_sequence=true;}
   if(InpNewSeq==false){new_sequence=false;}
//--- 
   ArraySetAsSeries(rsi_buffer,true);
   ArraySetAsSeries(emaS_buffer,true);
   ArraySetAsSeries(emaM_buffer,true);
   ArraySetAsSeries(emaF_buffer,true);
   ArraySetAsSeries(adx_main_buffer,true);
   ArraySetAsSeries(adx_minus_buffer,true);
   ArraySetAsSeries(adx_plus_buffer,true);
   ArraySetAsSeries(bb_lower_buffer,true);
   ArraySetAsSeries(bb_upper_buffer,true);
//indicators
// rsi TF
   if(InpRsiTF == ENUM_M1){rsiTF = PERIOD_M1;}
   if(InpRsiTF == ENUM_M5){rsiTF = PERIOD_M5;}
   if(InpRsiTF == ENUM_M30){rsiTF = PERIOD_M30;}
   if(InpRsiTF == ENUM_H1){rsiTF = PERIOD_H1;}
   if(InpRsiTF == ENUM_H4){rsiTF = PERIOD_H4;}
// ema TF
   if(InpEMATF == ENUM_M1){emaTF = PERIOD_M1;}
   if(InpEMATF == ENUM_M5){emaTF = PERIOD_M5;}
   if(InpEMATF == ENUM_M30){emaTF = PERIOD_M30;}
   if(InpEMATF == ENUM_H1){emaTF = PERIOD_H1;}
   if(InpEMATF == ENUM_H4){emaTF = PERIOD_H4;}
// adxTF
   if(InpADXTF == ENUM_M1){adxTF = PERIOD_M1;}
   if(InpADXTF == ENUM_M5){adxTF = PERIOD_M5;}
   if(InpADXTF == ENUM_M30){adxTF = PERIOD_M30;}
   if(InpADXTF == ENUM_H1){adxTF = PERIOD_H1;}
   if(InpADXTF == ENUM_H4){adxTF = PERIOD_H4;}
// bb TF
   if(InpBBTF == ENUM_M1){bbTF = PERIOD_M1;}
   if(InpBBTF == ENUM_M5){bbTF = PERIOD_M5;}
   if(InpBBTF == ENUM_M30){bbTF = PERIOD_M30;}
   if(InpBBTF == ENUM_H1){bbTF = PERIOD_H1;}
   if(InpBBTF == ENUM_H4){bbTF = PERIOD_H4;}
// ema periods
   if(InpEMAPeriod == ENUM_EMAFAST){emaF_period=8; emaM_period=13; emaS_period=21;}
   if(InpEMAPeriod == ENUM_EMAMID){emaF_period=9; emaM_period=21; emaS_period=55;}
   if(InpEMAPeriod == ENUM_EMAMIDSLOW){emaF_period=10; emaM_period=50; emaS_period=100;}
   if(InpEMAPeriod == ENUM_EMASLOW){emaF_period=10; emaM_period=50; emaS_period=200;}      
// indicator handle
   rsi_handle     = iRSI(_Symbol,rsiTF,InpRSIPeriod,PRICE_CLOSE);
   emaF_handle    = iMA(_Symbol,emaTF,emaF_period,0,MODE_EMA,PRICE_CLOSE);
   emaM_handle    = iMA(_Symbol,emaTF,emaM_period,0,MODE_EMA,PRICE_CLOSE);
   emaS_handle    = iMA(_Symbol,emaTF,emaS_period,0,MODE_EMA,PRICE_CLOSE);
   adx_handle     = iADX(_Symbol,adxTF,InpADXPeriod);
   bb_handle      = iBands(_Symbol,bbTF,InpBBPeriod,0,InpBBDeviation,PRICE_CLOSE);
   atr_handle     = iATR(_Symbol,PERIOD_M1,InpATRPeriod); 
// setting rsi upper/lower level
   rsiUpper = InpRSILevel;
   rsiLower = 100 - rsiUpper;   
// string split seperator code     
   sep_code = StringGetCharacter("-",0);
// maximum mvolume on symbol   
   symbol_maxVol = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
// set chart properties
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
// color schemes   
   if(InpColorScheme == ENUM_MIDNIGHT){
      ChartSetBackColor(C'7,16,39',0);
      ChartSetForeColor(clrWhite,0);
      ChartSetGridColor(C'7,16,39',0);
      ChartSetUpColor(clrChartreuse,0);
      ChartSetBullColor(clrChartreuse,0);
      ChartSetDownColor(clrCrimson,0);
      ChartSetBearColor(clrCrimson,0);
      ChartSetVolumesColor(C'44,106,255',0);
      ChartSetAskLineColor(C'44,106,255',0);
        
   }
   if(InpColorScheme == ENUM_DARK){
      ChartSetBackColor(clrBlack,0);
      ChartSetForeColor(clrGray,0);
      ChartSetGridColor(C'31,31,31',0);
      ChartSetUpColor(C'85,85,85',0);
      ChartSetBullColor(C'85,85,85',0);
      ChartSetDownColor(C'85,85,85',0);
      ChartSetBearColor(C'85,85,85',0);
      ChartSetVolumesColor(clrTurquoise,0);
      ChartSetAskLineColor(clrSilver,0);
      ChartSetBidLineColor(clrTurquoise,0); //C'42, 177, 253'  
   }
   /////////////////////////////////////////////////////////////////////
   // PANEL CREATE                                                                
   ////////////////////////////////////////////////////////////////////
   if(InpShowPanel){
      // background border
      rectangleCreate(border,18,108,504,484,C'81, 81, 81'); //81, 81, 81     //C'42, 177, 253'
      // background
      rectangleCreate(client,20,110,500,480,C'22, 22, 22');  //16,16,32
      // nav bar border
      rectangleCreate(nav_brdr,18,58,244,53,C'81, 81, 81');
      // nav bar rectangle
      rectangleCreate(nav,20,60,240,50,C'17, 17, 20');
      // nav bar text
      textLabelCreate(ea_name,50,65,"PALM EA v1.0",12,C'156,156,174');
      // nav divider
      dividerCreate(div_1,40,110,200,1,C'67, 69, 91');
      dividerCreate(div_2,40,160,460,1,C'67, 69, 91');
      // news border
      rectangleCreate(news_brdr,18,505,504,190,C'67, 69, 91'); //1news ysize=100, 2news=140, 3news= 190
      // news background
      rectangleCreate(news_bg,20,507,500,186,C'22, 22, 22'); //1news ysize=96, 2news=136, 3news=186
      // ea description
      //rectangleCreate(ea_d,22,112,496,50,C'36, 37, 43');
      // ea description text
      string stratString="";
      if(InpStratDescr==""){
         if(InpTradeComment != ""){stratString = InpTradeComment;}
         else{stratString = _Symbol+" - Palm EA";}
      } else {
         stratString = InpStratDescr;
      }
      textLabelCreate(ea_dText,45,118,stratString,10,clrMediumSpringGreen);
      textLabelCreate(currTime,420,118,TimeToString(TimeCurrent(),TIME_MINUTES|TIME_SECONDS),10,clrMediumSpringGreen);
      // trading session
      textLabelCreate(sesh,60,170,"current session",10,C'156,156,174');
      rectangleCreate(box1,295,164,200,50,C'36, 37, 43');
      if(InpCustomSession==false){seshcontent="ALL DAY";}
      textLabelCreate(sesh1,395,180,seshcontent,11,clrMediumSpringGreen);
      ObjectSetInteger(0,sesh1,OBJPROP_ANCHOR,ANCHOR_CENTER);
      // current balance
      textLabelCreate(cBal,60,220,"current balance",10,C'156,156,174');
      rectangleCreate(box2,295,216,200,50,C'36, 37, 43');
      textLabelCreate(cBalC,395,230,DoubleToString(accountInfo.Balance(),2),11,clrMediumSpringGreen);
      ObjectSetInteger(0,cBalC,OBJPROP_ANCHOR,ANCHOR_CENTER);
      balance = accountInfo.Balance();
      //current equity
      textLabelCreate(cEquity,60,270,"current equity",10,C'156,156,174'); 
      rectangleCreate(box3,295,268,200,50,C'36, 37, 43');
      textLabelCreate(cEquityC,395,285,DoubleToString(accountInfo.Equity(),2),10,clrMediumSpringGreen);
      ObjectSetInteger(0,cEquityC,OBJPROP_ANCHOR,ANCHOR_CENTER);
      // ATR pips
      textLabelCreate(atr,60,320,"atr pips",10,C'156,156,174');
      rectangleCreate(box4,295,320,200,50,C'36, 37, 43');
      textLabelCreate(atrC,395,335,"0.00",10,clrMediumSpringGreen);
      ObjectSetInteger(0,atrC,OBJPROP_ANCHOR,ANCHOR_CENTER);
      // lot size
      if(!InpCompound){lots_str=DoubleToString(InpLotSize,2); maxLots_str=DoubleToString(InpMaxLotSize,2);}
      textLabelCreate(lots_str,60,370,"lot size",10,C'156,156,174');
      rectangleCreate(box5,295,372,200,50,C'36, 37, 43');
      textLabelCreate(lotsC,395,390,lots_str,10,clrMediumSpringGreen);
      ObjectSetInteger(0,lotsC,OBJPROP_ANCHOR,ANCHOR_CENTER);
      //max lot size
      textLabelCreate(mLot,60,420,"max lots",10,C'156,156,174');
      rectangleCreate(box6,295,424,200,50,C'36, 37, 43');
      textLabelCreate(mLotC,395,440,maxLots_str,10,clrMediumSpringGreen);
      ObjectSetInteger(0,mLotC,OBJPROP_ANCHOR,ANCHOR_CENTER);
      //news header
      textLabelCreate(newsHead,45,510,"HIGH IMPACT NEWS",10,clrMediumSpringGreen);
      dividerCreate(div_3,40,550,200,1,C'67, 69, 91');
      ////news 1
      //textLabelCreate(nws1,60,555,"Non Farm Employment Change",9,C'156,156,174');
      //textLabelCreate(nws1T,440,555,"15:30",10,clrMediumSpringGreen);
      ////news 2
      //textLabelCreate(nws2,60,595,"ISM Manufacturing",9,C'156,156,174');
      //textLabelCreate(nws2T,440,595,"17:00",10,clrMediumSpringGreen);
      ////news 3
      //textLabelCreate(nws3,60,635,"CPI m/m",9,C'156,156,174');
      //textLabelCreate(nws3T,440,635,"18:00",10,clrMediumSpringGreen);
   }

   
   input_lp = InpLockProfit;
   
   
   if(UninitializeReason() == 5){
      input_changed = true;
   }  
   
   return(INIT_SUCCEEDED);
}



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(rsi_handle != INVALID_HANDLE){IndicatorRelease(rsi_handle);}
   if(emaF_handle != INVALID_HANDLE){IndicatorRelease(emaF_handle);}
   if(emaM_handle != INVALID_HANDLE){IndicatorRelease(emaM_handle);}
   if(emaS_handle != INVALID_HANDLE){IndicatorRelease(emaS_handle);}
   if(adx_handle != INVALID_HANDLE){IndicatorRelease(adx_handle);}
   if(bb_handle != INVALID_HANDLE){IndicatorRelease(bb_handle);}
   
   ObjectsDeleteAll(0,0,-1);
  }
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---   
   if(!SymbolInfoTick(_Symbol,currentTick)){Print("Failed to get current tick.");return;}
//---
   //-- check backtest news at start of each day
   if(IsTester && InpUseNewsFilter==true){
      
      if((InpUseUSDnews==true && array_oor==3) || (InpUseUSDnews==false && array_oor==2) || (baseCurrency=="USD" && array_oor==2) || (secondaryCurrency=="USD" && array_oor==2)){
         can_check_news = false;
      }
  
      int dayBars = iBars(_Symbol,PERIOD_D1);
      if(daily_barsTotal != dayBars){
         daily_barsTotal = dayBars;
         if(can_check_news == true){
            newsBackTest(TimeCurrent());     
         }
      }
      if(TimeCurrent() > bt_newsResume && can_check_news == true){
         newsBackTest(TimeCurrent());
         skipNextTick = false;
      }
   }
//---   
   //-- check if algo trading is enabled to reset can_trade to true / must be check up here to not overide session times etc.
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
      can_trade = true;
   }  
//---
   //Get Bid & Ask Price
   bid = currentTick.bid;
   ask = currentTick.ask;  
//---
   //count open positions
   CountOpenPositions(cntBuy,cntSell);
   
////  RESETING COUNTERS  ///////////////////////////////////////////////////////
   if(can_trade == false && cntBuy == 0){
      DT_entryBuyCount = 0;
      DT_buyCount = 0;
      entryBuyCount = 0;
   }
   if(can_trade == false && cntSell == 0){
      DT_entrySellCount = 0;
      DT_sellCount = 0;
      entrySellCount = 0;
   }   

   if(cntBuy==0){
      totalBuyLots=0;
      totalBuyPrice=0;
      breakEvenLineBuy=0;
      buy_check_count=0;
      //rand_buyCount=0;
      entryBuyCount=0;
      buy_pipStep=0;
      buy_LP=0;
      buy_TS_check=0;
      prev_buy_pipStep=0;
      seq_buyCount = 0;
   }
   if(cntSell==0){
      totalSellLots=0;
      totalSellPrice=0;
      breakEvenLineSell=0;
      sell_check_count=0;
      //rand_sellCount=0;
      entrySellCount=0;
      sell_pipStep=0;
      sell_LP=0;
      sell_TS_check=0;
      prev_sell_pipStep=0;
      seq_sellCount = 0;
   }
   if(cntBuy > 0){
      rand_buyCount = 0;
      v_breakEvenBuy = 0;
      //v_buy_LP = 0;
      v_totalBuyLots = 0;
      v_totalBuyPrice = 0;
      //DT_buyCount = 0;
      DT_entryBuyCount = 0;
   }
   if(cntSell > 0){
      rand_sellCount = 0;
      v_breakEvenSell = 0;
      //v_sell_LP = 0;
      v_totalSellLots = 0;
      v_totalSellPrice = 0;
      //DT_sellCount = 0;
      DT_entrySellCount = 0;
   }    
//---   
   //Get M1 Close Price of Previous Bar
   m1_close_price = iClose(_Symbol,PERIOD_M1,1);
//---

//---
   //copy indicators into buffer arrays
   //CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
   //CopyBuffer(emaF_handle,0,0,3,emaF_buffer);
   //CopyBuffer(emaM_handle,0,0,3,emaM_buffer);
   //CopyBuffer(emaS_handle,0,0,3,emaS_buffer);
   //CopyBuffer(adx_handle,0,0,3,adx_main_buffer);
   //CopyBuffer(adx_handle,1,0,3,adx_plus_buffer);
   //CopyBuffer(adx_handle,2,0,3,adx_minus_buffer);
   //CopyBuffer(bb_handle,1,0,3,bb_upper_buffer);
   //CopyBuffer(bb_handle,2,0,3,bb_lower_buffer);
   CopyBuffer(atr_handle,0,0,3,atr_buffer);

//---

   //point conversions
   if(InpTakeProfit >= 0){tp_points = NormalizeDouble(InpTakeProfit * 10 * _Point,_Digits);}
   if(InpTakeProfit < 0){tp_atr = (InpTakeProfit-(InpTakeProfit*2)); tp_points = NormalizeDouble(atr_buffer[0] * tp_atr,_Digits);}

   if(InpStopLoss >= 0){sl_points = NormalizeDouble(InpStopLoss * 10 * _Point,_Digits);}
   if(InpStopLoss < 0){sl_atr = (InpStopLoss-(InpStopLoss*2)); sl_points = NormalizeDouble(atr_buffer[0] * sl_atr,_Digits);}
   
   if(InpLockProfit >= 0){lp_points = NormalizeDouble(InpLockProfit * 10 * _Point,_Digits);}
   if(InpLockProfit < 0){lp_atr = (InpLockProfit-(InpLockProfit*2)); lp_points = NormalizeDouble(atr_buffer[0] * lp_atr,_Digits);}

   if(InpTrailingStop >= 0){ts_points = NormalizeDouble(InpTrailingStop * 10 * _Point,_Digits);}
   if(InpTrailingStop < 0){ts_atr = (InpTrailingStop-(InpTrailingStop*2)); ts_points = NormalizeDouble(atr_buffer[0] * ts_atr,_Digits);}
   
   if(InpTrailingStep >= 0){tsPips_points = NormalizeDouble(InpTrailingStep * 10 * _Point,_Digits);}
   if(InpTrailingStep < 0){tsPips_atr = (InpTrailingStep-(InpTrailingStep*2)); tsPips_points = NormalizeDouble(atr_buffer[0] * tsPips_atr,_Digits);}   
   
   if(InpMaxPipStep >= 0){maxPipStep_points = NormalizeDouble(InpMaxPipStep * 10 * _Point,_Digits);}
   if(InpMaxPipStep < 0){maxPipStep_atr = (InpMaxPipStep-(InpMaxPipStep*2)); maxPipStep_points = NormalizeDouble(atr_buffer[0] * maxPipStep_atr,_Digits);}
   
   if(InpMinPipStep >= 0){minPipStep_points = NormalizeDouble(InpMinPipStep * 10 * _Point,_Digits);}
   if(InpMinPipStep < 0){minPipStep_atr = (InpMinPipStep-(InpMinPipStep*2)); minPipStep_points = NormalizeDouble(atr_buffer[0] * minPipStep_atr,_Digits);}
     
   if(InpPipStep >= 0){pipStep_points = NormalizeDouble(InpPipStep * 10 * _Point,_Digits);}
   if(InpPipStep < 0){pipStep_atr = (InpPipStep-(InpPipStep*2)); pipStep_points = NormalizeDouble(atr_buffer[0] * pipStep_atr,_Digits);}
   if(atr_buffer[0]==0.0){Print("ERROR - ATR not found, trying again..."); return;}
   
   //max lot size
   if(InpCompound && InpMaxLotSize > 0 && accountInfo.Balance() >= 100000){
      max_lotSize = NormalizeDouble(InpMaxLotSize * (accountInfo.Balance() / 100000),2);
   } else {
      max_lotSize = InpMaxLotSize;
   }
   
//---
   //max spread
   max_spread = NormalizeDouble(atr_buffer[0]*1.5,_Digits);
   current_spread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)*_Point;
   if(current_spread > max_spread){spread_ok = false;}
   else{spread_ok = true;}
//---

   
//Time Settings
   time_now = TimeCurrent();
   TimeToStruct(time_now,today);
   if(time_now > day_end){
      checkedSesh = false;
   }

//custom sessions
   if(InpCustomSession==false){can_trade = true;}

   if(InpCustomSession==true){
      //monday
      if(today.day_of_week == 1){
         StringSplit(InpMonday,sep_code,mon_times);
         mon_start = StringToTime(mon_times[0]);
         mon_stop = StringToTime(mon_times[1]);
         customSesion(mon_start,mon_stop);
         if(InpShowPanel && !checkedSesh){
            ObjectSetString(0,sesh1,OBJPROP_TEXT,InpMonday); 
            checkedSesh=true;
         }
      }
      //tuesday
      if(today.day_of_week == 2){
         StringSplit(InpTuesday,sep_code,tue_times);
         tue_start = StringToTime(tue_times[0]);
         tue_stop = StringToTime(tue_times[1]);
         customSesion(tue_start,tue_stop);
         if(InpShowPanel && !checkedSesh){
            ObjectSetString(0,sesh1,OBJPROP_TEXT,InpTuesday); 
            checkedSesh=true;
         }
      }
      //wednesday
      if(today.day_of_week == 3){
         StringSplit(InpWednesday,sep_code,wed_times);
         wed_start = StringToTime(wed_times[0]);
         wed_stop = StringToTime(wed_times[1]);
         customSesion(wed_start,wed_stop);
         if(InpShowPanel && !checkedSesh){
            ObjectSetString(0,sesh1,OBJPROP_TEXT,InpWednesday); 
            checkedSesh=true;
         }
      }
      //thursday
      if(today.day_of_week == 4){
         StringSplit(InpThursday,sep_code,thu_times);
         thu_start = StringToTime(thu_times[0]);
         thu_Stop = StringToTime(thu_times[1]);
         customSesion(thu_start,thu_Stop);
         if(InpShowPanel && !checkedSesh){
            ObjectSetString(0,sesh1,OBJPROP_TEXT,InpThursday); 
            checkedSesh=true;
         }
      }
      //friday
      if(today.day_of_week == 5){
         StringSplit(InpFriday,sep_code,fri_times);
         fri_start = StringToTime(fri_times[0]);
         fri_stop = StringToTime(fri_times[1]);
         customSesion(fri_start,fri_stop);
         if(InpShowPanel && !checkedSesh){
            ObjectSetString(0,sesh1,OBJPROP_TEXT,InpFriday); 
            checkedSesh=true;
         }
      }   
   }  
//--- 

//________________________________________________________________________________________________________________________________________________________________ LIVE/BACKTEST NEWS START __________/

////  FOREX FACTORY NEWS DOWNLOAD  ////////////////////////////////////////////////
                                                                                          //-- CHECK IF RED NEWS == ALL DAY. TURN NEW_SEQUENCE TO FALSE FOR WHOLE DAY. *********
   string   str_todayDate  = TimeToString(TimeCurrent(),TIME_DATE);
   string   str_timeNow    = TimeToString(TimeCurrent(),TIME_MINUTES);   
   day_start = iTime(_Symbol,PERIOD_D1,0);
   day_end = day_start + PeriodSeconds(PERIOD_D1);
 
   if(!IsTester){  
      if(InpUseNewsWindow == false){newsWindowCheck = false; can_trade_newsWindow = true;}
       
      if(newsWeekCount == 0){     
         CArrayString *newsTitleArray=new CArrayString;  
         CArrayString *newsCountryArray=new CArrayString;
         CArrayString *newsTimeArray=new CArrayString;
         CArrayString *newsImpactArray=new CArrayString;
            
         CFFCalendarDownload *downloader = new CFFCalendarDownload("KG\\News", 50000);
         bool           success     =  downloader.Download("calendar.csv");
         int            error       =  0;
         
         ArrayResize(event_title, downloader.Count);
         ArrayResize(event_country, downloader.Count);
         ArrayResize(event_impact, downloader.Count);
         ArrayResize(event_time, downloader.Count);
         
         if (!success) {
            PrintFormat("failed to download.");
            error    =  downloader.Error();
            Alert("Failed to download news. Add 'https://nfs.faireconomy.media' to Tools > Options > Expert Advisors > WebRequest URL..");
         }
         else {
            for(int i=0; i<downloader.Count; i++){
               //PrintFormat("Title=%s | Country=%s | Time=%s | Impact=%s | Forecast=%s | Previous=%s",
               //            downloader.Events[i].title,
               //            downloader.Events[i].country,
               //            TimeToString(downloader.Events[i].time),
               //            downloader.Events[i].impact,
               //            downloader.Events[i].forecast,
               //            downloader.Events[i].previous);
               
               if(!newsTitleArray.Add(downloader.Events[i].title)){printf("Event Title Array - Element addition error."); delete newsTitleArray; return;} 
               if(!newsCountryArray.Add(downloader.Events[i].country)){printf("Event Country Array - Element addition error."); delete newsCountryArray; return;}
               if(!newsImpactArray.Add(downloader.Events[i].impact)){printf("Event Impact Array - Element addition error."); delete newsImpactArray; return;}
               if(!newsTimeArray.Add(TimeToString(downloader.Events[i].time))){printf("Event Time Array - Element addition error."); delete newsTimeArray; return;}
               
               event_title[i]       =  newsTitleArray[i];  
               event_country[i]     =  newsCountryArray[i];
               event_impact[i]      =  newsImpactArray[i];
               event_time[i]        =  StringToTime(newsTimeArray[i]); 
            }
         }   
   
         delete downloader;
         delete newsCountryArray;
         delete newsImpactArray;
         delete newsTimeArray;
         delete newsTitleArray; 
      
         newsWeekCount = 1;
      }
   
      datetime dt_gmtOffset = TimeCurrent() - TimeGMT();
      int     s_gmtOffeset = (int) dt_gmtOffset;
      
      if(newsArrayCheck == false){ 
         for(int i=0; i<ArraySize(event_title); i++){
            if((event_country[i] == baseCurrency && event_impact[i] == "High" && event_time[i] >= day_start && event_time[i] < day_end) ||
               (event_country[i] == secondaryCurrency && event_impact[i] == "High" && event_time[i] >= day_start && event_time[i] < day_end) ||
               (event_country[i] == "USD" && event_impact[i] == "High" && event_time[i] >= day_start && event_time[i] < day_end)){
               
               if(InpUseNewsWindow==true && time_now < (event_time[i]+s_gmtOffeset) + InpNewsWindowStart*60 && newsWindowCheck==false){
                  news_windowStop   = (event_time[i]+s_gmtOffeset) - (InpNewsWindowStart*60);  
                  news_windowResume = (event_time[i]+s_gmtOffeset) + (InpNewsWindowEnd*60);
                  newsWindowCheck   = true;
               }
               if(InpUseNewsFilter==true && time_now < (event_time[i]+s_gmtOffeset) + InpMinsAfter*60 && newsFilterCheck==false){
                  news_stop = (event_time[i]+s_gmtOffeset) - (InpMinsBefore*60);
                  news_resume = (event_time[i]+s_gmtOffeset) + (InpMinsBefore*60);
                  newsFilterCheck = true;
                  PrintFormat("*Upcoming News: %s | %s | Stop Trading at: %s | Resume Trading at: %s*", event_country[i], event_title[i], TimeToString(news_stop), TimeToString(news_resume));
                  break;
               }
               //newsArrayCheck = true;
            }
         }
      }

      int weeklyBars = iBars(_Symbol,PERIOD_W1);
      if(weeklyBarsTotal != weeklyBars){
         weeklyBarsTotal = weeklyBars;
         newsWeekCount = 0;
      }
      if(InpUseNewsWindow==true && time_now > news_windowResume){newsWindowCheck=false; newsArrayCheck=false;}
      if(InpUseNewsFilter==true && time_now > news_resume){newsFilterCheck=false; newsArrayCheck=false;}
      //Comment("news_Resume: ",news_resume,"\nevent_Title[2]: ",event_title[11]," | @ ",event_time[11]+s_gmtOffeset);
      if(InpUseNewsWindow == true){
         if(time_now < news_windowStop){
            can_trade_newsWindow = true;
         }
         if(time_now >= news_windowStop && time_now < news_windowResume){
            can_trade_newsWindow = false;
         }
         if(time_now >= news_windowResume){
            can_trade_newsWindow = true;
         }
      }
      if(InpUseNewsFilter == true){
         if(time_now >= news_stop && time_now < news_resume){
            can_trade = false;
            insideNewsFilter = true;
            //PrintFormat("Stopping For High Impact News from: %s - Resuming at: %s", TimeToString(news_stop), TimeToString(news_resume));
         }
         if(time_now >= news_resume){
            if(InpCustomSession==false){can_trade = true;}
            if(InpCustomSession==true && outsideCustomSession==false){can_trade = true;}    // && insideNews == false                // ********** THIS IS CAUSING CAN_TRADE TO BE TRUE OUTSIDE OF CUSTOM SESSION TIME ***************************** //
            if(InpCustomSession==true && outsideCustomSession==true){can_trade = false;}
            insideNewsFilter = false;                                     //  need to do if(no news today){news_today==false;}
            //Print("News Over; Resuming Trading now...");                  //  then if(news_today==false)
         }
      }
   }


////  BACKTESTING NEWS  ////////////////////////////////////////////////////   
   if(IsTester){
      if(InpUseNewsWindow == false){newsWindowCheck = false; can_trade_newsWindow = true;}
      if(InpUseNewsWindow == true){
         if(time_now >= bt_newsPropStop && time_now <= bt_newsPropResume){
            can_trade_newsWindow = false;
         }
         else {
            can_trade_newsWindow = true;
         }
      }
      
      //if(InpUseNewsWindow==true && time_now > news_windowResume){newsWindowCheck=false;}
      if(InpUseNewsFilter==true && time_now > bt_newsResume){
         newsFilterCheck=false; 
         insideNewsFilter=false;
         if(can_check_news==true){skipNextTick = true;}   
      }
      
      //if(InpUseNewsWindow == true){
      //   if(time_now >= news_windowStop && time_now < news_windowResume){
      //      can_trade_newsWindow = false;
      //   }
      //   if(time_now >= news_windowResume){
      //      can_trade_newsWindow = true;
      //   }
      //}
      
      if(InpUseNewsFilter == true){
         if(time_now >= bt_newsStop && time_now < bt_newsResume){
            can_trade = false;
            insideNewsFilter = true;
            //PrintFormat("Stopping For High Impact News from: %s - Resuming at: %s", TimeToString(bt_newsStop), TimeToString(bt_newsResume));
         }       
         if(time_now >= bt_newsResume || time_now < bt_newsStop){
            if(InpCustomSession==false){can_trade = true;}
            if(InpCustomSession==true && outsideCustomSession==false){can_trade = true;}    // && insideNews == false                // ********** THIS IS CAUSING CAN_TRADE TO BE TRUE OUTSIDE OF CUSTOM SESSION TIME ***************************** //
            if(InpCustomSession==true && outsideCustomSession==true){can_trade = false;}
            insideNewsFilter = false;                                     //  need to do if(no news today){news_today==false;}
            //Print("News Over; Resuming Trading now...");                  //  then if(news_today==false)
         }
      }
   }
//________________________________________________________________________________________________________________________________________________________________ LIVE/BACKTEST NEWS END _____________/   


////  SAME PAIR / DIRECTION FILTER  ////////////////////////////////////////////////////
   if(!IsTester){
      if(InpSamePairDirection==true){
         if(PositionsTotal() > 0){
            symBuyCount=0;
            symSellCount=0;
            for(int i=PositionsTotal()-1; i>=0; i--){
               long magic  = PositionGetInteger(POSITION_MAGIC);
               long type   = PositionGetInteger(POSITION_TYPE);
               string sym  = PositionGetString(POSITION_SYMBOL);
               if(sym == _Symbol && magic!= InpMagicNumber){
                  if(type == POSITION_TYPE_BUY){
                     sameSymBuy=true;
                     buyMagic = magic;
                     symBuyCount+=1;
                  }
                  if(type == POSITION_TYPE_SELL){
                     sameSymSell=true;
                     sellMagic = magic;
                     symSellCount+=1;
                  }
               }
            }
            if(symBuyCount==0){sameSymBuy=false;}
            if(symSellCount==0){sameSymSell=false;}
         }
         if(PositionsTotal() == 0){
            sameSymBuy=false;
            sameSymSell=false;
         }    
      }
      if(InpSamePairDirection==false){
         sameSymBuy=false;
         sameSymSell=false;
      }
   }
   else {
      sameSymBuy=false;
      sameSymSell=false;
   }


////  HEDGING NOT ALLOWED  ////////////////////////////////////////////////////////////////
   if(InpHedging == false && InpNewSeq==true){
      if(cntBuy > 0 || cntSell > 0){
         new_sequence = false;
      }
      else {
         new_sequence = true;
      }
   }

////  WEEKEND CLOSE  /////////////////////////////////////////////////////////////////////
   day_start = iTime(_Symbol,PERIOD_D1,0);
   if(InpWeekendClose == true){
      if(closed_for_weekend == false){
         if(today.day_of_week==5 && InpDayToClose==ENUM_FRI && time_now >= day_start+21*60*60){
            weekendCloseTimes(); 
         }
         if(today.day_of_week==4 && InpDayToClose==ENUM_THU && time_now >= day_start+21*60*60){
            weekendCloseTimes();
         }
         if(today.day_of_week==3 && InpDayToClose==ENUM_WED && time_now >= day_start+21*60*60){
            weekendCloseTimes();
         }
         if(today.day_of_week==2 && InpDayToClose==ENUM_TUE && time_now >= day_start+21*60*60){
            weekendCloseTimes();
         }
         if(today.day_of_week==1 && InpDayToClose==ENUM_MON && time_now >= day_start+21*60*60){
            weekendCloseTimes();
         }
      }
      if(time_now >= weekendCloseTime && time_now < weekendRestartTime){
         can_trade = false;
      }
      if(time_now >= weekendRestartTime && weekendCount==1){
         can_trade = true;
         closed_for_weekend = false;
         weekendCount = 0;
      }
   }

//---
   //-- check if algo trading is disabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
      can_trade = false;
   }
//________________________________________________________________________________________________________________________________________________________________ ENTRY POSITION CONDITIONS ______/

   int m1_bars = iBars(_Symbol,PERIOD_M1);
   if(m1_barsTotal != m1_bars){
      m1_barsTotal = m1_bars;

      if(skipNextTick){can_trade = false;}
      if(entryBuyCount==0 || entrySellCount==0){

      ////  NO INDICATORS  ////////////////////////////////////////////////////////////   
         if(new_sequence==true && can_trade==true && spread_ok==true && InpUseRSI==false && InpUseEMA==false && InpUseADX==false && InpUseBB==ENUM_OFF){
            randomEntryBuy();
            randomEntrySell();
            entrySellPosition();
            entryBuyPosition();
         }    
      
      
      ////  RSI ONLY  /////////////////////////////////////////////////////////////////    
         if(InpUseRSI==true && InpUseEMA==false && InpUseADX==false && InpUseBB==ENUM_OFF){ 
            //-- Buys
            if(rsiBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition())
            {    randomEntrySell(); entrySellPosition();   } 
         }
        
           
      ////  EMA ONLY  /////////////////////////////////////////////////////////////////  
         if(InpUseRSI==false && InpUseEMA==true && InpUseADX==false && InpUseBB==ENUM_OFF){
            //-- Buys
            if(emaBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //--Sells
            if(emaSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
        
          
      ////  ADX ONLY  /////////////////////////////////////////////////////////////////  
         if(InpUseRSI==false && InpUseEMA==false && InpUseADX==true && InpUseBB==ENUM_OFF){
            //-- Buys
            if(adxBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(adxSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
         
         
      ////  BB ONLY  //////////////////////////////////////////////////////////////////    
         if(InpUseRSI==false && InpUseEMA==false && InpUseADX==false && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(bbSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
         
          
      ////  RSI & EMA  ////////////////////////////////////////////////////////////////  
         if(InpUseRSI==true && InpUseEMA==true && InpUseADX==false && InpUseBB==ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && emaBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && emaSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
         
       
      ////  RSI & ADX  ////////////////////////////////////////////////////////////////    
         if(InpUseRSI==true && InpUseEMA==false && InpUseADX==true && InpUseBB==ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && adxBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && adxSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
         
       
      ////  RSI & BB  /////////////////////////////////////////////////////////////////   
         if(InpUseRSI==true && InpUseEMA==false && InpUseADX==false && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
                                                                                                                                                                               
                                                                                               
      ////  EMA & ADX  ////////////////////////////////////////////////////////////////
         if(InpUseRSI==false && InpUseEMA==true && InpUseADX==true && InpUseBB==ENUM_OFF){
            //-- Buys
            if(emaBuyCondition() && adxBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(emaSellCondition() && adxSellCondition())
            {    randomEntrySell(); entrySellPosition();   }
         }
         
        
      ////  EMA & BB  /////////////////////////////////////////////////////////////////  
         if(InpUseRSI==false && InpUseEMA==true && InpUseADX==false && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(emaBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(emaSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();    }
         }
                 
      
      ////  ADX & BB  /////////////////////////////////////////////////////////////////   
         if(InpUseRSI==false && InpUseEMA==false && InpUseADX==true && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(adxBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(adxSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();    }
         }
           
         
      ////  RSI & EMA & ADX  //////////////////////////////////////////////////////////  
         if(InpUseRSI==true && InpUseEMA==true && InpUseADX==true && InpUseBB==ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && emaBuyCondition() && adxBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && emaSellCondition() && adxSellCondition())
            {    randomEntrySell(); entrySellPosition();    }  
         }
        
       
      ////  RSI & ADX & BB  ///////////////////////////////////////////////////////////   
         if(InpUseRSI==true && InpUseEMA==false && InpUseADX==true && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && adxBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && adxSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();    }
         }
       
        
      ////  EMA & ADX & BB  ///////////////////////////////////////////////////////////  
         if(InpUseRSI==false && InpUseEMA==true && InpUseADX==true && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(emaBuyCondition() && adxBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(emaSellCondition() && adxSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();    }
         }
        
      
      ////  RSI & EMA & BB  ///////////////////////////////////////////////////////////   
         if(InpUseRSI==true && InpUseEMA==true && InpUseADX==false && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && emaBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && emaSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();    }
         }
       
        
      ////  RSI & EMA & ADX & BB  /////////////////////////////////////////////////////   
         if(InpUseRSI==true && InpUseEMA==true && InpUseADX==true && InpUseBB!=ENUM_OFF){
            //-- Buys
            if(rsiBuyCondition() && emaBuyCondition() && adxBuyCondition() && bbBuyCondition())
            {     randomEntryBuy(); entryBuyPosition();     }
            //-- Sells
            if(rsiSellCondition() && emaSellCondition() && adxSellCondition() && bbSellCondition())
            {    randomEntrySell(); entrySellPosition();    }
         }
       
      }
//________________________________________________________________________________________________________________________________________________________________ ENTRY POSITIONS CONDITIONS END ____/



//________________________________________________________________________________________________________________________________________________________________ SEQUENCE/DELAYED POSITIONS START ___/

   //Next Positions in Sequence 
                                            
      if(InpDelayTradeSeq == 0){
      
         // no news filter or session time
         if(InpUseNewsFilter==false && InpCustomSession==false && can_trade_newsWindow==true){
            if(InpUseRSI==true && cntBuy>0 && rsiBuyDoubleCheck())      {  sequenceBuys();      }
            if(InpUseRSI==true && cntSell>0 && rsiSellDoubleCheck())    {  sequenceSells();     }         
            if(InpUseRSI==false)                          {  sequenceBuys();  sequenceSells();  }
         }     
         // session time: inside & no news filter
         if(InpUseNewsFilter==false && InpCustomSession==true && can_trade==true && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // session time: outside/continue & no news filter
         if(InpCustomSession==true && InpEndSession==ENUM_CONT && can_trade==false && InpUseNewsFilter==false && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // session time: outside/pause & no news filter
         if(InpCustomSession==true && InpEndSession==ENUM_PAUSE && can_trade==false && InpUseNewsFilter==false && can_trade_newsWindow==true){
            // No trades
         }
         // news filter: outside & no session time
         if(InpUseNewsFilter==true && can_trade==true && InpCustomSession==false && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // news filter: inside/continue & no session time
         if(InpUseNewsFilter==true && InpNewsAction==ENUM_CONT && can_trade==false && InpCustomSession==false && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // news filter: inside/pause & no session time
         if(InpUseNewsFilter==true && InpNewsAction==ENUM_PAUSE && can_trade==false && InpCustomSession==false && can_trade_newsWindow==true){
            //if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            //if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            //if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
            // no trades
         }
         // Session time: Inside  &  News Filter Outside
         if(InpCustomSession==true && outsideCustomSession==false && can_trade==true && InpUseNewsFilter==true && insideNewsFilter==false && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // Session time: Inside  &  News Filter Inside / Continue
         if(InpCustomSession==true && outsideCustomSession==false && InpUseNewsFilter==true && insideNewsFilter==true && InpNewsAction==ENUM_CONT && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // Session time: Inside  &  News Filter Inside / Pause
         if(InpCustomSession==true && outsideCustomSession==false && InpUseNewsFilter==true && insideNewsFilter==true && InpNewsAction==ENUM_PAUSE){
            // no trades
         }      
         // session time: outside/continue  &  newsfilter outside
         if(InpCustomSession==true && InpEndSession==ENUM_CONT && outsideCustomSession==true && InpUseNewsFilter==true && insideNewsFilter==false && can_trade==false && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // session time: outside/continue  &  newsfilter inside / continue
         if(InpCustomSession==true && InpEndSession==ENUM_CONT && outsideCustomSession==true && InpUseNewsFilter==true && insideNewsFilter==true && InpNewsAction==ENUM_CONT && can_trade_newsWindow==true){
            if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
         }
         // session time: outside/continue  &  newsfilter inside / pause
         if(InpCustomSession==true && InpEndSession==ENUM_CONT && outsideCustomSession==true && InpUseNewsFilter==true && insideNewsFilter==true && InpNewsAction==ENUM_PAUSE){ // && can_trade==false && can_trade_newsWindow==true
            //if(InpUseRSI==true && rsiBuyDoubleCheck())   {  sequenceBuys();  }
            //if(InpUseRSI==true && rsiSellDoubleCheck())  {  sequenceSells();  }         
            //if(InpUseRSI==false)                         {  sequenceBuys();  sequenceSells();  }
            // no trades
         }
         // session time: outside/pause  &  news filter outside
         if(InpCustomSession==true && outsideCustomSession==true && InpEndSession==ENUM_PAUSE && InpUseNewsFilter==true && insideNewsFilter==false && can_trade==false && can_trade_newsWindow==true){
            // no trades
         }
      }
   
   //Delayed Trade Positions   
      if(InpDelayTradeSeq > 0 && can_trade==true){
      
      //Delayed Virtual Buys
         if(DT_entryBuyCount == 1 && DT_buyCount < InpDelayTradeSeq && bid <= nextBuyPrice){
            if(InpPipStepMulti == 0 || InpPipStepMulti == 1){
               last_buy_price = nextBuyPrice;
               nextBuyPrice = NormalizeDouble(ask - pipStep_points,_Digits);
            }
            else{
               last_buy_pipStep = last_buy_price - nextBuyPrice;  //last_buy_price - ask
               last_buy_price = nextBuyPrice; 
               buy_pipStep = NormalizeDouble(last_buy_pipStep * InpPipStepMulti,_Digits); 
               nextBuyPrice = NormalizeDouble(ask - buy_pipStep,_Digits);
               //last_buy_price = ask; 
            }
        //** 
            if(InpLotMulitiplier == 1){v_buy_lotSize = InpLotSize;}
            else{v_buy_lotSize = v_last_volume_buy * InpLotMulitiplier;}
            if(InpMaxLotSize > 0 && v_buy_lotSize > max_lotSize){v_buy_lotSize = max_lotSize;}        
            v_last_open_price_buy = ask;
            v_last_volume_buy = v_buy_lotSize;
            v_totalBuyPrice += (v_last_volume_buy * v_last_open_price_buy);
            v_totalBuyLots += v_last_volume_buy;
            v_breakEvenBuy = v_totalBuyPrice / v_totalBuyLots;
            v_buy_LP = v_breakEvenBuy + lp_points;
        //**          
            DT_buyCount++;
            Print("Magic Number: ",InpMagicNumber,"  --  DELAYED BUY SEQUENCE - Position ",DT_buyCount,"/",InpDelayTradeSeq,"  -  ask: ",ask,"  -  Next Buy Price: ",nextBuyPrice,"  --");
         }
         
      //Delayed Virtual Sells
         if(DT_entrySellCount == 1 && DT_sellCount < InpDelayTradeSeq && bid >= nextSellPrice){          
            if(InpPipStepMulti == 0 || InpPipStepMulti == 1){
               last_sell_price = nextSellPrice;
               nextSellPrice = NormalizeDouble(bid + pipStep_points,_Digits);  //nextSellPrice + pipStep_points,_Digits
            }
            else{
               last_sell_pipStep = nextSellPrice - last_sell_price;  //bid - last_sell_price;
               last_sell_price = nextSellPrice;
               sell_pipStep = NormalizeDouble(last_sell_pipStep * InpPipStepMulti,_Digits);
               nextSellPrice = NormalizeDouble(bid + sell_pipStep,_Digits);  //nextSellPrice + sell_pipStep,_Digits
               //last_sell_price = bid;
            }
        //**
            if(InpLotMulitiplier == 1){v_sell_lotSize = InpLotSize;}
            else{v_sell_lotSize = v_last_volume_sell * InpLotMulitiplier;}
            if(InpMaxLotSize > 0 && v_sell_lotSize > max_lotSize){v_sell_lotSize = max_lotSize;}        
            v_sell_lotSize = InpLotSize;
            v_last_open_price_sell = bid;
            v_last_volume_sell = v_sell_lotSize;
            v_totalSellPrice += (v_last_volume_sell * v_last_open_price_sell);
            v_totalSellLots += v_last_volume_sell;
            v_breakEvenSell = v_totalSellPrice / v_totalSellLots;
            v_sell_LP = v_breakEvenSell - lp_points;
        //**            
            DT_sellCount++;
            Print("Magic Number: ",InpMagicNumber,"  --  DELAYED SELL SEQUENCE - Position ",DT_sellCount,"/",InpDelayTradeSeq,"  -  bid: ",bid,"  -  Next Sell Price: ",nextSellPrice,"  --");   
         }
         
   
      //Real Positions After Delay    
       
      //Real Buys              && DT_entryBuyCount == 1
         if(can_trade == true  && DT_buyCount == InpDelayTradeSeq && ask <= nextBuyPrice && time_now > next_buy_time && can_trade_newsWindow==true){
            if(InpUseRSI==false){
               if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==false){RealBuy();}
               else if(InpUseADX==true && InpADXCheck==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealBuy();}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealBuy();}
                        
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Buy Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==false){Print("First Real Buy Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Buy Trade Not Executed.. adx & ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Buy Trade Not Executed.. ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Buy Trade Not Executed.. adx double check failed.");}
               
               else{RealBuy();}
            }
            if(InpUseRSI==true && rsiBuyDoubleCheck()){
               if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==false){RealBuy();}
               else if(InpUseADX==true && InpADXCheck==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealBuy();}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealBuy();}
                        
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Buy Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==false){Print("First Real Buy Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Buy Trade Not Executed.. adx & ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Buy Trade Not Executed.. ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Buy Trade Not Executed.. adx double check failed.");}
               
               else{RealBuy();}
            }         
         }
   
      //Real Sells            && DT_entrySellCount == 1
         if(can_trade == true && DT_sellCount == InpDelayTradeSeq && bid >= nextSellPrice && time_now > next_sell_time && can_trade_newsWindow==true){
            if(InpUseRSI==false){
               if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==false){RealSell();}
               else if(InpUseADX==true && InpADXCheck==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealSell();}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealSell();}
                        
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Sell Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==false){Print("First Real Sell Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Sell Trade Not Executed.. adx & ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Sell Trade Not Executed.. ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Sell Trade Not Executed.. adx double check failed.");}
               
               else{RealSell();}         
            }
            if(InpUseRSI==true && rsiSellDoubleCheck()){
               if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==false){RealSell();}
               else if(InpUseADX==true && InpADXCheck==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealSell();}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==true){RealSell();}
                        
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Sell Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==false){Print("First Real Sell Trade Not Executed.. adx double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Sell Trade Not Executed.. adx & ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==true && InpUseEMA==true && InpEMACheck==true && ema_check==false){Print("First Real Sell Trade Not Executed.. ema double check failed.");}
               else if(InpUseADX==true && InpADXCheck==true && adx_check==false && InpUseEMA==true && InpEMACheck==true && ema_check==true){Print("First Real Sell Trade Not Executed.. adx double check failed.");}
               
               else{RealSell();}         
            }         
         }
      }
   }

//________________________________________________________________________________________________________________________________________________________________ SEQUENCE/DELAYED POSITIONS END ___/   

////  TRAILING STOP  ///////////////////////////////////////////////////////////
   if(fixed_SLTP == false){
      //Check Every Tick
      if(InpLPCheck == ENUM_TICK && can_trade_newsWindow==true){
         if(cntBuy > 0 && buy_LP > 0 && bid >= buy_TS_check){
            checkTrailingSLBuy(bid);
            Print("BUY TRAILING STOP ACTIVATED AT BID: ",bid," - BUY LP: ",buy_LP);
            buy_TS_check = bid + tsPips_points;
            entryBuyCount = 0;
            DT_buyCount = 0;
         }
         if(cntSell > 0 && sell_LP > 0 && ask <= sell_TS_check){
            checkTrailingSLSell(ask);
            Print("SELL TRAILING STOP ACTIVATED AT ASK: ",ask," - SELL LP: ",sell_LP);
            sell_TS_check = ask - tsPips_points;
            entrySellCount = 0;
            DT_sellCount = 0;
         }
      }
      //Check M1 CLose
      if(InpLPCheck == ENUM_M1CLOSE && can_trade_newsWindow==true){
         if(cntBuy > 0 && buy_LP > 0 && m1_close_price >= buy_TS_check){
            checkTrailingSLBuy(bid);
            Print("BUY TRAILING STOP ACTIVATED AT M1 CANDLE CLOSE: ",m1_close_price," - BUY LP: ",buy_LP);
            buy_TS_check = m1_close_price + tsPips_points;
         }
         if(cntSell > 0 && sell_LP > 0 && m1_close_price <= sell_TS_check){
            checkTrailingSLSell(ask);
            Print("SELL TRAILING STOP ACTIVATED AT M1 CANDLE CLOSE: ",m1_close_price," - SELL LP: ",sell_LP);
            sell_TS_check = m1_close_price - tsPips_points;
         }
      }
   }  
   //virtual LP close
   if(InpDelayTradeSeq > 0 && DT_buyCount > 0){
      if(bid >= v_buy_LP){
         DT_buyCount = 0;
         DT_entryBuyCount = 0;
         v_totalBuyLots = 0;
         v_totalBuyPrice = 0;
         Print("--  DELAYED BUY SEQUENCE CLOSED BY VIRTUAL LP @ ",v_buy_LP,"  --");
      }
   }
   if(InpDelayTradeSeq > 0 && DT_sellCount > 0){
      if(ask <= v_sell_LP){
         DT_sellCount = 0;
         DT_entrySellCount = 0;
         v_totalSellLots = 0;
         v_totalSellPrice = 0;
         Print("--  DELAYED SELL SEQUENCE CLOSED BY VIRTUAL LP @ ",v_sell_LP,"  --");
      }
   }

////  CLOSING POSITIONS  ///////////////////////////////////////////////////////
   // closing at the end of custom session
   if(InpCustomSession){
      if((InpEndSession == ENUM_CLOSE && can_trade == false && (cntBuy > 0 || DT_buyCount > 0)) ||
         (InpEndSession == ENUM_CLOSE && can_trade == false && (cntSell > 0 || DT_sellCount > 0))){
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         if(DT_buyCount > 0){DT_entryBuyCount = 0; DT_buyCount = 0; v_totalBuyLots = 0; v_totalBuyPrice = 0; ObjectDelete(0,v_lpBuy);}
         if(DT_sellCount > 0){DT_entrySellCount = 0; DT_sellCount = 0; v_totalSellLots = 0; v_totalSellPrice = 0; ObjectDelete(0,v_lpSell);}
         Print("Magic Number: ",InpMagicNumber,"  --  End of Custom Trading Session - Closing Any Open Posiitons  --");
      }
      if(((InpEndSession == ENUM_CONT || InpEndSession == ENUM_PAUSE) && can_trade == false && DT_buyCount > 0) ||
         ((InpEndSession == ENUM_CONT || InpEndSession == ENUM_PAUSE) && can_trade == false && DT_sellCount > 0)){
         if(cntBuy==0 && DT_buyCount > 0){
            DT_entryBuyCount = 0; DT_buyCount = 0; v_totalBuyLots = 0; v_totalBuyPrice = 0; ObjectDelete(0,v_lpBuy);
            Print("Magic Number: ",InpMagicNumber,"  --  End of Custom Trading Session - Closing Current Delayed BUY Positions  --");
         }
         if(cntSell==0 && DT_sellCount > 0){
            DT_entrySellCount = 0; DT_sellCount = 0; v_totalSellLots = 0; v_totalSellPrice = 0; ObjectDelete(0,v_lpSell);
            Print("Magic Number: ",InpMagicNumber,"  --  End of Custom Trading Session - Closing Current Delayed SELL Positions  --");
         }
      }
   }
   // closing for start of news filter session 
   if(InpUseNewsFilter){
      if((InpNewsAction==ENUM_CLOSE && insideNewsFilter==true && (cntBuy > 0 || DT_buyCount > 0)) ||
         (InpNewsAction==ENUM_CLOSE && insideNewsFilter==true && (cntSell > 0 || DT_sellCount > 0))){
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         if(DT_buyCount > 0){DT_entryBuyCount = 0; DT_buyCount = 0; v_totalBuyLots = 0; v_totalBuyPrice = 0;  ObjectDelete(0,v_lpBuy);}
         if(DT_sellCount > 0){DT_entrySellCount = 0; DT_sellCount = 0; v_totalSellLots = 0; v_totalSellPrice = 0;  ObjectDelete(0,v_lpSell);}
         Print("Magic Number: ",InpMagicNumber,"  --  News Filter Active - Closing Any Open Posiitons  --");  
      }
      if(((InpNewsAction==ENUM_CONT || InpNewsAction==ENUM_PAUSE) && insideNewsFilter==true && DT_buyCount > 0) ||
         ((InpNewsAction==ENUM_CONT || InpNewsAction==ENUM_PAUSE) && insideNewsFilter==true && DT_sellCount > 0)){
         if(cntBuy==0 && DT_buyCount > 0){
            DT_entryBuyCount = 0; DT_buyCount = 0; v_totalBuyLots = 0; v_totalBuyPrice = 0;  ObjectDelete(0,v_lpBuy);
            Print("Magic Number: ",InpMagicNumber,"  --  End of Custom Trading Session - Closing Current Delayed BUY Positions  --");
         }
         if(cntSell==0 && DT_sellCount > 0){
            DT_entrySellCount = 0; DT_sellCount = 0; v_totalSellLots = 0; v_totalSellPrice = 0;  ObjectDelete(0,v_lpSell);
            Print("Magic Number: ",InpMagicNumber,"  --  End of Custom Trading Session - Closing Current Delayed SELL Positions  --");
         }  
      }
   }
   
////  MAX TRADE DURATION  ////////////////////////////////////////////////////   
   if(IsTester && InpMaxTradeDuration > 0){
   
      int H1_bars = iBars(_Symbol,PERIOD_H1);
      if(H1_bars != H1_bars_total){
         H1_bars_total = H1_bars;
         
         int posTotal = PositionsTotal();
         for(int i=posTotal-1; i>=0; i--){
            ulong ticket = PositionGetTicket(i);
            if(ticket <= 0){
               Print("Failed to get position ticket.");
            }
            if(!PositionSelectByTicket(ticket)){
               Print("Failed to select position.");
            }
            long time;
            if(!PositionGetInteger(POSITION_TIME,time)){
               Print("Failed to get position time.");
            }
            if(time_now - time >= InpMaxTradeDuration * 60 * 60){
               TesterStop();
            }
         } 
      }
   }
   
////  EQUITY PROTECTION  ////////////////////////////////////////////////////////////////
   
   //reset epHit boolean
   if(epHit==true && time_now >= eaRestartTime){
      epHit = false;
   }  
   if(profitReached==true && time_now >= eaRestartTime){
      totalDailyProfit = 0;
      profitReached = false;
      runningPL = 0;   
   }  

   //max loss close set file                                                                          //***  To block new sequences opening after EP hit til next day restart time
   if(InpMaxLoss>0 && epHit==false){                                                                  //***  set new variale called new_sequence and equal it to InpNewSequence
      double balanceCutoff = NormalizeDouble(accountInfo.Balance()-InpMaxLoss,2);                     //***  set it to false when EP hit, set to true when time_now > eaRestartTime & change entries to new variable
      if(accountInfo.Equity() <= balanceCutoff){
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         epHit = true;
         eaRestartTime = day_end + PeriodSeconds(PERIOD_H1);
         
      }
   }
   //max loss close global
   if(InpGlobalStop>0 && epHit==false){
      double globalCutoff = NormalizeDouble(accountInfo.Balance()-InpGlobalStop,2);
      if(accountInfo.Equity() <= globalCutoff){
         globalClosePositions();
         epHit = true;
         eaRestartTime = day_end + PeriodSeconds(PERIOD_H1); 
      }
   }
   //close daily profit target
   if(InpDailyProfit > 0){

      runningPL = RunningProfitLoss();
   
      if(totalDailyProfit + runningPL >= InpDailyProfit){ // || (totalDailyProfit >= InpDailyProfit) || (accountInfo.Equity() >= accountInfo.Balance() + InpDailyProfit)
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         can_trade = false;
         profitReached = true;
         eaRestartTime = day_end + PeriodSeconds(PERIOD_H1);
      }
   }  
   

//-- reset LP line if input is changed                             ***** CODE NOT WORKING, LP RESETS TO 0 WHEN LP INPUT IS CHANGED LIVE ***********
   //if((cntBuy > 0 && buy_LP==0) || (cntSell > 0 && sell_LP==0)){
   if(input_changed == true){ 
      ulong    ticket=0;
      double   price; 
      string   symbol; 
      long     type; 
      double   volume;
      ulong    magic;
      for(int i=0; i<PositionsTotal(); i++){
         price    = PositionGetDouble(POSITION_PRICE_OPEN);
         symbol   = PositionGetString(POSITION_SYMBOL);
         type     = PositionGetInteger(POSITION_TYPE);
         volume   = PositionGetDouble(POSITION_VOLUME);
         magic    = PositionGetInteger(POSITION_MAGIC);
         if(symbol==_Symbol && magic==InpMagicNumber){
         
            if(cntBuy > 0){ // && buy_LP == 0
               if(type==DEAL_TYPE_BUY){
                  if(cntBuy > 1){
                     last_open_price_buy = price;
                     last_volume_buy = volume;
                     totalBuyPrice += (last_volume_buy*last_open_price_buy);
                     totalBuyLots += last_volume_buy;
                     breakEvenLineBuy = totalBuyPrice/totalBuyLots;
                     buy_LP = NormalizeDouble(breakEvenLineBuy + lp_points,_Digits);
                     buy_TS_check = buy_LP;
                     nextBuyPrice = NormalizeDouble(price - pipStep_points,_Digits);
                  }
                  else {
                     buy_LP = NormalizeDouble(price + lp_points,_Digits);
                     nextBuyPrice = NormalizeDouble(price - pipStep_points,_Digits);
                  }
               }
            }       
            if(cntSell > 0){ // && sell_LP == 0 
               if(type==DEAL_TYPE_SELL){
                  if(cntSell > 1){
                     last_open_price_sell = price;
                     last_volume_sell = volume;
                     totalSellPrice += (last_volume_sell*last_open_price_sell);
                     totalSellLots += last_volume_sell;
                     breakEvenLineSell = totalSellPrice/totalSellLots;
                     sell_LP = NormalizeDouble(breakEvenLineSell - lp_points,_Digits);
                     sell_TS_check = sell_LP;
                     nextSellPrice = price + pipStep_points;
                  }
                  else{
                     sell_LP = NormalizeDouble(price - lp_points,_Digits);
                     nextSellPrice = price + pipStep_points;
                  }
               }
            }
         } 
      }
      input_changed = false;
   }


////  OBJECT CREATE  ///////////////////////////////////////////////////////////

   if(!fixed_SLTP){
      if(cntBuy > 0){
         objectFull(beBuy,OBJ_HLINE,time_now,breakEvenLineBuy,clrMediumSpringGreen,STYLE_DOT);
         objectFull(lpBuy,OBJ_HLINE,time_now,buy_LP,clrMediumSpringGreen,STYLE_SOLID);
      }
      if(cntSell > 0){
         objectFull(beSell,OBJ_HLINE,time_now,breakEvenLineSell,clrMediumSpringGreen,STYLE_DOT);
         objectFull(lpSell,OBJ_HLINE,time_now,sell_LP,clrMediumSpringGreen,STYLE_SOLID);
      }
   }
   if(DT_buyCount > 0 && cntBuy == 0){
      //objectFull(v_beBuy,OBJ_HLINE,time_now,v_breakEvenBuy,clrGreenYellow,STYLE_DASHDOT);
      objectFull(v_lpBuy,OBJ_HLINE,time_now,v_buy_LP,clrMediumSpringGreen,STYLE_DASHDOTDOT);
   }
   if(DT_sellCount > 0 && cntSell == 0){
      //objectFull(v_beSell,OBJ_HLINE,time_now,v_breakEvenSell,clrCornflowerBlue,STYLE_DASHDOT);
      objectFull(v_lpSell,OBJ_HLINE,time_now,v_sell_LP,clrMediumSpringGreen,STYLE_DASHDOTDOT);
   }
   if(InpUseNewsWindow==true){
      
   }
   
   if(cntBuy == 0){ObjectDelete(0,beBuy); ObjectDelete(0,lpBuy);}
   if(cntSell == 0){ObjectDelete(0,beSell); ObjectDelete(0,lpSell);}
   if(DT_buyCount == 0 || cntBuy > 0){ObjectDelete(0,v_beBuy); ObjectDelete(0,v_lpBuy);}
   if(DT_sellCount == 0 || cntSell > 0){ObjectDelete(0,v_beSell); ObjectDelete(0,v_lpSell);}


////  GUI PANEL VARIABLES  ////////////////////////////////////////////////////////
   if(InpShowPanel){
      if(balance != accountInfo.Balance()){
         balance = accountInfo.Balance();
         ObjectSetString(0,cBalC,OBJPROP_TEXT,DoubleToString(balance,2));
      }
      if(InpCustomSession){
         if(time_now > nextSeshCheck){
            ObjectSetString(0,sesh1,OBJPROP_TEXT,customSessionString());
            nextSeshCheck = iTime(_Symbol,PERIOD_D1,0) + PeriodSeconds(PERIOD_D1);
         }      
      }     
      ObjectSetString(0,currTime,OBJPROP_TEXT,TimeToString(TimeCurrent(),TIME_MINUTES|TIME_SECONDS));
      ObjectSetString(0,cEquityC,OBJPROP_TEXT,DoubleToString(accountInfo.Equity(),2));
      ObjectSetString(0,atrC,OBJPROP_TEXT,DoubleToString(atr_buffer[0]/_Point*0.1,2));
      if(InpCompound){
         if(accountInfo.Balance() > 100000){
            double objLots = NormalizeDouble(accountInfo.Balance()/100000*InpLotSize,2);
            lots_str = DoubleToString(objLots,2);
            ObjectSetString(0,lotsC,OBJPROP_TEXT,lots_str);
            ObjectSetString(0,mLotC,OBJPROP_TEXT,DoubleToString(max_lotSize,2));
         } else {
            ObjectSetString(0,lotsC,OBJPROP_TEXT,DoubleToString(InpLotSize,2));
            ObjectSetString(0,mLotC,OBJPROP_TEXT,DoubleToString(max_lotSize,2));
         }
         
      }
   }
   
   
   
}


//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

////  COUNT OPEN POSITIONS  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool CountOpenPositions(int &posBuy, int &posSell){
   
   posBuy   = 0;
   posSell  = 0;
   int total = PositionsTotal();
   for(int i=total-1; i>=0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0){
         Print("Failed to get position ticket.");
         return false;
      }
      if(!PositionSelectByTicket(ticket)){
         Print("Failed to select position.");
         return false;
      }
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){
         Print("Failed to get position magic number.");
         return false;
      }
      //if magic number of a position belongs to this ea
      if(magic == InpMagicNumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return false;}
         if(type == POSITION_TYPE_BUY){posBuy++;}
         if(type == POSITION_TYPE_SELL){posSell++;}
      }
   }
   
   return true;
}





////  TRADE TRANSACTION FUNCTION  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result){

//---get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
//---if transaction is result of addition TO the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD){
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      long     deal_type         =-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal)){
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);         
      }
      else
         return;
         
      day_start = iTime(_Symbol,PERIOD_D1,0);
      day_end = day_start + PeriodSeconds(PERIOD_D1);   
         
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_entry==DEAL_ENTRY_IN && (deal_type==DEAL_TYPE_BUY || DEAL_TYPE_SELL)){
         
            if(deal_type==DEAL_TYPE_BUY){
               last_open_price_buy = deal_price;
               last_volume_buy = deal_volume;
            }
            if(deal_type==DEAL_TYPE_SELL){
               last_open_price_sell = deal_price;
               last_volume_sell = deal_volume;
            }
            
            last_open_price = deal_price;
            last_volume = deal_volume;
            last_position_type = (deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_BUY:POSITION_TYPE_SELL; 
            
         }
         else if(deal_entry==DEAL_ENTRY_OUT){
            last_open_price = 0.0;
            last_volume = 0.0;                              
            last_position_type = -1;
            
            if(deal_time >= day_start && deal_time < day_end){
               runningPL = 0;
               totalDailyProfit += deal_profit;
            }             
         }
      }
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_BUY && deal_entry==DEAL_ENTRY_IN){
            totalBuyPrice += (last_volume_buy*last_open_price_buy);
            totalBuyLots += last_volume_buy;
            breakEvenLineBuy = totalBuyPrice/totalBuyLots;
            buy_LP = breakEvenLineBuy + lp_points;
            buy_TS_check = buy_LP;
         }
      }
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_SELL && deal_entry==DEAL_ENTRY_IN){
            totalSellPrice += (last_volume_sell*last_open_price_sell);
            totalSellLots += last_volume_sell;
            breakEvenLineSell = totalSellPrice/totalSellLots;
            sell_LP = breakEvenLineSell - lp_points;
            sell_TS_check = sell_LP;
         }
      }
      if(deal_entry == DEAL_ENTRY_OUT && (deal_reason == DEAL_REASON_SL || deal_reason == DEAL_REASON_TP)){
         if(deal_type == DEAL_TYPE_SELL){
            entryBuyCount = 0;
            DT_buyCount = 0;
         }
         if(deal_type == DEAL_TYPE_BUY){
            entrySellCount = 0;
            DT_sellCount = 0;
         }
      }         
   }   
}

////  RETURN CUSTOMSESSION AS STRING  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
string customSessionString(){
   switch (today.day_of_week) {
      case 1:
         return InpMonday;
         break;
      case 2:
         return InpTuesday;
         break;
      case 3:
         return InpWednesday;
         break;
      case 4:
         return InpThursday;
         break;
      case 5:
         return InpFriday;
         break;
      default:
         return "00:00-00:00";
         break;
   }
}
////  RUNNING PROFIT & LOSS  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double RunningProfitLoss(){
   int err=0;
   double profit=0;
   
   for(int i=PositionsTotal()-1; i >= 0; i--){
      if(positionInfo.SelectByIndex(i)){
         if(positionInfo.Symbol()==_Symbol && positionInfo.Magic()==InpMagicNumber){
            profit += positionInfo.Profit();
         }
      }
      else {
         Print("Failed to Select Order.");
         err = GetLastError();
         Print("Encountered an error while seleting order ,error number "+(string)err);
         ResetLastError();
      }
   }
   return profit;
}


////  RANDOM NUMBER GENERATOR  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int MathRandInt(const int min, const int max)
  {
   int RAND_MAX = 32767;
   int range = max - min;
   if (range > RAND_MAX) range = RAND_MAX;
   int randMin = RAND_MAX % range;
   int rand;  do{ rand = MathRand(); }while (rand <= randMin);
   return rand % range + min;
  }
  
  
////  CUSTOM SESSION TIMES  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void customSesion(datetime start, datetime stop){
   time_now = TimeCurrent();
   if(start < stop && time_now >= start && time_now < stop){can_trade = true; outsideCustomSession = false;}  // enter outsidescustomsession = true/false
   if(start < stop && time_now < start){can_trade = false; outsideCustomSession = true;}
   if(start < stop && time_now >= stop){can_trade = false; outsideCustomSession = true;}  
   if(start > stop && time_now < stop){can_trade = true; outsideCustomSession = false;}
   if(start > stop && time_now >= start){can_trade = true; outsideCustomSession = false;}
   if(start > stop && time_now >= stop && time_now < start){can_trade = false; outsideCustomSession = true;}   
}


//// OBJECT CREATE  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void objectFull(string name, ENUM_OBJECT type,datetime time, double price, color objColor, ENUM_LINE_STYLE style){
   ObjectCreate(0,name,type,0,time,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,objColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
}


//// CLOSE ALL POSITIONS  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(positionInfo.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(positionInfo.Symbol()==_Symbol && positionInfo.Magic()==InpMagicNumber)
            if(positionInfo.PositionType()==pos_type) // gets the position type
               trade.PositionClose(positionInfo.Ticket()); // close a position by the specified symbol
   }
   
//// GLOBAL CLOSE POSITIONS  ////////////////////////////////////////////////////////////////////////////////
void globalClosePositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(positionInfo.SelectByIndex(i))     // selects the position by index for further access to its properties
         trade.PositionClose(positionInfo.Ticket()); // close a position by the specified symbol
   }   


////  TRAILING STOP  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void  checkTrailingSLBuy(double bid_price){
   if(InpTrailingStop==0){
      ClosePositions(POSITION_TYPE_BUY);
      return;
   }
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);            
      if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC);
         double volume = PositionGetDouble(POSITION_VOLUME);         
         buy_TS = NormalizeDouble(bid_price - ts_points,_Digits);
         if(magic==InpMagicNumber && type==POSITION_TYPE_BUY){
            trade.PositionModify(positionTicket,buy_TS,0); 
         }        
      }         
   }                     
}

void  checkTrailingSLSell(double ask_price){
   if(InpTrailingStop==0){
      ClosePositions(POSITION_TYPE_SELL);
      return;
   }
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);          
      if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC);
         double volume = PositionGetDouble(POSITION_VOLUME);
         double pos_SL = PositionGetDouble(POSITION_SL);
         sell_TS = NormalizeDouble(ask_price + ts_points,_Digits);
         if(magic==InpMagicNumber && type==POSITION_TYPE_SELL){
            trade.PositionModify(positionTicket,sell_TS,0);
         } 
      }     
   }
}

////  ENTRY BUY/SELL POSITIONS  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void entryBuyPosition(){

   if(sameSymBuy == true){
      new_sequence = false;
      if(time_now > samePair_next_check){
         Alert(_Symbol," - Same Pair Filter |  MN: ",InpMagicNumber," failed to open buy position due to MN: ",buyMagic);
         samePair_next_check = time_now + PeriodSeconds(PERIOD_M5);
      }
   }
   else{new_sequence = true;}
   if(epHit==true || profitReached==true){new_sequence = false;}
   if(InpNewSeq == false){new_sequence = false;}
   
   if((new_sequence == true && InpTradeDirection == ENUM_LS && cntBuy == 0 && time_now > next_buy_time) || (new_sequence == true && InpTradeDirection == ENUM_L && cntBuy == 0 && time_now > next_buy_time)){
      if(InpDelayTradeSeq == 0 && entryBuyCount == 0 && sameSymBuy==false){
         if(InpStopLoss==0){buy_SL = 0;}
         else{buy_SL = ask - sl_points; fixed_SLTP = true;}
         if(InpTakeProfit==0){buy_TP = 0;}
         else{buy_TP = ask + tp_points;}
         if(InpCompound==false){buy_lotSize = InpLotSize;}
         if(InpCompound==true){buy_lotSize = NormalizeDouble(InpLotSize * (accountInfo.Balance() / 100000),2);}
         if(InpMaxLotSize>0 && buy_lotSize > max_lotSize){buy_lotSize = max_lotSize;}
         if(buy_lotSize > symbol_maxVol){buy_lotSize = symbol_maxVol;}

         seq_buyCount++;
         if(InpTradeComment==""){buy_tradeComment = IntegerToString(seq_buyCount);}
         else{buy_tradeComment = IntegerToString(seq_buyCount)+"_"+InpTradeComment;}
            
         trade.Buy(buy_lotSize,_Symbol,ask,buy_SL,buy_TP,buy_tradeComment);

         CountOpenPositions(cntBuy,cntSell);
         
         if(cntBuy == 1){
            last_buy_price = ask;
            last_buy_vol = buy_lotSize;
            last_buy_time = time_now;
            nextBuyPrice = NormalizeDouble(ask - pipStep_points,_Digits);
            entryBuyCount = 1;
            buy_check_count++;
            Print("Magic Number: ",InpMagicNumber,"  --  Executed Buy... ",buy_lotSize," Lots at ask: ",ask,"  -  Next Buy Price: ",nextBuyPrice,"  --");
            if(InpMinSeconds > 0){
               next_buy_time = last_buy_time + InpMinSeconds;
            }
         }
         else{
            Print("Magic Number: ",InpMagicNumber,"  |  Failed to open Buy Position. Trying again...");
            seq_buyCount--;
         }
      }

      if(InpDelayTradeSeq > 0 && DT_entryBuyCount == 0){
         last_buy_price = ask;
         //breakEvenLineBuy = ask;
         //buy_LP = ask + lp_points;
     //**    
         v_buy_lotSize = InpLotSize;
         v_last_open_price_buy = ask;
         v_last_volume_buy = v_buy_lotSize;
         v_totalBuyPrice += (v_last_volume_buy * v_last_open_price_buy);
         v_totalBuyLots += v_last_volume_buy;
         v_breakEvenBuy = v_totalBuyPrice / v_totalBuyLots;
         v_buy_LP = v_breakEvenBuy + lp_points;
     //**    
         nextBuyPrice = NormalizeDouble(ask - pipStep_points,_Digits);
         DT_buyCount++;
         DT_entryBuyCount=1;
         
         Print("Magic Number: ",InpMagicNumber,"  --  DELAYED BUY SEQUENCE - Position ",DT_buyCount,"/",InpDelayTradeSeq,"  -  ask: ",ask,"  -  Next Buy Price: ",nextBuyPrice,"  --");
      }
   }    
}

void entrySellPosition(){

   if(sameSymSell == true){
      new_sequence = false;
      if(time_now > samePair_next_check){
         Alert(_Symbol," - Same Pair Filter |  MN: ",InpMagicNumber," failed to open sell position due to MN: ",sellMagic);
         samePair_next_check = time_now + PeriodSeconds(PERIOD_M5);
      }
   }
   else{new_sequence = true;}
   if(epHit==true || profitReached==true){new_sequence = false;}
   if(InpNewSeq == false){new_sequence = false;}
   
   if((new_sequence == true && InpTradeDirection == ENUM_LS && cntSell == 0 && time_now > next_sell_time) ||(new_sequence == true && InpTradeDirection == ENUM_S && cntSell == 0 && time_now > next_sell_time)){
      if(InpDelayTradeSeq == 0 && entrySellCount == 0 && sameSymSell==false){
         if(InpStopLoss == 0){sell_SL = 0;}
         else{sell_SL = bid + sl_points; fixed_SLTP = true;}
         if(InpTakeProfit == 0){sell_TP = 0;}
         else{sell_TP = bid - tp_points;}
         if(InpCompound == false){sell_lotSize = InpLotSize;}
         if(InpCompound == true){sell_lotSize = NormalizeDouble(InpLotSize * (accountInfo.Balance() / 100000),2);}
         if(InpMaxLotSize > 0 && sell_lotSize > max_lotSize){sell_lotSize = max_lotSize;}
         if(sell_lotSize > symbol_maxVol){sell_lotSize = symbol_maxVol;}
         
         seq_sellCount++;
         if(InpTradeComment==""){sell_tradeComment = IntegerToString(seq_sellCount);}
         else{sell_tradeComment = IntegerToString(seq_sellCount)+"_"+InpTradeComment;}

         trade.Sell(sell_lotSize,_Symbol,bid,sell_SL,sell_TP,sell_tradeComment);

         CountOpenPositions(cntBuy,cntSell);
         
         if(cntSell == 1){
            last_sell_price = bid;
            last_sell_vol = sell_lotSize;
            last_sell_time = time_now;
            nextSellPrice = NormalizeDouble(bid + pipStep_points,_Digits);
            entrySellCount = 1;
            sell_check_count++;
            Print("Magic Number: ",InpMagicNumber,"  --  Executed Sell... ",sell_lotSize," Lots at bid: ",bid,"  -  Next Sell Price: ",nextSellPrice,"  --");
            if(InpMinSeconds > 0){
               next_sell_time = last_sell_time + InpMinSeconds;
            }
         }
         else{
            Print("Magic Number: ",InpMagicNumber,"  |  Failed to open Sell Position. Trying again...");
            seq_sellCount--;
         }
      }

      if(InpDelayTradeSeq > 0 && DT_entrySellCount == 0){
         last_sell_price = bid;
         //breakEvenLineSell = bid;
         //sell_LP = bid - lp_points;
     //**
         v_sell_lotSize = InpLotSize;
         v_last_open_price_sell = bid;
         v_last_volume_sell = v_sell_lotSize;
         v_totalSellPrice += (v_last_volume_sell * v_last_open_price_sell);
         v_totalSellLots += v_last_volume_sell;
         v_breakEvenSell = v_totalSellPrice / v_totalSellLots;
         v_sell_LP = v_breakEvenSell - lp_points;
     //**   
         nextSellPrice = NormalizeDouble(bid + pipStep_points,_Digits);
         DT_sellCount++;
         DT_entrySellCount = 1;
         Print("Magic Number: ",InpMagicNumber,"  --  DELAYED SELL SEQUENCE - Position ",DT_sellCount,"/",InpDelayTradeSeq,"  -  bid: ",bid,"  -  Next Sell Price: ",nextSellPrice,"  --");
      }
   }  
}


void randomEntryBuy(){
   if(InpRandEntry==true && rand_buyCount==0 && cntBuy==0){
      next_buy_time = time_now + MathRandInt(1,6);
      rand_buyCount=1;
   }
}

void randomEntrySell(){
   if(InpRandEntry==true && rand_sellCount==0 && cntSell==0){
      next_sell_time = time_now + MathRandInt(1,6);
      rand_sellCount=1;
   }
}


////  RSI DOUBLE CHECK EVERY TRADE  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool rsiBuyDoubleCheck(){
   CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
   //buys
   if(rsi_buffer[1] < rsiLower){
      return true;
   }
   return false;  
}
bool rsiSellDoubleCheck(){
   CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
   //buys
   if(rsi_buffer[1] > rsiUpper){
      return true;
   }
   return false;  
}

////  DOUBLE CHECK EMA FIRST REAL TRADE  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void emaDoubleCheck(){
//trend only
   if(InpEMARule == ENUM_TREND){
      //buys
      if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
         ema_check = true;
      }
      else{ema_check = false;}
      //sells
      if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
         ema_check = true;
      }
      else{ema_check = false;}
   } 
//range only        
   if(InpEMARule == ENUM_RANGE){
      if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
         (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
         (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
         (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
         ema_check = true;
      }
      else{ema_check = false;}
   }
//trend and range
   if(InpEMARule == ENUM_TRENDRANGE){
      //buys
      if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
         ema_check = true;
      }
      else{ema_check = false;}
      //sells
      if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
         ema_check = true;
      }    
      else{ema_check = false;}
      //range
      if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
         (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
         (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
         (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
         ema_check = true;
      }
      else{ema_check = false;}
   }
//counter trend only
   if(InpEMARule == ENUM_COUNTERTREND){
      //sells
      if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
         ema_check = true;
      }
      else{ema_check = false;}
      //buys
      if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
         ema_check = true;
      } 
      else{ema_check = false;}
   } 
}

//// ADX DOUBLE CHECK FIRST REAL TRADE  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void adxDoubleCheck(){
//trend only
   if(InpADXRule == ENUM_TREND){
      //buys
      if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
         adx_check = true;
      }
      else{adx_check = false;}
      //sells
      if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
         adx_check = true;
      }
      else{adx_check = false;}
   }
//range only
   if(InpADXRule == ENUM_RANGE){
      if(adx_main_buffer[1] < InpADXThreshold){
         adx_check = true;
      }
      else{adx_check = false;}
   }
//trend and range
   if(InpADXRule == ENUM_TRENDRANGE){
      if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
         adx_check = true;
      }
      else{adx_check = false;}
      if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
         adx_check = true;
      }
      else{adx_check = false;}
      if(adx_main_buffer[1] < InpADXThreshold){
         adx_check = true;
      }  
      else{adx_check = false;}
   }
//counter trend
   if(InpADXRule == ENUM_COUNTERTREND){
      //sells
      if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
         adx_check = true;
      }
      else{adx_check = false;}
      //buys
      if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
         adx_check = true;
      }
      else{adx_check = false;}
   }
}


////  FIRST REAL BUY  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void RealBuy(){
   if(InpStopLoss==0){buy_SL = 0;}
   else{buy_SL = ask - sl_points; fixed_SLTP = true;}
   if(InpTakeProfit==0){buy_TP = 0;}
   else{buy_TP = ask + tp_points;}
         
   if(InpLotMulitiplier == 1){buy_lotSize = InpLotSize;}
   else{buy_lotSize = NormalizeDouble(last_buy_vol * InpLotMulitiplier,2);}
   if(InpLotMulitiplier > 1 && cntBuy == 0){buy_lotSize = InpLotSize;}         
   if(InpMaxLotSize > 0 && buy_lotSize > max_lotSize){buy_lotSize = max_lotSize;}
   if(buy_lotSize > symbol_maxVol){buy_lotSize = symbol_maxVol;}
   last_buy_vol = buy_lotSize;
   
   seq_buyCount++;
   if(InpTradeComment==""){buy_tradeComment = IntegerToString(seq_buyCount);}
   else{buy_tradeComment = IntegerToString(seq_buyCount)+"_"+InpTradeComment;}
      
   trade.Buy(buy_lotSize,_Symbol,ask,buy_SL,buy_TP,buy_tradeComment);
   CountOpenPositions(cntBuy,cntSell);
    
   if(cntBuy > buy_check_count){         
      if(InpPipStepMulti == 0 || InpPipStepMulti == 1){
         nextBuyPrice = NormalizeDouble(ask - pipStep_points,_Digits);  //nextBuyPrice - pipStep_points,_Digits
      }
      else{
         //last_buy_pipStep = last_buy_price - nextBuyPrice;  //last_buy_price - ask;
         //last_buy_price = nextBuyPrice;
         //buy_pipStep = NormalizeDouble(last_buy_pipStep * InpPipStepMulti,_Digits);
         //if(InpPipStepMulti > 1 && buy_pipStep > maxPipStep_points){buy_pipStep = maxPipStep_points;}
         //if(InpPipStepMulti < 1 && buy_pipStep < minPipStep_points){buy_pipStep = minPipStep_points;} 
         //nextBuyPrice = NormalizeDouble(nextBuyPrice - buy_pipStep,_Digits);  //ask - buy_pipStep,_Digits
         ////last_buy_price = ask; 
      
         nextBuyPrice = NormalizeDouble(ask - pipStep_points,_Digits);  //ask - pipStep_points,_Digits
         last_buy_price = ask;
      }
      buy_LP = ask + lp_points;
      buy_TS_check = ask + lp_points; 
      buy_check_count++;
      entryBuyCount = 1;
      last_buy_time = time_now;
      if(InpMinSeconds > 0){
         next_buy_time = last_buy_time + InpMinSeconds;
      }                      
      if(InpMaxPositions > 1 && cntBuy < InpMaxPositions){Print("Magic Number: ",InpMagicNumber,"  --  Executed Buy... ",buy_lotSize," Lots at ask: ",last_buy_price,"  -  Next Buy Price: ",nextBuyPrice," - BUY LP: ",buy_LP,"  --");}                   
   }
   else{
      Print("Magic Number: ",InpMagicNumber,"  |  Failed to execute first real BUY position... Trying again.");
      seq_buyCount--;
   }           
}

////  FIRST REAL SELL  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void RealSell(){
   if(InpStopLoss == 0){sell_SL = 0;}
   else{sell_SL = bid + sl_points; fixed_SLTP = true;}
   if(InpTakeProfit == 0){sell_TP = 0;}
   else{sell_TP = bid - tp_points;}
         
   if(InpLotMulitiplier == 1){sell_lotSize = InpLotSize;}
   else{sell_lotSize = NormalizeDouble(last_sell_vol * InpLotMulitiplier,2);}
   if(InpLotMulitiplier > 1 && cntSell == 0){sell_lotSize = InpLotSize;}
   if(InpMaxLotSize > 0 && sell_lotSize > max_lotSize){sell_lotSize = max_lotSize;}
   if(sell_lotSize > symbol_maxVol){sell_lotSize = symbol_maxVol;}
   last_sell_vol = sell_lotSize;
   
   seq_sellCount++;
   if(InpTradeComment==""){sell_tradeComment = IntegerToString(seq_sellCount);}
   else{sell_tradeComment = IntegerToString(seq_sellCount)+"_"+InpTradeComment;}
   
   trade.Sell(sell_lotSize,_Symbol,bid,sell_SL,sell_TP,sell_tradeComment);
   
   CountOpenPositions(cntBuy,cntSell);
     
   if(cntSell > sell_check_count){          
      if(InpPipStepMulti == 0 || InpPipStepMulti == 1){
         nextSellPrice = NormalizeDouble(bid + pipStep_points,_Digits);  //nextsellprice + pipStep_points,_Digits
      }
      else{
         //last_sell_pipStep = nextSellPrice - last_sell_price; //bid - last_sell_price;
         //last_sell_price = nextSellPrice;
         //sell_pipStep = NormalizeDouble(last_sell_pipStep * InpPipStepMulti,_Digits);
         //if(InpPipStepMulti > 1 && sell_pipStep > maxPipStep_points){sell_pipStep = maxPipStep_points;}
         //if(InpPipStepMulti < 1 && sell_pipStep < minPipStep_points){sell_pipStep = minPipStep_points;}
         //nextSellPrice = NormalizeDouble(last_sell_price + sell_pipStep,_Digits);  //bid + sell_pipStep,_Digits
         //last_sell_price = bid;
         
         nextSellPrice = NormalizeDouble(bid + pipStep_points,_Digits);
         last_sell_price = bid;
      }
      sell_LP = bid - lp_points;
      sell_TS_check = bid - lp_points;
      sell_check_count++;
      entrySellCount = 1; 
      last_sell_time = time_now; 
      if(InpMinSeconds > 0){
         next_sell_time = last_sell_time + InpMinSeconds;
      }          
      if(InpMaxPositions > 1 && cntSell < InpMaxPositions){Print("Magic Number: ",InpMagicNumber,"  --  Executed Sell... ",sell_lotSize," Lots at bid: ",bid,"  -  Next Sell Price: ",nextSellPrice," - SELL LP: ",sell_LP,"  --");} //Print("pip step: ",sell_pipStep/_Point/10); 
   }         
   else{
      Print("Failed to execute real Sell Position... Trying again.");
      seq_sellCount--;
   }
}


////  SEQUENCE BUYS  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void sequenceBuys(){
   if(entryBuyCount == 1 && cntBuy > 0 && ask <= nextBuyPrice && time_now > next_buy_time){        
      if(InpLotMulitiplier == 1){buy_lotSize = NormalizeDouble(last_buy_vol,2);} //changes to las_buy_vol from InpLotSize as compounding owuld not work with lot multiplier of 1
      else{buy_lotSize = NormalizeDouble(last_buy_vol * InpLotMulitiplier,2);}
      if(InpMaxLotSize > 0 && buy_lotSize > max_lotSize){buy_lotSize = max_lotSize;}
      if(buy_lotSize > symbol_maxVol){buy_lotSize = symbol_maxVol;}
      last_buy_vol = buy_lotSize;
      double   target_buy_pipStep = NormalizeDouble(last_buy_price - nextBuyPrice,_Digits);  //ask - nextBuyPrice,_Digits
      
      //count current open buys
      CountOpenPositions(cntBuy,cntSell);
      int total_buys = cntBuy;
      
      seq_buyCount++;
      if(InpTradeComment==""){buy_tradeComment = IntegerToString(seq_buyCount);}
      else{buy_tradeComment = IntegerToString(seq_buyCount)+"_"+InpTradeComment;}
      
      trade.Buy(buy_lotSize,_Symbol,ask,0,0,buy_tradeComment);
      
      //check if new buy was executed
      CountOpenPositions(cntBuy,cntSell);
      if(cntBuy > total_buys){         
         if(InpPipStepMulti == 0 || InpPipStepMulti == 1){
            nextBuyPrice = NormalizeDouble(ask - pipStep_points,_Digits);  //nextBuyPrice - pipStep_points,_Digits
         }
         else{
            last_buy_pipStep = last_buy_price - nextBuyPrice;  //last_buy_price - ask;
            last_buy_price = ask;  //last_buy_price = nextBuyPrice;
            if(InpPipStepMulti < 1 && last_buy_pipStep > target_buy_pipStep){
               last_buy_pipStep = target_buy_pipStep;
            }          
            buy_pipStep = NormalizeDouble(last_buy_pipStep * InpPipStepMulti,_Digits);
            if(InpPipStepMulti > 1 && buy_pipStep > maxPipStep_points){buy_pipStep = maxPipStep_points;}
            if(InpPipStepMulti < 1 && buy_pipStep < minPipStep_points){buy_pipStep = minPipStep_points;}
            if(InpPipStepMulti == 1){buy_pipStep = pipStep_points;}
            Print("buy_pipStep: ",buy_pipStep);  
            nextBuyPrice = NormalizeDouble(ask - buy_pipStep,_Digits);  //nextBuyPrice - buy_pipStep,_Digits
            //last_buy_price = ask;
            //prev_buy_pipStep = buy_pipStep; 
         }
         last_buy_time = time_now;
         if(InpMinSeconds > 0){
            next_buy_time = last_buy_time + InpMinSeconds;
         }
         Print("Magic Number: ",InpMagicNumber,"  --  Executed Buy... ",buy_lotSize," Lots at ask: ",ask,"  -  Next Buy Price: ",nextBuyPrice,"  --");    
      }
      else {
         Print("Magic Number: ",InpMagicNumber,"  --  BUY Position Failed... attempting execution again.");
         seq_buyCount--;
      }
   }
}

////  SEQUENCE SELLS  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void sequenceSells(){
   if(entrySellCount == 1 && cntSell > 0 && bid >= nextSellPrice && time_now > next_sell_time){             // pip step is calculating based on previous step and not keeping in sequence with lot multiplier
      if(InpLotMulitiplier == 1){sell_lotSize = NormalizeDouble(last_sell_vol,2);}
      else{sell_lotSize = NormalizeDouble(last_sell_vol * InpLotMulitiplier,2);}
      if(InpMaxLotSize > 0 && sell_lotSize > max_lotSize){sell_lotSize = max_lotSize;}
      if(sell_lotSize > symbol_maxVol){sell_lotSize = symbol_maxVol;}
      last_sell_vol = sell_lotSize;
      double   target_sell_pipStep = NormalizeDouble(nextSellPrice - last_sell_price,2); 
      
      //counting open sell positions
      CountOpenPositions(cntBuy,cntSell);
      int total_sells = cntSell;
      
      seq_sellCount++;
      if(InpTradeComment==""){sell_tradeComment = IntegerToString(seq_sellCount);}
      else{sell_tradeComment = IntegerToString(seq_sellCount)+"_"+InpTradeComment;}
      
      trade.Sell(sell_lotSize,_Symbol,bid,0,0,sell_tradeComment);
      
      //checking if new sell position executed
      CountOpenPositions(cntBuy,cntSell);
      if(cntSell > total_sells){    
         if(InpPipStepMulti == 0 || InpPipStepMulti == 1){
            nextSellPrice = NormalizeDouble(bid + pipStep_points,_Digits);   //nextSellPrice + pipStep_points,_Digits
         }
         else{
            last_sell_pipStep = nextSellPrice - last_sell_price;      //bid - last_sell_price;
            last_sell_price = bid;  //last_sell_price = nextSellPrice;
            if(InpPipStepMulti < 1 && last_sell_pipStep > target_sell_pipStep){
               last_sell_pipStep = target_sell_pipStep;
            }
                           
            sell_pipStep = NormalizeDouble(last_sell_pipStep * InpPipStepMulti,_Digits);
            if(InpPipStepMulti > 1 && sell_pipStep > maxPipStep_points){sell_pipStep = maxPipStep_points;}
            if(InpPipStepMulti < 1 && sell_pipStep < minPipStep_points){sell_pipStep = minPipStep_points;}
            if(InpPipStepMulti == 1){sell_pipStep = pipStep_points;}
            nextSellPrice = NormalizeDouble(bid + sell_pipStep,_Digits);  //bid + sell_pipStep,_Digits
            //last_sell_price = bid;
            //prev_sell_pipStep = sell_pipStep;
         }
         last_sell_time = time_now;
         if(InpMinSeconds > 0){
            next_sell_time = last_sell_time + InpMinSeconds;
         }
         Print("Magic Number: ",InpMagicNumber,"  --  Executed Sell... ",sell_lotSize," Lots at bid: ",bid,"  -  Next Sell Price: ",nextSellPrice,"  --");
      }
      else {
         Print("Magic Number: ",InpMagicNumber,"  --  SELL Position Failed... attempting execution again.");
         seq_sellCount--;
      }
   }
}

////  RSI /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool rsiBuyCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
      //buys
      if(rsi_buffer[1] < rsiLower){
         return true;
      }
   }
   return false;
}
bool rsiSellCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
      //sells
      if(rsi_buffer[1] > rsiUpper){
         return true;
      }     
   }
   return false;
}

////  EMA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool emaBuyCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(emaF_handle,0,0,3,emaF_buffer);
      CopyBuffer(emaM_handle,0,0,3,emaM_buffer);
      CopyBuffer(emaS_handle,0,0,3,emaS_buffer);
   //trend only
      if(InpEMARule == ENUM_TREND){
         //buys
         if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
            return true;
         }
      } 
   //range only        
      if(InpEMARule == ENUM_RANGE){
         if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
            (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
            (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
            (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
            return true;
         }
      }
   //trend and range
      if(InpEMARule == ENUM_TRENDRANGE){
         //buys
         if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
            return true;
         }  
         //range
         if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
            (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
            (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
            (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
            return true;
         }
      }
   //Range & Counter Trend
      if(InpEMARule == ENUM_COUNTERRANGE){
         //buys
         if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
            return true;
         }       
         //range
         if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
            (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
            (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
            (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
            return true;
         }
      }
   //counter trend only
      if(InpEMARule == ENUM_COUNTERTREND){
         //buys
         if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
            return true;
         } 
      } 
   }
   return false;
}

bool emaSellCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(emaF_handle,0,0,3,emaF_buffer);
      CopyBuffer(emaM_handle,0,0,3,emaM_buffer);
      CopyBuffer(emaS_handle,0,0,3,emaS_buffer);
   //trend only
      if(InpEMARule == ENUM_TREND){
         //sells
         if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
            return true;
         }
      } 
   //range only        
      if(InpEMARule == ENUM_RANGE){
         if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
            (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
            (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
            (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
            return true;
         }
      }
   //trend and range
      if(InpEMARule == ENUM_TRENDRANGE){
         //sells
         if(emaS_buffer[1] > emaM_buffer[1] && emaM_buffer[1] > emaF_buffer[1]){
            return true;
         }    
         //range
         if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
            (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
            (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
            (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
            return true;
         };
      }
   //Range & Counter Trend
      if(InpEMARule == ENUM_COUNTERRANGE){
         //sells
         if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
            return true;
         }       
         //range
         if((emaS_buffer[1] < emaF_buffer[1] && emaF_buffer[1] < emaM_buffer[1]) ||
            (emaF_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaM_buffer[1]) ||
            (emaM_buffer[1] < emaS_buffer[1] && emaS_buffer[1] < emaF_buffer[1]) ||
            (emaS_buffer[1] > emaF_buffer[1] && emaF_buffer[1] > emaM_buffer[1])){
            return true;
         }
      }   
   //counter trend only
      if(InpEMARule == ENUM_COUNTERTREND){
         //sells
         if(emaS_buffer[1] < emaM_buffer[1] && emaM_buffer[1] < emaF_buffer[1]){
            return true;
         }
      } 
   }
   return false;
}

////  ADX /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool adxBuyCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(adx_handle,0,0,3,adx_main_buffer);
      CopyBuffer(adx_handle,1,0,3,adx_plus_buffer);
      CopyBuffer(adx_handle,2,0,3,adx_minus_buffer);
   //trend only
      if(InpADXRule == ENUM_TREND){
         //buys
         if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
            return true;
         }
      }
   //range only
      if(InpADXRule == ENUM_RANGE){
         if(adx_main_buffer[1] < InpADXThreshold){
            return true;
         }
      }
   //trend and range
      if(InpADXRule == ENUM_TRENDRANGE){
         if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
            return true;
         }
         if(adx_main_buffer[1] < InpADXThreshold){
            return true;
         }  
      }
   //range & counter trend
      if(InpADXRule == ENUM_COUNTERRANGE){
         //buys
         if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
            return true;
         }
         //range
         if(adx_main_buffer[1] < InpADXThreshold){
            return true;
         }
      }
   //counter trend
      if(InpADXRule == ENUM_COUNTERTREND){
         //buys
         if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
            return true;
         }
      }
   }
   return false;
}

bool adxSellCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(adx_handle,0,0,3,adx_main_buffer);
      CopyBuffer(adx_handle,1,0,3,adx_plus_buffer);
      CopyBuffer(adx_handle,2,0,3,adx_minus_buffer);
   //trend only
      if(InpADXRule == ENUM_TREND){
         //sells
         if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
            return true;
         }
      }
   //range only
      if(InpADXRule == ENUM_RANGE){
         if(adx_main_buffer[1] < InpADXThreshold){
            return true;
         }
      }
   //trend and range
      if(InpADXRule == ENUM_TRENDRANGE){
         if(adx_main_buffer[1] > InpADXThreshold && adx_minus_buffer[1] > adx_plus_buffer[1]){
            return true;
         }
         if(adx_main_buffer[1] < InpADXThreshold){
            return true;
         }  
      }
   //range & counter trend
      if(InpADXRule == ENUM_COUNTERRANGE){
         //sells
         if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
            return true;
         }
         //range
         if(adx_main_buffer[1] < InpADXThreshold){
            return true;
         }
      }   
   //counter trend
      if(InpADXRule == ENUM_COUNTERTREND){
         //sells
         if(adx_main_buffer[1] > InpADXThreshold && adx_plus_buffer[1] > adx_minus_buffer[1]){
            return true;
         }
      }
   }
   return false;
}

////  BB /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool bbBuyCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(bb_handle,1,0,3,bb_upper_buffer);
      CopyBuffer(bb_handle,2,0,3,bb_lower_buffer);
      if(InpUseBB == ENUM_AVOID){
         if(m1_close_price < bb_upper_buffer[1] && m1_close_price > bb_lower_buffer[1]){
            return true;
         }
      }
      if(InpUseBB == ENUM_COUNTERX){
         if(m1_close_price < bb_lower_buffer[1]){
            return true;
         }
      }
   }
   return false;
}

bool bbSellCondition(){
   if(InpNewSeq==true && can_trade==true && spread_ok == true){
      CopyBuffer(bb_handle,1,0,3,bb_upper_buffer);
      CopyBuffer(bb_handle,2,0,3,bb_lower_buffer);
      if(InpUseBB == ENUM_AVOID){
         if(m1_close_price < bb_upper_buffer[1] && m1_close_price > bb_lower_buffer[1]){
            return true;
         }
      }
      if(InpUseBB == ENUM_COUNTERX){
         if(m1_close_price > bb_upper_buffer[1]){
            return true;
         }
      }
   }
   return false;
}



void weekendCloseTimes() {
   //-- closing all positions for EA
   ClosePositions(POSITION_TYPE_BUY);
   ClosePositions(POSITION_TYPE_SELL);
   //-- reseting virtual delay variables
   if(DT_buyCount > 0){DT_entryBuyCount = 0; DT_buyCount = 0; v_totalBuyLots = 0; v_totalBuyPrice = 0;  ObjectDelete(0,v_lpBuy);}
   if(DT_sellCount > 0){DT_entrySellCount = 0; DT_sellCount = 0; v_totalSellLots = 0; v_totalSellPrice = 0;  ObjectDelete(0,v_lpSell);}   
   //-- getting start time of current day
   day_start = iTime(_Symbol,PERIOD_D1,0);
   //-- setting weekend close time variable
   weekendCloseTime = day_start + 21*60*60;
   //-- setting each day stop time to start of friday for easier restart time calcualtions
   if(InpDayToClose==ENUM_MON){
      day_start = day_start+PeriodSeconds(PERIOD_D1)*4;
   }
   else if(InpDayToClose==ENUM_TUE){
      day_start = day_start+PeriodSeconds(PERIOD_D1)*3;
   }
   else if(InpDayToClose==ENUM_WED){
      day_start = day_start+PeriodSeconds(PERIOD_D1)*2;
   }
   else if(InpDayToClose==ENUM_THU){
      day_start = day_start+PeriodSeconds(PERIOD_D1);
   }
   else {day_start = day_start;}
   //-- setting restart time based on start time of friday
   if(InpDayToRestart == ENUM_MON){
      weekendRestartTime = day_start+(PeriodSeconds(PERIOD_D1)*3 + 60*60);
   }
   else if(InpDayToRestart == ENUM_TUE){
      weekendRestartTime = day_start+(PeriodSeconds(PERIOD_D1)*4 + 60*60);
   }
   else if(InpDayToRestart == ENUM_WED){
      weekendRestartTime = day_start+(PeriodSeconds(PERIOD_D1)*5 + 60*60);
   }
   else if(InpDayToRestart == ENUM_THU){
      weekendRestartTime = day_start+(PeriodSeconds(PERIOD_D1)*6 + 60*60);
   }
   else {
      weekendRestartTime = day_start+(PeriodSeconds(PERIOD_D1)*7 + 60*60);
   }
   //-- setting bool to true to signal that the ea closed for weekend
   closed_for_weekend = true;
   weekendCount = 1;
   //-- Print message
   Print("Magic Number: ",InpMagicNumber,"  |  Closing Positions for Weekend.");
}

void textLabelCreate(string name, int xDist, int yDist, string textDisplay, int fontSize, int textColor){
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xDist);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yDist);
   ObjectSetString(0,name,OBJPROP_TEXT,textDisplay);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0,name,OBJPROP_FONT,"HoloLens MDL2 Assets"); //Consolas
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
}

void rectangleCreate(string name, int xDist, int yDist, int xSize, int ySize, int objColor){
   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xDist);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yDist);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,objColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT); 
}

void dividerCreate(string name, int xDist, int yDist, int xSize, int ySize, int objColor){
   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xDist);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yDist);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_COLOR,objColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
}

////  NEWS BACKTEST /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void newsBackTest(datetime timeNow){
   //all times in GMT+2/3 server time                                               
   string   symbol_base   = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   string   symbol_profit = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   int      bt_newsCounter = 0;

   if((symbol_base == "USD" || symbol_profit == "USD" || InpUseUSDnews==true) && usd_oor==false){   
      string USD[][2] = {
         {  "Empire State Manufacturing Index",    "2023.01.17 15:30"   }, 
         {  "PPI m/m",                             "2023.01.18 15:30"   }, 
         {  "Flash Services PMI",                  "2023.01.24 16:45"   }, 
         {  "Advance GDP q/q",                     "2023.01.26 14:30"   },
         {  "Core PCE Price Index m/m",            "2023.01.27 14:30"   },
         {  "CB Consumer Confidence",              "2023.01.31 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.02.01 15:15"   },
         {  "JOLTS Job Openings",                  "2023.02.01 17:00"   },
         {  "FOMC Statement",                      "2023.02.01 21:00"   },
         {  "Non-Farm Employment Change",          "2023.02.03 15:30"   },
         {  "ISM Services PMI",                    "2023.02.03 17:00"   },
         {  "Fed Chair Powell Speaks",             "2023.02.07 19:40"   },
         {  "FOMC Member Williams Speaks",         "2023.02.08 16:15"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.02.10 17:00"   },
         {  "CPI m/m",                             "2023.02.14 15:30"   },
         {  "Retail Sales m/m",                    "2023.02.15 15:30"   },
         {  "PPI m/m",                             "2023.02.16 15:30"   },
         {  "Flash Services PMI",                  "2023.02.21 16:45"   },
         {  "FOMC Meeting Minutes",                "2023.02.22 21:00"   },
         {  "Prelim GDP q/q",                      "2023.02.23 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.02.24 15:30"   },
         {  "CB Consumer Confidence",              "2023.02.28 15:00"   },
         {  "ISM Manufacturing PMI",               "2023.03.01 17:00"   },
         {  "ISM Services PMI",                    "2023.03.03 17:00"   },
         {  "Fed Chair Powell Testifies",          "2023.03.07 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.03.08 15:15"   },
         {  "JOLTS Job Openings",                  "2023.03.08 17:00"   },
         {  "Non-Farm Employment Change",          "2023.03.10 15:30"   },
         {  "Fed Announcement",                    "2023.03.13 15:00"   },
         {  "CPI m/m",                             "2023.03.14 15:30"   },
         {  "PPI m/m",                             "2023.03.15 15:30"   },
         {  "Unemployment Claims",                 "2023.03.16 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.03.17 17:00"   },
         {  "FOMC Statement",                      "2023.03.22 21:00"   },
         {  "FOMC Press Conference",               "2023.03.22 21:30"   },
         {  "Unemployment Claims",                 "2023.03.23 15:30"   },
         {  "Flash Manufacturing PMI",             "2023.03.24 16:45"   },
         {  "CB Consumer Confidence",              "2023.03.28 17:00"   },
         {  "Unemployment Claims",                 "2023.03.30 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.03.31 15:30"   },
         {  "ISM Manufacturing PMI",               "2023.04.03 17:00"   },
         {  "JOLTS Job Openings",                  "2023.04.04 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.04.05 15:15"   },
         {  "ISM Services PMI",                    "2023.04.05 17:00"   },
         {  "Unemployment Claims",                 "2023.04.06 15:30"   },
         {  "Non-Farm Employment Change",          "2023.04.07 15:30"   },
         {  "CPI m/m",                             "2023.04.12 15:30"   },
         {  "FOMC Meeting Minutes",                "2023.04.12 21:00"   },
         {  "PPI m/m",                             "2023.04.13 15:30"   },
         {  "Retail Sales m/m",                    "2023.04.14 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.04.14 17:00"   },
         {  "Empire State Manufacturing Index",    "2023.04.17 15:30"   },
         {  "Unemployment Claims",                 "2023.04.20 15:30"   },
         {  "Flash Manufacturing PMI",             "2023.04.21 16:45"   },
         {  "CB Consumer Confidence",              "2023.04.25 17:00"   },
         {  "Unemployment Claims",                 "2023.04.27 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.04.28 15:30"   },
         {  "ISM Manufacturing PMI",               "2023.05.01 17:00"   },
         {  "JOLTS Job Openings",                  "2023.05.04 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.05.03 15:15"   },
         {  "ISM Services PMI",                    "2023.05.03 17:00"   },
         {  "FOMC Statement",                      "2023.05.03 21:00"   },
         {  "Unemployment Claims",                 "2023.05.04 15:30"   },
         {  "Non-Farm Employment Change",          "2023.05.05 15:30"   },
         {  "CPI m/m",                             "2023.05.10 15:30"   },
         {  "PPI m/m",                             "2023.05.11 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.05.12 17:00"   },
         {  "Empire State Manufacturing Index",    "2023.05.15 15:30"   },
         {  "Retail Sales m/m",                    "2023.05.16 15:30"   },
         {  "Unemployment Claims",                 "2023.05.18 15:30"   },
         {  "Fed Chair Powell Speaks",             "2023.05.19 18:00"   },
         {  "Flash Manufacturing PMI",             "2023.05.23 16:45"   },
         {  "FOMC Meeting Minutes",                "2023.05.24 21:00"   },
         {  "Unemployment Claims",                 "2023.05.25 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.05.26 15:30"   },
         {  "CB Consumer Confidence",              "2023.05.30 17:00"   },
         {  "JOLTS Job Openings",                  "2023.05.31 17:00"   },
         {  "Unemployment Claims",                 "2023.06.01 15:30"   },
         {  "ISM Manufacturing PMI",               "2023.06.01 17:00"   },
         {  "Non-Farm Employment Change",          "2023.06.02 15:30"   },
         {  "ISM Services PMI",                    "2023.06.05 17:00"   },
         {  "Unemployment Claims",                 "2023.06.08 15:30"   },
         {  "CPI m/m",                             "2023.06.13 15:30"   },
         {  "PPI m/m",                             "2023.06.14 15:30"   },
         {  "FOMC Statement",                      "2023.06.14 21:00"   },
         {  "Retail Sales m/m",                    "2023.06.15 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.06.16 17:00"   },
         {  "Treasury Currency Report",            "2023.06.16 21:00"   },
         {  "Fed Chair Powell Testifies",          "2023.06.21 17:00"   },
         {  "Unemployment Claims",                 "2023.06.22 15:30"   },
         {  "Fed Chair Powell Testifies",          "2023.06.22 17:00"   },
         {  "Flash Manufacturing PMI",             "2023.06.23 16:45"   },
         {  "CB Consumer Confidence",              "2023.06.27 17:00"   },
         {  "Fed Chair Powell Speaks",             "2023.06.28 16:30"   },
         {  "Fed Chair Powell Speaks",             "2023.06.29 09:30"   },
         {  "Unemployment Claims",                 "2023.06.29 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.06.30 15:30"   },
         {  "ISM Manufacturing PMI",               "2023.07.03 17:00"   },
         {  "FOMC Meeting Minutes",                "2023.07.05 21:00"   },
         {  "Unemployment Claims",                 "2023.07.06 15:30"   },
         {  "JOLTS Job Openings",                  "2023.07.06 17:00"   },
         {  "Non-Farm Employment Change",          "2023.07.07 15:30"   },
         {  "CPI m/m",                             "2023.07.12 15:30"   },
         {  "PPI m/m",                             "2023.07.13 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.07.14 17:00"   },
         {  "Empire State Manufacturing Index",    "2023.07.17 15:30"   },
         {  "Retail Sales m/m",                    "2023.07.18 15:30"   },
         {  "Housing Starts",                      "2023.07.19 15:30"   },
         {  "Unemployment Claims",                 "2023.07.20 15:30"   },
         {  "Flash Manufacturing PMI",             "2023.07.24 16:45"   },
         {  "CB Consumer Confidence",              "2023.07.25 17:00"   },
         {  "FOMC Statement",                      "2023.07.26 21:00"   },
         {  "Unemployment Claims",                 "2023.07.27 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.07.28 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2023.07.28 17:00"   },
         {  "JOLTS Job Openings",                  "2023.08.01 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.08.02 15:15"   },
         {  "Unemployment Claims",                 "2023.08.03 15:30"   },
         {  "ISM Services PMI",                    "2023.08.03 17:00"   },
         {  "Non-Farm Employment Change",          "2023.08.04 15:30"   },
         {  "CPI m/m",                             "2023.08.10 15:30"   },
         {  "PPI m/m",                             "2023.08.11 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.08.11 17:00"   },
         {  "Retail Sales m/m",                    "2023.08.15 15:30"   },
         {  "FOMC Meeting Minutes",                "2023.08.16 21:00"   },
         {  "Unemployment Claims",                 "2023.08.17 15:30"   },
         {  "Flash Manufacturing PMI",             "2023.08.23 16:45"   },
         {  "Unemployment Claims",                 "2023.08.24 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2023.08.25 17:00"   },
         {  "JOLTS Job Openings",                  "2023.08.29 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.08.30 15:15"   },
         {  "Unemployment Claims",                 "2023.08.31 15:30"   },
         {  "Non-Farm Employment Change",          "2023.09.01 15:30"   },
         {  "ISM Manufacturing PMI",               "2023.09.01 17:00"   },
         {  "ISM Services PMI",                    "2023.09.06 17:00"   },
         {  "Unemployment Claims",                 "2023.09.07 15:30"   },
         {  "CPI m/m",                             "2023.09.13 15:30"   },
         {  "PPI m/m",                             "2023.09.14 15:30"   },
         {  "Empire State Manufacturing Index",    "2023.09.15 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.09.15 17:00"   },
         {  "FOMC Statement",                      "2023.09.20 21:00"   },
         {  "Unemployment Claims",                 "2023.09.21 15:30"   },
         {  "Flash Manufacturing PMI",             "2023.09.22 16:45"   },
         {  "CB Consumer Confidence",              "2023.09.26 17:00"   },
         {  "Unemployment Claims",                 "2023.09.28 15:30"   },
         {  "Fed Chair Powell Speaks",             "2023.09.28 23:00"   },
         {  "Core PCE Price Index m/m",            "2023.09.29 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2023.09.29 17:00"   },
         {  "ISM Manufacturing PMI",               "2023.10.02 17:00"   },
         {  "ISM Manufacturing PMI",               "2023.10.02 18:00"   },
         {  "JOLTS Job Openings",                  "2023.10.03 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.10.04 15:15"   },
         {  "ISM Services PMI",                    "2023.10.04 17:00"   },
         {  "Unemployment Claims",                 "2023.10.05 15:30"   },
         {  "Non-Farm Employment Change",          "2023.10.06 15:30"   },
         {  "PPI m/m",                             "2023.10.11 15:30"   },
         {  "FOMC Meeting Minutes",                "2023.10.11 21:00"   },
         {  "CPI m/m",                             "2023.10.12 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.10.13 17:00"   },
         {  "Empire State Manufacturing Index",    "2023.10.16 15:30"   },
         {  "Retail Sales m/m",                    "2023.10.17 15:30"   },
         {  "Unemployment Claims",                 "2023.10.19 15:30"   },
         {  "Fed Chair Powell Speaks",             "2023.10.19 17:00"   },
         {  "Flash Services PMI",                  "2023.10.24 16:45"   },
         {  "Fed Chair Powell Speaks",             "2023.10.25 23:35"   },
         {  "Unemployment Claims",                 "2023.10.26 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.10.27 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2023.10.27 17:00"   },
         {  "Employment Cost Index q/q",           "2023.10.31 15:30"   },
         {  "CB Consumer Confidence",              "2023.10.31 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.11.01 15:15"   },
         {  "JOLTS Job Openings",                  "2023.11.01 17:00"   },
         {  "FOMC Statement",                      "2023.11.01 21:00"   },
         {  "Unemployment Claims",                 "2023.11.02 15:30"   },
         {  "Non-Farm Employment Change",          "2023.11.03 15:30"   },
         {  "ISM Services PMI",                    "2023.11.03 17:00"   },
         {  "Treasury Currency Report",            "2023.11.07 23:00"   },
         {  "Fed Chair Powell Speaks",             "2023.11.08 15:15"   },
         {  "Unemployment Claims",                 "2023.11.09 15:30"   },
         {  "Fed Chair Powell Speaks",             "2023.11.09 21:00"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.11.10 17:00"   },
         {  "CPI m/m",                             "2023.11.14 15:30"   },
         {  "PPI m/m",                             "2023.11.15 15:30"   },
         {  "Unemployment Claims",                 "2023.11.16 15:30"   },
         {  "FOMC Meeting Minutes",                "2023.11.21 21:00"   },
         {  "Unemployment Claims",                 "2023.11.22 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2023.11.22 17:00"   },
         {  "Flash Services PMI",                  "2023.11.24 16:45"   },
         {  "CB Consumer Confidence",              "2023.11.28 17:00"   },
         {  "Prelim GDP q/q",                      "2023.11.29 15:30"   },
         {  "Unemployment Claims",                 "2023.11.30 15:30"   },
         {  "ISM Manufacturing PMI",               "2023.12.01 17:00"   },
         {  "Fed Chair Powell Speaks",             "2023.12.01 18:00"   },
         {  "Fed Chair Powell Speaks",             "2023.12.01 21:00"   },
         {  "JOLTS Job Openings",                  "2023.12.05 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2023.12.06 15:15"   },
         {  "Unemployment Claims",                 "2023.12.07 15:30"   },
         {  "Non-Farm Employment Change",          "2023.12.08 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2023.12.08 17:00"   },
         {  "CPI m/m",                             "2023.12.12 15:30"   },
         {  "PPI m/m",                             "2023.12.13 15:30"   },
         {  "FOMC Statement",                      "2023.12.13 21:00"   },
         {  "Retail Sales m/m",                    "2023.12.14 15:30"   },
         {  "Empire State Manufacturing Index",    "2023.12.15 15:30"   },
         {  "Flash Manufacturing PMI",             "2023.12.15 16:45"   },
         {  "CB Consumer Confidence",              "2023.12.20 17:00"   },
         {  "Unemployment Claims",                 "2023.12.21 15:30"   },
         {  "Core PCE Price Index m/m",            "2023.12.22 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2023.12.22 17:00"   },
         {  "JOLTS Job Openings",                  "2024.01.03 17:00"   },
         {  "FOMC Meeting Minutes",                "2024.01.03 21:00"   },
         {  "Unemployment Claims",                 "2024.01.04 15:30"   },
         {  "Non-Farm Employment Change",          "2024.01.05 15:30"   },
         {  "ISM Services PMI",                    "2024.01.05 17:00"   },
         {  "CPI m/m",                             "2024.01.11 15:30"   },
         {  "PPI m/m",                             "2024.01.12 15:30"   },
         {  "Empire State Manufacturing Index",    "2024.01.16 15:30"   },
         {  "Retail Sales m/m",                    "2024.01.17 15:30"   },
         {  "Unemployment Claims",                 "2024.01.17 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2024.01.19 17:00"   },
         {  "Flash Manufacturing PMI",             "2024.01.24 16:45"   },
         {  "Unemployment Claims",                 "2024.01.25 15:30"   },
         {  "Core PCE Price Index m/m",            "2024.01.26 15:30"   },
         {  "JOLTS Job Openings",                  "2024.01.30 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2024.01.31 15:15"   },
         {  "Employment Cost Index q/q",           "2024.01.31 15:30"   },
         {  "FOMC Statement",                      "2024.01.31 21:00"   },
         {  "Unemployment Claims",                 "2024.02.01 15:30"   },
         {  "ISM Manufacturing PMI",               "2024.02.01 17:00"   },
         {  "Non-Farm Employment Change",          "2024.02.02 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2024.02.02 17:00"   },
         {  "Fed Chair Powell Speaks",             "2024.02.05 02:00"   },
         {  "ISM Services PMI",                    "2024.02.05 17:00"   },
         {  "Unemployment Claims",                 "2024.02.08 15:30"   },
         {  "CPI m/m",                             "2024.02.13 15:30"   },
         {  "Retail Sales m/m",                    "2024.02.15 15:30"   },
         {  "PPI m/m",                             "2024.02.16 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2024.02.16 17:00"   },
         {  "FOMC Meeting Minutes",                "2024.02.21 21:00"   },
         {  "Unemployment Claims",                 "2024.02.22 15:30"   },
         {  "Flash Manufacturing PMI",             "2024.02.22 16:45"   },
         {  "Durable Goods Orders m/m",            "2024.02.27 15:30"   },
         {  "CB Consumer Confidence",              "2024.02.27 17:00"   },
         {  "Prelim GDP q/q",                      "2024.02.28 15:30"   },
         {  "Unemployment Claims",                 "2024.02.29 15:30"   },
         {  "ISM Manufacturing PMI",               "2024.03.01 17:00"   },
         {  "ISM Services PMI",                    "2024.03.05 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2024.03.06 15:15"   },
         {  "JOLTS Job Openings",                  "2024.03.06 17:00"   },
         {  "Unemployment Claims",                 "2024.03.07 15:30"   },
         {  "Fed Chair Powell Testifies",          "2024.03.07 17:00"   },
         {  "Non-Farm Employment Change",          "2024.03.08 15:30"   },
         {  "CPI m/m",                             "2024.03.12 15:30"   },
         {  "10-y Bond Auction",                   "2024.03.12 20:00"   },
         {  "30-y Bond Auction",                   "2024.03.13 20:00"   },
         {  "PPI m/m",                             "2024.03.14 15:30"   },
         {  "Empire State Manufacturing Index",    "2024.03.15 15:30"   },
         {  "Prelim UoM Consumer Sentiment",       "2024.03.15 17:00"   },
         {  "FOMC Statement",                      "2024.03.20 21:00"   },
         {  "FOMC Press Conference",               "2024.03.20 21:30"   },
         {  "Unemployment Claims",                 "2024.03.21 15:30"   },
         {  "Flash Manufacturing PMI",             "2024.03.21 16:45"   },
         {  "Fed Chair Powell Speaks",             "2024.03.22 16:00"   },
         {  "CB Consumer Confidence",              "2024.03.26 17:00"   },
         {  "FOMC Member Waller Speaks",           "2024.03.28 01:00"   },
         {  "Unemployment Claims",                 "2024.03.28 15:30"   },
         {  "Pending Home Sales m/m",              "2024.03.28 17:00"   },
         {  "Core PCE Price Index m/m",            "2024.03.29 15:30"   },
         {  "Fed Chair Powell Speaks",             "2024.03.29 19:30"   },
         {  "ISM Manufacturing PMI",               "2024.04.01 17:00"   },
         {  "JOLTS Job Openings",                  "2024.04.02 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2024.04.03 15:15"   },
         {  "ISM Services PMI",                    "2024.04.03 17:00"   },
         {  "Fed Chair Powell Speaks",             "2024.04.03 19:15"   },
         {  "Unemployment Claims",                 "2024.04.04 15:30"   },
         {  "Non-Farm Employment Change",          "2024.04.05 15:30"   },
         {  "CPI m/m",                             "2024.04.10 15:30"   },
         {  "FOMC Meeting Minutes",                "2024.04.04 21:00"   },
         {  "PPI m/m",                             "2024.04.11 15:30"   },
         {  "30-y Bond Auction",                   "2024.04.11 20:00"   },
         {  "Prelim UoM Consumer Sentiment",       "2024.04.12 17:00"   },
         {  "Retail Sales m/m",                    "2024.04.15 15:30"   },
         {  "Fed Chair Powell Speaks",             "2024.04.16 20:15"   },
         {  "Unemployment Claims",                 "2024.04.18 15:30"   },
         {  "Flash Manufacturing PMI",             "2024.04.23 16:45"   },
         {  "Unemployment Claims",                 "2024.04.25 15:30"   },
         {  "Pending Home Sales m/m",              "2024.04.25 17:00"   },
         {  "Core PCE Price Index m/m",            "2024.04.26 15:30"   },
         {  "Revised UoM Consumer Sentiment",      "2024.04.26 17:00"   },
         {  "Employment Cost Index q/q",           "2024.04.30 15:30"   },
         {  "CB Consumer Confidence",              "2024.04.30 17:00"   },
         {  "ADP Non-Farm Employment Change",      "2024.05.01 15:15"   },
         {  "Final Manufacturing PMI",             "2024.05.01 16:45"   },
         {  "JOLTS Job Openings",                  "2024.05.01 17:00"   },
         {  "FOMC Statement",                      "2024.05.01 21:00"   },
         {  "Unemployment Claims",                 "2024.05.02 15:30"   },
         {  "Non-Farm Employment Change",          "2024.05.03 15:30"   },
         {  "ISM Services PMI",                    "2024.05.03 17:00"   },     
         {  "Unemployment Claims",                 "2024.05.09 15:30"   },     
         {  "30-y Bond Auction",                   "2024.05.09 20:00"   },
         {  "Prelim UoM Consumer Sentiment",       "2024.05.10 17:00"   },
         {  "PPI m/m",                             "2024.05.14 15:30"   },
         {  "Fed Chair Powell Speaks",             "2024.05.14 17:00"   },
         {  "CPI m/m",                             "2024.05.15 15:30"   },
         {  "Unemployment Claims",                 "2024.05.16 15:30"   },
         {  "FOMC Meeting Minutes",                "2024.05.22 21:00"   },
         {  "Unemployment Claims",                 "2024.05.23 15:30"   },
         {  "Flash Manufacturing PMI",             "2024.05.23 16:45"   },
         {  "Revised UoM Consumer Sentiment",      "2024.05.24 17:00"   },
         {  "CB Consumer Confidence",              "2024.05.28 17:00"   },
         {  "Unemployment Claims",                 "2024.05.30 15:30"   },  
         {  "Pending Home Sales m/m",              "2024.05.30 17:00"   },  
         {  "Core PCE Price Index m/m",            "2024.05.31 15:30"   },
         {  "Final Manufacturing PMI",             "2024.06.03 16:45"   },
         {  "ISM Manufacturing PMI",               "2024.06.03 17:00"   }, 
         {  "JOLTS Job Openings",                  "2024.06.04 17:00"   }, 
         {  "ADP Non-Farm Employment Change",      "2024.06.05 15:15"   }, 
         {  "ISM Services PMI",                    "2024.06.05 17:00"   }, 
         {  "Unemployment Claims",                 "2024.06.06 15:30"   }, 
         {  "Non-Farm Employment Change",          "2024.06.07 15:30"   }        
      };
      for(int i=0; i<ArrayRange(USD,0); i++){

         if(timeNow < StringToTime(USD[i][1])+InpMinsAfter*60){
            newsName    = USD[i][0];
            newsTime    =  StringToTime(USD[i][1]);
            bt_newsStop       =  newsTime - InpMinsBefore * 60;
            bt_newsResume     =  newsTime + InpMinsAfter * 60;
            bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
            bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;

            bt_newsCounter = 1;
    
            break;
         }
         if(i >= ArrayRange(USD,0)-1){
            usd_oor = true;
            array_oor++;
            break;
         }
      }
   }
//   for(int i=0; i<ArraySize(USD); i++){
//      if(timeNow < StringToTime(USD[i][1])+InpMinsAfter*60){
//         newsName    = USD[i][0];
//         newsTime    =  StringToTime(USD[i][1]);
//         bt_newsStop       =  newsTime - InpMinsBefore * 60;
//         bt_newsResume     =  newsTime + InpMinsAfter * 60;
//         //if(TimeToString(TimeCurrent(),TIME_DATE) == TimeToString(StringToTime(USD[i][1]),TIME_DATE)){
//         //   Print("congrats it works.");
//         //}
//         //Print("timetostring(timecurrent,time_date): ",TimeToString(TimeCurrent(),TIME_DATE) ,"  |  newstime: ",USD[i][1]);
//              
//         break;
//      }
//   }
   if((symbol_base == "GBP" || symbol_profit == "GBP") && gbp_oor==false){
      string GBP[][2] = {
         {  "BOE Gov Bailey Speaks",               "2023.01.16 17:00"   }, 
         {  "Claimant Count Change",               "2023.01.17 09:00"   },
         {  "CPI y/y",                             "2023.01.18 09:00"   }, 
         {  "Flash Manufacturing PMI",             "2023.01.24 11:30"   },
         {  "Official Bank Rate",                  "2023.02.02 14:00"   }, 
         {  "BOE Gov Bailey Speaks",               "2023.02.02 14:30"   },
         {  "Monetary Policy Report Hearings",     "2023.02.09 11:45"   }, 
         {  "GDP m/m",                             "2023.02.10 09:00"   },
         {  "Claimant Count Change",               "2023.02.14 09:00"   }, 
         {  "CPI y/y",                             "2023.02.15 09:00"   },
         {  "Flash Manufacturing PMI",             "2023.02.21 11:30"   }, 
         {  "BOE Gov Bailey Speaks",               "2023.03.01 12:00"   },
         {  "GDP m/m",                             "2023.03.10 09:00"   }, 
         {  "Claimant Count Change",               "2023.03.14 10:00"   },
         {  "Annual Budget Release",               "2023.03.15 15:30"   },
         {  "CPI y/y",                             "2023.03.22 10:00"   },
         {  "Official Bank Rate",                  "2023.03.23 15:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.03.23 17:00"   },
         {  "Flash Manufacturing PMI",             "2023.03.24 12:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.03.27 20:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.03.28 11:45"   },
         {  "BOE Gov Bailey Speaks",               "2023.04.12 16:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.04.12 22:15"   },
         {  "GDP m/m",                             "2023.04.13 09:00"   },
         {  "Claimant Count Change",               "2023.04.18 09:00"   },
         {  "CPI y/y",                             "2023.04.19 09:00"   },
         {  "Flash Manufacturing PMI",             "2023.04.21 11:30"   },
         {  "Official Bank Rate",                  "2023.05.11 14:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.05.11 14:30"   },
         {  "GDP m/m",                             "2023.05.12 09:00"   },
         {  "Claimant Count Change",               "2023.05.16 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.05.17 12:50"   },
         {  "Flash Manufacturing PMI",             "2023.05.23 11:30"   },
         {  "CPI y/y",                             "2023.05.24 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.05.24 12:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.05.24 16:00"   },
         {  "Claimant Count Change",               "2023.06.13 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.06.13 17:00"   },
         {  "GDP m/m",                             "2023.06.14 09:00"   },
         {  "CPI y/y",                             "2023.06.21 09:00"   },
         {  "Official Bank Rate",                  "2023.06.22 14:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.06.22 14:15"   },
         {  "Flash Manufacturing PMI",             "2023.06.23 11:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.06.28 16:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.07.09 10:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.07.10 18:00"   },
         {  "Claimant Count Change",               "2023.07.11 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.07.12 11:00"   },
         {  "GDP m/m",                             "2023.07.13 09:00"   },
         {  "CPI y/y",                             "2023.07.19 09:00"   },
         {  "Flash Manufacturing PMI",             "2023.07.24 11:30"   },
         {  "Official Bank Rate",                  "2023.08.03 14:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.08.03 14:30"   },
         {  "GDP m/m",                             "2023.08.11 11:00"   },
         {  "Claimant Count Change",               "2023.08.15 09:00"   },
         {  "CPI y/y",                             "2023.08.16 09:00"   },
         {  "Flash Manufacturing PMI",             "2023.08.23 11:30"   },
         {  "Claimant Count Change",               "2023.09.12 09:00"   },
         {  "GDP m/m",                             "2023.09.13 09:00"   },
         {  "CPI y/y",                             "2023.09.20 09:00"   },
         {  "Official Bank Rate",                  "2023.09.21 14:00"   },
         {  "Retail Sales m/m",                    "2023.09.22 09:00"   },
         {  "Flash Manufacturing PMI",             "2023.09.22 11:30"   },
         {  "GDP m/m",                             "2023.10.12 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.10.13 11:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.10.14 18:00"   },
         {  "Average Earnings Index 3m/y",         "2023.10.17 09:00"   },
         {  "CPI y/y",                             "2023.10.18 09:00"   },
         {  "Retail Sales m/m",                    "2023.10.20 09:00"   },
         {  "Claimant Count Change",               "2023.10.24 09:00"   },
         {  "Flash Manufacturing PMI",             "2023.10.24 11:30"   },
         {  "Official Bank Rate",                  "2023.11.02 14:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.11.02 14:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.11.08 11:30"   },
         {  "GDP m/m",                             "2023.11.10 09:00"   },
         {  "Claimant Count Change",               "2023.11.14 09:00"   },
         {  "CPI y/y",                             "2023.11.15 09:00"   },
         {  "Retail Sales m/m",                    "2023.11.17 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.11.20 20:45"   },
         {  "Flash Manufacturing PMI",             "2023.11.23 11:30"   },
         {  "BOE Gov Bailey Speaks",               "2023.11.29 17:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.12.06 13:00"   },
         {  "Claimant Count Change",               "2023.12.12 09:00"   },
         {  "GDP m/m",                             "2023.12.13 09:00"   },
         {  "Official Bank Rate",                  "2023.12.14 14:00"   },
         {  "BOE Gov Bailey Speaks",               "2023.12.14 15:00"   },
         {  "Flash Manufacturing PMI",             "2023.12.15 11:30"   },
         {  "CPI y/y",                             "2023.12.20 09:00"   },
         {  "Retail Sales m/m",                    "2023.12.22 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.01.10 16:15"   },
         {  "GDP m/m",                             "2024.01.12 09:00"   },
         {  "Claimant Count Change",               "2024.01.16 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.01.16 17:00"   },
         {  "CPI y/y",                             "2024.01.17 09:00"   },
         {  "Retail Sales m/m",                    "2024.01.19 09:00"   },
         {  "Flash Manufacturing PMI",             "2024.01.24 11:30"   },
         {  "Official Bank Rate",                  "2024.02.01 14:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.02.01 14:30"   },
         {  "BOE Gov Bailey Speaks",               "2024.02.12 20:00"   },
         {  "Claimant Count Change",               "2024.02.13 09:00"   },
         {  "CPI y/y",                             "2024.02.14 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.02.14 17:00"   },
         {  "GDP m/m",                             "2024.02.15 09:00"   },
         {  "Retail Sales m/m",                    "2024.02.16 09:00"   },
         {  "Flash Manufacturing PMI",             "2024.02.22 11:30"   },
         {  "Annual Budget Release",               "2024.03.06 14:34"   },
         {  "Claimant Count Change",               "2024.03.12 09:00"   },
         {  "GDP m/m",                             "2024.03.13 09:00"   },
         {  "CPI y/y",                             "2024.03.20 09:00"   },
         {  "Flash Manufacturing PMI",             "2024.03.21 11:30"   },
         {  "Official Bank Rate",                  "2024.03.21 14:00"   },
         {  "Retail Sales m/m",                    "2024.03.22 09:00"   },
         {  "GDP m/m",                             "2024.04.12 09:00"   },
         {  "Claimant Count Change",               "2024.04.16 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.04.16 20:00"   },
         {  "CPI y/y",                             "2024.04.17 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.04.17 19:00"   },
         {  "Retail Sales m/m",                    "2024.04.19 09:00"   },
         {  "Flash Manufacturing PMI",             "2024.04.23 11:30"   },
         {  "Official Bank Rate",                  "2024.05.09 14:00"   },
         {  "GDP m/m",                             "2024.05.10 09:00"   },
         {  "Claimant Count Change",               "2024.05.14 09:00"   },
         {  "BOE Gov Bailey Speaks",               "2024.05.21 20:00"   },
         {  "CPI y/y",                             "2024.05.22 09:00"   },
         {  "Flash Manufacturing PMI",             "2024.05.23 11:30"   },
         {  "Retail Sales m/m",                    "2024.05.24 09:00"   },
         {  "Claimant Count Change",               "2024.06.11 09:00"   },
         {  "GDP m/m",                             "2024.06.12 09:00"   },
         {  "CPI y/y",                             "2024.06.19 09:00"   },
         {  "Flash Manufacturing PMI",             "2024.06.20 11:30"   },
         {  "Official Bank Rate",                  "2024.06.20 14:00"   },
         {  "Retail Sales m/m",                    "2024.06.21 09:00"   }
      };
      for(int i=0; i<ArrayRange(GBP,0); i++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(GBP[i][1])+InpMinsAfter*60){
               newsName    =  GBP[i][0];
               newsTime    =  StringToTime(GBP[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            if(StringToTime(GBP[i][1]) < newsTime && timeNow < StringToTime(GBP[i][1])+InpMinsAfter*60){
               newsName    =  GBP[i][0];
               newsTime    =  StringToTime(GBP[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(GBP[i][1]) >= newsTime && timeNow < StringToTime(GBP[i][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(i >= ArrayRange(GBP,0)-1){
            gbp_oor = true;
            array_oor++;
            break;
         }
      }
   }
   if((symbol_base == "EUR" || symbol_profit == "EUR") && eur_oor==false){
      string EUR[][2] = {
         {  "Main Refinancing Rate",               "2023.02.02 15:15"   }, 
         {  "ECB Press Conference",                "2023.02.02 15:45"   },
         {  "Main Refinancing Rate",               "2023.03.16 15:15"   }, 
         {  "ECB Press Conference",                "2023.03.16 15:45"   },
         {  "French Flash Services PMI",           "2023.03.24 10:15"   }, 
         {  "German Flash Services PMI",           "2023.03.24 10:30"   }, 
         {  "French Flash Services PMI",           "2023.04.21 10:15"   },
         {  "German Flash Services PMI",           "2023.04.21 10:30"   }, 
         {  "Main Refinancing Rate",               "2023.05.04 15:15"   },
         {  "ECB Press Conference",                "2023.05.04 15:45"   }, 
         {  "French Flash Services PMI",           "2023.05.23 10:15"   },
         {  "German Flash Services PMI",           "2023.05.23 10:30"   },
         {  "CPI Flash Estimate y/y",              "2023.06.01 12:00"   },
         {  "Main Refinancing Rate",               "2023.06.15 15:15"   },
         {  "ECB Press Conference",                "2023.06.15 15:45"   }, 
         {  "French Flash Services PMI",           "2023.06.23 10:15"   },
         {  "German Flash Services PMI",           "2023.06.23 10:30"   },
         {  "French Flash Services PMI",           "2023.07.24 10:15"   },
         {  "German Flash Services PMI",           "2023.07.24 10:30"   },
         {  "Main Refinancing Rate",               "2023.07.27 15:15"   },
         {  "ECB Press Conference",                "2023.07.27 15:45"   },
         {  "French Flash Services PMI",           "2023.08.23 10:15"   },
         {  "German Flash Services PMI",           "2023.08.23 10:30"   },
         {  "German ifo Business Climate",         "2023.08.25 11:00"   },
         {  "ECB President Lagarde Speaks",        "2023.08.25 22:00"   },
         {  "Spanish Flash CPI y/y",               "2023.08.30 10:00"   },
         {  "Main Refinancing Rate",               "2023.09.14 15:15"   },
         {  "ECB Press Conference",                "2023.09.14 15:45"   },
         {  "French Flash Services PMI",           "2023.09.22 10:15"   },
         {  "German Flash Services PMI",           "2023.09.22 10:30"   },
         {  "German ifo Business Climate",         "2023.09.25 11:00"   },
         {  "Spanish Flash CPI y/y",               "2023.09.28 10:00"   },
         {  "French Flash Services PMI",           "2023.10.24 10:15"   },
         {  "German Flash Services PMI",           "2023.10.24 10:30"   },
         {  "German ifo Business Climate",         "2023.10.25 11:00"   },
         {  "Main Refinancing Rate",               "2023.10.26 15:15"   },
         {  "ECB Press Conference",                "2023.10.26 15:45"   },
         {  "Spanish Flash CPI y/y",               "2023.10.30 10:00"   },
         {  "French Flash Services PMI",           "2023.11.23 10:15"   },
         {  "German Flash Services PMI",           "2023.11.23 10:30"   },
         {  "Spanish Flash CPI y/y",               "2023.11.29 10:00"   },
         {  "Main Refinancing Rate",               "2023.12.14 15:15"   },
         {  "ECB Press Conference",                "2023.12.14 15:45"   },
         {  "French Flash Services PMI",           "2023.12.15 10:15"   },
         {  "German Flash Services PMI",           "2023.12.15 10:30"   },
         {  "French Flash Services PMI",           "2023.01.24 10:15"   },
         {  "German Flash Services PMI",           "2023.01.24 10:30"   },
         {  "Main Refinancing Rate",               "2023.01.25 15:15"   },
         {  "ECB Press Conference",                "2023.01.25 15:45"   },
         {  "French Flash Services PMI",           "2023.02.22 10:15"   },
         {  "German Flash Services PMI",           "2023.02.22 10:30"   },
         {  "Main Refinancing Rate",               "2023.03.07 15:15"   },
         {  "ECB Press Conference",                "2023.03.07 15:45"   },
         {  "French Flash Services PMI",           "2023.03.21 10:15"   },
         {  "German Flash Services PMI",           "2023.03.21 10:30"   },
         {  "Main Refinancing Rate",               "2023.04.11 15:15"   },
         {  "ECB Press Conference",                "2023.02.11 15:45"   },
         {  "French Flash Services PMI",           "2023.04.23 10:15"   },
         {  "German Flash Services PMI",           "2023.04.23 10:30"   },
         {  "French Flash Services PMI",           "2023.05.23 10:15"   },
         {  "German Flash Services PMI",           "2023.05.23 10:30"   },
         {  "CPI Flash Estimate y/y",              "2023.05.31 12:00"   },
         {  "Main Refinancing Rate",               "2023.06.06 15:15"   },
         {  "ECB Press Conference",                "2023.06.06 15:45"   },
         {  "French Flash Services PMI",           "2023.06.20 10:15"   },
         {  "German Flash Services PMI",           "2023.06.20 10:30"   }
      };
      for(int i=0; i<ArrayRange(EUR,0); i++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(EUR[i][1])+InpMinsAfter*60){
               newsName    =  EUR[i][0];
               newsTime    =  StringToTime(EUR[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            if(StringToTime(EUR[i][1]) < newsTime && timeNow < StringToTime(EUR[i][1])+InpMinsAfter*60){
               newsName    =  EUR[i][0];
               newsTime    =  StringToTime(EUR[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(EUR[i][1]) >= newsTime && timeNow < StringToTime(EUR[i][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(i >= ArrayRange(EUR,0)-1){
            eur_oor = true;
            array_oor++;
            break;
         }
      }
   }
   if((symbol_base == "JPY" || symbol_profit == "JPY") && jpy_oor==false){
      string JPY[][2] = {
         {  "Monetary Policy Statement",           "2023.01.18 04:40"   }, 
         {  "BOJ Press Conference",                "2023.01.18 08:30"   },
         {  "BOJ Gov Ueda Speaks",                 "2023.02.25 02:34"   }, 
         {  "BOJ Gov Ueda Speaks",                 "2023.02.27 06:10"   },
         {  "Monetary Policy Statement",           "2023.03.10 04:31"   }, 
         {  "BOJ Press Conference",                "2023.03.10 08:30"   },
         {  "Tokyo Core CPI y/y",                  "2023.04.28 02:30"   },
         {  "Monetary Policy Statement",           "2023.04.28 07:00"   },
         {  "BOJ Press Conference",                "2023.04.28 09:30"   },
         {  "Monetary Policy Statement",           "2023.06.16 05:47"   },
         {  "BOJ Press Conference",                "2023.06.16 09:00"   },
         {  "BOJ Gov Ueda Speaks",                 "2023.06.28 16:30"   },
         {  "Monetary Policy Statement",           "2023.07.28 06:28"   },
         {  "BOJ Press Conference",                "2023.07.28 09:30"   },
         {  "Monetary Policy Statement",           "2023.09.22 05:52"   },
         {  "BOJ Press Conference",                "2023.09.22 09:30"   },
         {  "BOJ Gov Ueda Speaks",                 "2023.09.25 08:35"   },
         {  "BOJ Gov Ueda Speaks",                 "2023.09.30 09:01"   },
         {  "Monetary Policy Statement",           "2023.10.31 05:28"   },
         {  "BOJ Press Conference",                "2023.10.31 08:40"   },
         {  "BOJ Gov Ueda Speaks",                 "2023.11.06 03:05"   },
         {  "Monetary Policy Statement",           "2023.12.19 04:49"   },
         {  "BOJ Press Conference",                "2023.12.19 08:30"   },
         {  "Monetary Policy Statement",           "2024.01.23 05:09"   },
         {  "BOJ Press Conference",                "2024.01.23 08:30"   },
         {  "BOJ Gov Ueda Speaks",                 "2024.03.05 06:00"   },
         {  "Monetary Policy Statement",           "2024.03.19 05:36"   },
         {  "BOJ Press Conference",                "2024.03.19 08:30"   },
         {  "Monetary Policy Statement",           "2024.04.26 06:22"   },
         {  "BOJ Press Conference",                "2024.04.26 09:30"   },
         {  "BOJ Gov Ueda Speaks",                 "2024.05.27 15:05"   },
         {  "Monetary Policy Statement",           "2024.06.14 05:30"   }
      };
      for(int i=0; i<ArrayRange(JPY,0); i++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(JPY[i][1])+InpMinsAfter*60){
               newsName    =  JPY[i][0];
               newsTime    =  StringToTime(JPY[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            if(StringToTime(JPY[i][1]) < newsTime && timeNow < StringToTime(JPY[i][1])+InpMinsAfter*60){
               newsName    =  JPY[i][0];
               newsTime    =  StringToTime(JPY[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(JPY[i][1]) >= newsTime && timeNow < StringToTime(JPY[i][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(i >= ArrayRange(JPY,0)-1){
            jpy_oor = true;
            array_oor++;
            break;
         }
      }
   }
   if((symbol_base == "AUD" || symbol_profit == "AUD") && aud_oor==false){
      string AUD[][2] = {
         {  "CPI y/y",                             "2023.01.25 02:30"   }, 
         {  "Cash Rate",                           "2023.02.07 05:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.02.15 02:15"   }, 
         {  "Unemployment Rate",                   "2023.02.16 02:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.02.17 00:30"   }, 
         {  "Wage Price Index q/q",                "2023.02.22 02:30"   },
         {  "CPI y/y",                             "2023.03.01 02:30"   },
         {  "Cash Rate",                           "2023.03.07 05:30"   },
         {  "Fed Chair Powell Testifies",          "2023.03.07 17:00"   },
         {  "RBA Gov Lowe Speaks",                 "2023.03.07 23:55"   },
         {  "Unemployment Rate",                   "2023.03.16 02:30"   },
         {  "CPI y/y",                             "2023.03.29 03:30"   },
         {  "Cash Rate",                           "2023.04.04 07:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.04.05 05:30"   },
         {  "Unemployment Rate",                   "2023.04.13 04:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.04.20 05:00"   },
         {  "CPI y/y",                             "2023.04.26 04:30"   },
         {  "Cash Rate",                           "2023.05.02 07:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.04.02 14:20"   },
         {  "Wage Price Index q/q",                "2023.05.17 04:30"   },
         {  "Unemployment Rate",                   "2023.05.18 04:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.05.31 02:00"   },
         {  "CPI y/y",                             "2023.05.31 04:30"   },
         {  "Cash Rate",                           "2023.06.06 07:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.06.07 02:20"   },
         {  "GDP q/q",                             "2023.06.07 04:30"   },
         {  "Unemployment Rate",                   "2023.06.15 04:30"   },
         {  "CPI y/y",                             "2023.06.28 04:30"   },
         {  "Cash Rate",                           "2023.07.04 07:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.07.12 06:10"   },
         {  "Monetary Policy Meeting Minutes",     "2023.07.18 04:30"   },
         {  "Unemployment Rate",                   "2023.07.20 04:30"   },
         {  "CPI y/y",                             "2023.07.26 04:30"   },
         {  "Cash Rate",                           "2023.08.01 07:30"   },
         {  "RBA Gov Lowe Speaks",                 "2023.08.11 02:30"   },
         {  "Wage Price Index q/q",                "2023.08.15 04:30"   },
         {  "Unemployment Rate",                   "2023.08.17 04:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.08.29 10:40"   },
         {  "CPI y/y",                             "2023.08.30 04:30"   },
         {  "Cash Rate",                           "2023.09.05 07:30"   },
         {  "GDP q/q",                             "2023.09.06 04:30"   },
         {  "Unemployment Rate",                   "2023.09.14 04:30"   },
         {  "Monetary Policy Meeting Minutes",     "2023.09.19 04:30"   },
         {  "CPI y/y",                             "2023.09.27 04:30"   },
         {  "Cash Rate",                           "2023.10.03 06:30"   },
         {  "Monetary Policy Meeting Minutes",     "2023.10.17 03:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.10.18 01:35"   },
         {  "Unemployment Rate",                   "2023.10.19 03:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.10.24 11:00"   },
         {  "CPI y/y",                             "2023.10.25 03:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.10.26 01:00"   },
         {  "Cash Rate",                           "2023.11.07 05:30"   },
         {  "Wage Price Index q/q",                "2023.11.15 02:30"   },
         {  "Unemployment Rate",                   "2023.11.16 02:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.11.21 01:00"   },
         {  "Monetary Policy Meeting Minutes",     "2023.11.21 02:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.11.22 10:35"   },
         {  "RBA Gov Bullock Speaks",              "2023.11.28 03:18"   },
         {  "CPI y/y",                             "2023.11.29 02:30"   },
         {  "Cash Rate",                           "2023.12.05 05:30"   },
         {  "GDP q/q",                             "2023.12.06 02:30"   },
         {  "RBA Gov Bullock Speaks",              "2023.12.12 00:20"   },
         {  "Unemployment Rate",                   "2023.12.14 02:30"   },
         {  "Monetary Policy Meeting Minutes",     "2023.12.19 02:30"   },
         {  "CPI y/y",                             "2024.01.10 02:30"   },
         {  "Unemployment Rate",                   "2024.01.18 02:30"   },
         {  "CPI y/y",                             "2024.01.31 02:30"   },
         {  "Cash Rate",                           "2024.02.06 05:30"   },
         {  "RBA Press Conference",                "2024.02.06 06:30"   },
         {  "RBA Gov Bullock Speaks",              "2024.02.09 00:30"   },
         {  "RBA Gov Bullock Speaks",              "2024.02.15 00:00"   },
         {  "Unemployment Rate",                   "2024.02.15 02:30"   },
         {  "Monetary Policy Meeting Minutes",     "2024.02.20 02:30"   },
         {  "Wage Price Index q/q",                "2024.02.21 02:30"   },
         {  "CPI y/y",                             "2024.02.28 02:30"   },
         {  "GDP q/q",                             "2024.03.06 02:30"   },
         {  "Cash Rate",                           "2024.03.19 05:30"   },
         {  "RBA Press Conference",                "2024.03.19 06:30"   },
         {  "Unemployment Rate",                   "2024.03.21 02:30"   },
         {  "CPI y/y",                             "2024.03.27 02:30"   },
         {  "Unemployment Rate",                   "2024.04.18 04:30"   },
         {  "CPI y/y",                             "2024.04.24 04:30"   },
         {  "Cash Rate",                           "2024.05.07 07:30"   },
         {  "Wage Price Index q/q",                "2024.05.15 04:30"   },
         {  "Unemployment Rate",                   "2024.05.06 04:30"   },
         {  "CPI y/y",                             "2024.05.29 04:30"   },
         {  "GDP q/q",                             "2024.06.05 04:30"   },
         {  "Unemployment Rate",                   "2024.06.13 04:30"   },
         {  "Cash Rate",                           "2024.06.18 07:30"   },
         {  "CPI y/y",                             "2024.06.26 04:30"   }
      };
      for(int i=0; i<ArrayRange(AUD,0); i++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(AUD[i][1])+InpMinsAfter*60){
               newsName    =  AUD[i][0];
               newsTime    =  StringToTime(AUD[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            if(StringToTime(AUD[i][1]) < newsTime && timeNow < StringToTime(AUD[i][1])+InpMinsAfter*60){
               newsName    =  AUD[i][0];
               newsTime    =  StringToTime(AUD[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(AUD[i][1]) >= newsTime && timeNow < StringToTime(AUD[i][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(i >= ArrayRange(AUD,0)-1){
            aud_oor = true;
            array_oor++;
            break;
         }
      }
   }
   if((symbol_base == "NZD" || symbol_profit == "NZD") && nzd_oor==false){
      string NZD[][2] = {
         {  "CPI q/q",                             "2023.01.24 23:45"   }, 
         {  "Unemployment Rate",                   "2023.01.31 23:45"   },
         {  "Inflation Expectations q/q",          "2023.02.14 04:00"   }, 
         {  "Official Cash Rate",                  "2023.02.22 03:00"   },
         {  "RBNZ Press Conference",               "2023.02.22 04:00"   },
         {  "RBNZ Gov Orr Speaks",                 "2023.02.22 21:10"   }, 
         {  "RBNZ Gov Orr Speaks",                 "2023.03.02 21:06"   },
         {  "GDP q/q",                             "2023.03.16 00:45"   },
         {  "Official Cash Rate",                  "2023.04.05 05:00"   }, 
         {  "CPI q/q",                             "2023.04.20 01:45"   },
         {  "Unemployment Rate",                   "2023.05.03 01:45"   },
         {  "RBNZ Gov Orr Speaks",                 "2023.05.03 04:00"   }, 
         {  "Inflation Expectations q/q",          "2023.05.12 06:00"   },
         {  "Official Cash Rate",                  "2023.05.24 05:00"   },
         {  "RBNZ Press Conference",               "2023.05.24 06:00"   }, 
         {  "GDP q/q",                             "2023.06.15 01:45"   },
         {  "Official Cash Rate",                  "2023.07.12 05:00"   },
         {  "CPI q/q",                             "2023.07.19 01:45"   }, 
         {  "Unemployment Rate",                   "2023.08.02 01:45"   },
         {  "Inflation Expectations q/q",          "2023.08.09 06:00"   },
         {  "Official Cash Rate",                  "2023.08.16 05:00"   }, 
         {  "RBNZ Press Conference",               "2023.08.16 06:00"   },
         {  "GDP q/q",                             "2023.09.21 01:45"   },
         {  "Official Cash Rate",                  "2023.10.04 04:00"   },
         {  "CPI q/q",                             "2023.10.17 00:45"   },
         {  "Unemployment Rate",                   "2023.10.31 23:45"   },
         {  "Inflation Expectations q/q",          "2023.11.08 04:25"   },
         {  "Official Cash Rate",                  "2023.11.29 03:00"   },
         {  "RBNZ Press Conference",               "2023.11.29 04:00"   },
         {  "GDP q/q",                             "2023.12.13 23:45"   },
         {  "Unemployment Rate",                   "2024.02.06 23:45"   },
         {  "Inflation Expectations q/q",          "2024.02.13 04:20"   },
         {  "Official Cash Rate",                  "2024.02.28 03:00"   },
         {  "GDP q/q",                             "2024.03.20 23:45"   },
         {  "Official Cash Rate",                  "2024.04.10 05:00"   },
         {  "CPI q/q",                             "2024.04.17 01:45"   },
         {  "Unemployment Rate",                   "2024.05.01 01:45"   },
         {  "Inflation Expectations q/q",          "2024.05.13 06:00"   },
         {  "Official Cash Rate",                  "2024.05.22 05:00"   },
         {  "GDP q/q",                             "2024.06.20 01:45"   }
      };
      for(int i=0; i<ArrayRange(NZD,0); i++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(NZD[i][1])+InpMinsAfter*60){
               newsName    =  NZD[i][0];
               newsTime    =  StringToTime(NZD[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            if(StringToTime(NZD[i][1]) < newsTime && timeNow < StringToTime(NZD[i][1])+InpMinsAfter*60){
               newsName    =  NZD[i][0];
               newsTime    =  StringToTime(NZD[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(NZD[i][1]) >= newsTime && timeNow < StringToTime(NZD[i][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(i >= ArrayRange(NZD,0)-1){
            nzd_oor = true;
            array_oor++;
            break;
         }
      }
   }
   if((symbol_base == "CAD" || symbol_profit == "CAD") && cad_oor==false){
      string CAD[][2] = {
         {  "CPI m/m",                             "2023.01.17 15:30"   }, 
         {  "Overnight Rate",                      "2023.01.25 17:00"   },
         {  "BOC Press Conference",                "2023.01.25 18:00"   }, 
         {  "GDP m/m",                             "2023.01.31 15:30"   },
         {  "Unemployment Rate",                   "2023.02.10 15:30"   }, 
         {  "BOC Gov Macklem Speaks",              "2023.02.16 18:00"   },
         {  "CPI m/m",                             "2023.02.21 15:30"   }, 
         {  "GDP m/m",                             "2023.02.28 15:30"   },
         {  "Overnight Rate",                      "2023.03.08 17:00"   }, 
         {  "Unemployment Rate",                   "2023.03.10 15:30"   },
         {  "CPI m/m",                             "2023.03.21 14:30"   }, 
         {  "GDP m/m",                             "2023.03.31 15:30"   },
         {  "Unemployment Rate",                   "2023.04.06 15:30"   }, 
         {  "Overnight Rate",                      "2023.04.12 17:00"   },
         {  "BOC Press Conference",                "2023.04.12 18:00"   }, 
         {  "BOC Gov Macklem Speaks",              "2023.04.13 16:00"   },
         {  "CPI m/m",                             "2023.04.18 15:30"   }, 
         {  "BOC Gov Macklem Speaks",              "2023.04.18 18:30"   },
         {  "BOC Gov Macklem Speaks",              "2023.04.20 18:30"   }, 
         {  "GDP m/m",                             "2023.04.28 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2023.05.04 19:50"   },
         {  "Unemployment Rate",                   "2023.05.05 15:30"   }, 
         {  "CPI m/m",                             "2023.05.16 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2023.05.18 18:00"   },
         {  "GDP m/m",                             "2023.05.31 15:30"   }, 
         {  "Overnight Rate",                      "2023.06.07 17:00"   },
         {  "Unemployment Rate",                   "2023.06.09 15:30"   },
         {  "CPI m/m",                             "2023.06.27 15:30"   }, 
         {  "GDP m/m",                             "2023.06.30 15:30"   },
         {  "Unemployment Rate",                   "2023.07.07 15:30"   },
         {  "Overnight Rate",                      "2023.07.12 17:00"   }, 
         {  "CPI m/m",                             "2023.07.18 15:30"   },
         {  "GDP m/m",                             "2023.07.28 15:30"   },
         {  "Unemployment Rate",                   "2023.08.04 15:30"   }, 
         {  "CPI m/m",                             "2023.08.15 15:30"   },
         {  "GDP m/m",                             "2023.09.01 15:30"   },
         {  "Overnight Rate",                      "2023.09.06 17:00"   }, 
         {  "BOC Gov Macklem Speaks",              "2023.09.07 20:55"   },
         {  "Unemployment Rate",                   "2023.09.08 15:30"   },
         {  "CPI m/m",                             "2023.09.19 15:30"   }, 
         {  "GDP m/m",                             "2023.09.29 15:30"   },
         {  "Unemployment Rate",                   "2023.10.06 15:30"   },
         {  "CPI m/m",                             "2023.10.17 15:30"   }, 
         {  "Overnight Rate",                      "2023.10.25 17:00"   },
         {  "BOC Press Conference",                "2023.10.25 18:00"   },
         {  "BOC Gov Macklem Speaks",              "2023.10.30 22:30"   }, 
         {  "GDP m/m",                             "2023.10.31 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2023.11.01 23:15"   },
         {  "Unemployment Rate",                   "2023.11.03 15:30"   }, 
         {  "CPI m/m",                             "2023.11.21 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2023.11.22 18:30"   },
         {  "GDP m/m",                             "2023.11.30 15:30"   }, 
         {  "Unemployment Rate",                   "2023.12.01 15:30"   },
         {  "Overnight Rate",                      "2023.12.06 17:00"   }, 
         {  "BOC Gov Macklem Speaks",              "2023.12.15 19:25"   },
         {  "CPI m/m",                             "2023.12.19 15:30"   }, 
         {  "GDP m/m",                             "2023.12.22 15:30"   },
         {  "Unemployment Rate",                   "2024.01.05 15:30"   }, 
         {  "CPI m/m",                             "2024.01.16 15:30"   },
         {  "Overnight Rate",                      "2024.01.24 16:45"   }, 
         {  "BOC Press Conference",                "2024.01.24 17:30"   },
         {  "GDP m/m",                             "2024.01.31 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2024.02.01 18:30"   }, 
         {  "BOC Gov Macklem Speaks",              "2024.02.06 19:45"   },
         {  "Unemployment Rate",                   "2024.02.09 15:30"   },
         {  "CPI m/m",                             "2024.02.20 15:30"   }, 
         {  "GDP m/m",                             "2024.02.29 15:30"   },
         {  "Overnight Rate",                      "2024.03.06 16:45"   },
         {  "BOC Press Conference",                "2024.03.06 17:30"   }, 
         {  "Unemployment Rate",                   "2024.03.08 15:30"   },
         {  "CPI m/m",                             "2024.03.19 15:30"   },
         {  "GDP m/m",                             "2024.03.28 15:30"   }, 
         {  "Unemployment Rate",                   "2024.03.22 15:00"   },
         {  "Overnight Rate",                      "2024.04.10 16:45"   },
         {  "BOC Press Conference",                "2024.04.10 17:30"   }, 
         {  "CPI m/m",                             "2024.04.16 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2024.04.16 20:15"   },
         {  "GDP m/m",                             "2024.04.30 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2024.05.01 23:15"   },
         {  "BOC Gov Macklem Speaks",              "2024.05.02 15:45"   },
         {  "BOC Gov Macklem Speaks",              "2024.05.09 18:00"   },
         {  "Unemployment Rate",                   "2024.05.10 15:30"   },
         {  "CPI m/m",                             "2024.05.21 15:30"   },
         {  "GDP m/m",                             "2024.05.31 15:30"   },
         {  "Overnight Rate",                      "2024.06.05 16:45"   },
         {  "Unemployment Rate",                   "2024.06.07 15:30"   },
         {  "BOC Gov Macklem Speaks",              "2024.06.12 22:15"   },
         {  "CPI m/m",                             "2024.06.25 15:30"   },
         {  "GDP m/m",                             "2024.06.28 15:30"   }
      };
      for(int c=0; c<ArrayRange(CAD,0); c++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(CAD[c][1])+InpMinsAfter*60){
               newsName    =  CAD[c][0];
               newsTime    =  StringToTime(CAD[c][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            //Print("CAD[c][1]: ",CAD[c][1]," < newsTime: ",newsTime," && timeNow: ",timeNow," < resume time: ",StringToTime(CAD[c][1])+InpMinsAfter*60);
            if(StringToTime(CAD[c][1]) < newsTime && timeNow < StringToTime(CAD[c][1])+InpMinsAfter*60){ 
               newsName    =  CAD[c][0];
               newsTime    =  StringToTime(CAD[c][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(CAD[c][1]) >= newsTime && timeNow < StringToTime(CAD[c][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(c >= ArrayRange(CAD,0)-1){
            cad_oor = true;
            array_oor++;
            break;
         }  
      }
   }
   if((symbol_base == "CHF" || symbol_profit == "CHF") && chf_oor==false){
      string CHF[][2] = {
         {  "CPI m/m",                             "2023.02.13 09:30"   }, 
         {  "CPI m/m",                             "2023.03.06 09:00"   },
         {  "SNB Policy Rate",                     "2023.03.23 11:30"   }, 
         {  "SNB Press Conference",                "2023.03.23 12:00"   },
         {  "CPI m/m",                             "2023.04.03 09:30"   }, 
         {  "CPI m/m",                             "2023.05.05 09:30"   },
         {  "CPI m/m",                             "2023.06.05 09:30"   }, 
         {  "SNB Policy Rate",                     "2023.06.22 10:30"   }, 
         {  "SNB Press Conference",                "2023.06.22 11:00"   },
         {  "CPI m/m",                             "2023.07.03 09:30"   }, 
         {  "CPI m/m",                             "2023.08.03 09:30"   },
         {  "CPI m/m",                             "2023.09.01 09:30"   }, 
         {  "SNB Policy Rate",                     "2023.09.21 10:30"   },
         {  "SNB Press Conference",                "2023.09.21 11:00"   }, 
         {  "CPI m/m",                             "2023.10.03 09:30"   },
         {  "CPI m/m",                             "2023.11.02 09:30"   }, 
         {  "CPI m/m",                             "2023.12.04 09:30"   },
         {  "SNB Policy Rate",                     "2023.12.14 10:30"   }, 
         {  "SNB Press Conference",                "2023.12.14 11:00"   },
         {  "CPI m/m",                             "2024.01.08 09:30"   }, 
         {  "CPI m/m",                             "2024.02.13 09:30"   },
         {  "CPI m/m",                             "2024.03.04 09:30"   }, 
         {  "SNB Policy Rate",                     "2024.03.21 10:30"   },
         {  "SNB Press Conference",                "2024.03.21 11:00"   },
         {  "CPI m/m",                             "2024.04.04 09:30"   },
         {  "CPI m/m",                             "2024.05.02 09:30"   },
         {  "CPI m/m",                             "2024.06.04 09:30"   },
         {  "SNB Policy Rate",                     "2024.06.20 10:30"   },
         {  "SNB Press Conference",                "2024.06.20 11:30"   }
      };
      for(int i=0; i<ArrayRange(CHF,0); i++){
         
         if(bt_newsCounter == 0){
            if(timeNow < StringToTime(CHF[i][1])+InpMinsAfter*60){
               newsName    =  CHF[i][0];
               newsTime    =  StringToTime(CHF[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               bt_newsCounter = 1;
               
               break;
            }
         }
         else {
            if(StringToTime(CHF[i][1]) < newsTime && timeNow < StringToTime(CHF[i][1])+InpMinsAfter*60){
               newsName    =  CHF[i][0];
               newsTime    =  StringToTime(CHF[i][1]);
               bt_newsStop       =  newsTime - InpMinsBefore * 60;
               bt_newsResume     =  newsTime + InpMinsAfter * 60;
               bt_newsPropStop   =  newsTime - InpNewsWindowStart * 60;
               bt_newsPropResume =  newsTime + InpNewsWindowEnd * 60;
      
               break;  
            }
            if(StringToTime(CHF[i][1]) >= newsTime && timeNow < StringToTime(CHF[i][1])+InpMinsAfter*60) {
               break;  
            } 
         }
         if(i >= ArrayRange(CHF,0)-1){
            chf_oor = true;
            array_oor++;
            break;
         }
      }
   }

   //-- CHECK IF RED NEWS == ALL DAY. TURN NEW_SEQUENCE TO FALSE FOR WHOLE DAY.
   

   PrintFormat("Backtest News Event: %s at: %s | Stopping at: %s Resuming at: %s",
               newsName, TimeToString(newsTime,TIME_DATE|TIME_MINUTES), TimeToString(bt_newsStop,TIME_DATE|TIME_MINUTES), TimeToString(bt_newsResume,TIME_DATE|TIME_MINUTES));
   PrintFormat("*Prop Firm News Window | Start: %s - End: %s", TimeToString(bt_newsPropStop,TIME_DATE|TIME_MINUTES), TimeToString(bt_newsPropResume,TIME_DATE|TIME_MINUTES));
   return;
   
   // create 
   if(InpUseNewsWindow==true){
      objectFull("window_start",OBJ_VLINE,bt_newsPropStop,bid,clrCrimson,STYLE_SOLID);
      objectFull("window_end",OBJ_VLINE,bt_newsPropResume,bid,clrCrimson,STYLE_SOLID);
   }
}


string getUninitReasonText(int reasonCode) 
  { 
   string text=""; 
//--- 
   switch(reasonCode) 
     { 
      case REASON_ACCOUNT: 
         text="Account was changed";break; 
      case REASON_CHARTCHANGE: 
         text="Symbol or timeframe was changed";break; 
      case REASON_CHARTCLOSE: 
         text="Chart was closed";break; 
      case REASON_PARAMETERS: 
         text="Input-parameter was changed";break; 
      case REASON_RECOMPILE: 
         text="Program "+__FILE__+" was recompiled";break; 
      case REASON_REMOVE: 
         text="Program "+__FILE__+" was removed from chart";break; 
      case REASON_TEMPLATE: 
         text="New template was applied to chart";break; 
      default:text="Another reason"; 
     } 
//--- 
   return text; 
  }
