//+------------------------------------------------------------------+
//|                                                     BB Marti.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+ 
//| Chart Properties                                                 | 
//+------------------------------------------------------------------+ 
bool ChartBackColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the chart background color 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartForeColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of axes, scale and OHLC line 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_FOREGROUND,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartGridColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set chart grid color 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_GRID,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }  
   return(true); 
}

bool ChartUpColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of up bar, its shadow and border of body of a bullish candlestick 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }  
   return(true); 
}

bool ChartDownColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of down bar, its shadow and border of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}

bool ChartBullColorSet(const color clr,const long chart_ID=0){ 
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

bool ChartBearColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   } 
   return(true); 
}



//+------------------------------------------------------------------+
//| Includes & Enumerations                                          |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;

#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;

enum lotType{
   ENUM_PERC,  //%Risk
   ENUM_FIXED, //Fixed Lot
};


//+------------------------------------------------------------------+
//| Input Variables                                                  |
//+------------------------------------------------------------------+

input group       "Trade Settings"
input int         InpMagicNumber       =     88956;      //Magic Number
input lotType     InpLotType           =     ENUM_PERC;  //Lot Type (Not Used In Martingale Grid Strategy)
input double      InpRisk              =     1.0;        //Risk Percent
input double      InpLotSize           =     0.01;       //Fixed Lot Size
input int         InpStopLoss          =     20;         //Stop Loss (pips)
input int         InpTakeProfit        =     20;         //Take Profit (pips)
input int         InpBreakeven         =     15;         //Break Even (pips)
input bool        InpTrendFilter       =     false;      //Use Trend Filter
input ENUM_TIMEFRAMES   InpTrendTF     =     PERIOD_D1;  //Trend Filter Time Frame
input double      InpBearBull          =     0.5;        //Gold Liquidity Filter (0 = off for currency pairs)

input group       "Martingale Grid Strategy"          
input bool        InpMartingale        =     false;      //Use Martingale
input bool        InpAutoLot           =     false;      //Use Auto Lot
input double      InpStartLot          =     0.01;       //Starting Lot Size
input int         InpAutoLotPer        =     1000;       //(Auto Lot) Starting Lot Per: $
input double      InpLotMultiplier     =     1.5;        //Lot Mulitplier
input int         InpGridStep          =     20;         //Grid Step (pips)
input double      InpMaxLot            =     10;         //Max Lot Size
input int         InpMaxPositions      =     10;         //Max Positions
input double      InpDDpercent         =     0.0;        //Max Equity Drawdown %   
input int         InpDDbalance         =     0;          //Max Balance Drawdown $ 
input bool        InpStopFriday        =     false;      //STOP Expert on Friday (no trades)

input group       "Misc Settings"
input bool        InpProfitDisplay     =     true;       //Display Daily Profit
input color       InpTPcolor           =     clrGold;    //Take Profit Line Color
input color       InpBEcolor           =     clrDodgerBlue; //Break Even Line Color
input string      InpMulti_C           =     "";         //Currency Symbols for Multi Currency Trading

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick     currentTick;
MqlDateTime today;

//--------------------------------------------------------------
//current Symbol >>>>>>
//--------------------------------------------------------------
int         bBands_handle, ema50_handle, ema200_handle, bearsP_handle, bullsP_handle, ema450_handle;
double      bbUpperBuffer[], bbLowerBuffer[], ema50Buffer[], ema200Buffer[], bearsPBuffer[], bullsPBuffer[], ema450Buffer[];
double      barOneClose;
double      martiLotSize;
static double        nextBuyPrice;
static double        nextSellPrice;
static double        totalBuyPrice, totalSellPrice;
static double        totalBuyLots, totalSellLots;
static double        buyPrice, sellPrice;
static double        breakEvenLineBuy, breakEvenLineSell;
double               tpBuyLine, tpSellLine;

double      last_volume_buy = 0.0;
double      last_volume_sell = 0.0;
double      last_open_price_buy = 0.0;
double      last_open_price_sell = 0.0;
double      last_open_price = 0.0;
double      last_volume = 0.0;
int         last_position_type = -1;

//--------------------------------------------------------------
//Symbol 0 >>>>>>
//--------------------------------------------------------------
int         bBands_handle_s0, ema50_handle_s0, ema200_handle_s0, bearsP_handle_s0, bullsP_handle_s0, ema450_handle_s0;
double      bbUpperBuffer_s0[], bbLowerBuffer_s0[], ema50Buffer_s0[], ema200Buffer_s0[], bearsPBuffer_s0[], bullsPBuffer_s0[], ema450Buffer_s0[];
double      barOneClose_s0;
double      martiLotSize_s0;
static double        nextBuyPrice_s0;
static double        nextSellPrice_s0;
static double        totalBuyPrice_s0, totalSellPrice_s0;
static double        totalBuyLots_s0, totalSellLots_s0;
static double        buyPrice_s0, sellPrice_s0;
static double        breakEvenLineBuy_s0, breakEvenLineSell_s0;
double               tpBuyLine_s0, tpSellLine_s0;
double      last_volume_buy_s0 = 0.0;
double      last_volume_sell_s0 = 0.0;
double      last_open_price_buy_s0 = 0.0;
double      last_open_price_sell_s0 = 0.0;
double      last_open_price_s0 = 0.0;
double      last_volume_S0 = 0.0;
int         last_position_type_s0 = -1;

//--------------------------------------------------------------
//Symbol 1 >>>>>>
//--------------------------------------------------------------
int         bBands_handle_s1, ema50_handle_s1, ema200_handle_s1, bearsP_handle_s1, bullsP_handle_s1, ema450_handle_s1;
double      bbUpperBuffer_s1[], bbLowerBuffer_s1[], ema50Buffer_s1[], ema200Buffer_s1[], bearsPBuffer_s1[], bullsPBuffer_s1[], ema450Buffer_s1[];
double      barOneClose_s1;
double      martiLotSize_s1;
static double        nextBuyPrice_s1;
static double        nextSellPrice_s1;
static double        totalBuyPrice_s1, totalSellPrice_s1;
static double        totalBuyLots_s1, totalSellLots_s1;
static double        buyPrice_s1, sellPrice_s1;
static double        breakEvenLineBuy_s1, breakEvenLineSell_s1;
double               tpBuyLine_s1, tpSellLine_s1;
double      last_volume_buy_s1 = 0.0;
double      last_volume_sell_s1 = 0.0;
double      last_open_price_buy_s1 = 0.0;
double      last_open_price_sell_s1 = 0.0;
double      last_open_price_s1 = 0.0;
double      last_volume_S1 = 0.0;
int         last_position_type_s1 = -1;

//--------------------------------------------------------------
//Symbol 2 >>>>>>
//--------------------------------------------------------------
int         bBands_handle_s2, ema50_handle_s2, ema200_handle_s2, bearsP_handle_s2, bullsP_handle_s2, ema450_handle_s2;
double      bbUpperBuffer_s2[], bbLowerBuffer_s2[], ema50Buffer_s2[], ema200Buffer_s2[], bearsPBuffer_s2[], bullsPBuffer_s2[], ema450Buffer_s2[];
double      barOneClose_s2;
double      martiLotSize_s2;
static double        nextBuyPrice_s2;
static double        nextSellPrice_s2;
static double        totalBuyPrice_s2, totalSellPrice_s2;
static double        totalBuyLots_s2, totalSellLots_s2;
static double        buyPrice_s2, sellPrice_s2;
static double        breakEvenLineBuy_s2, breakEvenLineSell_s2;
double               tpBuyLine_s2, tpSellLine_s2;
double      last_volume_buy_s2 = 0.0;
double      last_volume_sell_s2 = 0.0;
double      last_open_price_buy_s2 = 0.0;
double      last_open_price_sell_s2 = 0.0;
double      last_open_price_s2 = 0.0;
double      last_volume_S2 = 0.0;
int         last_position_type_s2 = -1;



double      SL, TP;
double      lotSize;
int         barstotal;

int         pointSL = InpStopLoss*10;
int         pointTP = InpTakeProfit*10;
int         pointBE = InpBreakeven*10;
int         pointGridStep = InpGridStep*10;
double      SLsize = pointSL*_Point;





double   close_buy_range;
double   close_sell_range;

double      closeBuyPositions, closeSellPositions;


string symbolArray[];
ushort sep = StringGetCharacter(",",0);
int s_split;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

//---

   if(InpMartingale==true && InpTakeProfit <= 0){Alert("Take profit must be greater than 0...");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpMartingale==true && InpGridStep <= 0){Alert("Grid step must be greater than 0 when using martingale strategy.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotType==ENUM_FIXED && InpLotSize <= 0){Alert("Lot size cannot be less than 0.01...");return INIT_PARAMETERS_INCORRECT;}
   
//---
   s_split = StringSplit(InpMulti_C,sep,symbolArray);

   barstotal = iBars(_Symbol,PERIOD_CURRENT);
   
   TesterHideIndicators(true);   
   
//--------------------------------------------------------------
//Current Symbol >>>>>>
//--------------------------------------------------------------
   bBands_handle = iBands(_Symbol,PERIOD_CURRENT,100,0,2,PRICE_CLOSE);
   if(bBands_handle==INVALID_HANDLE){Print("Failed to create bollinger bands indicator handle.");return INIT_FAILED;}   
   ema50_handle = iMA(_Symbol,InpTrendTF,50,0,MODE_EMA,PRICE_CLOSE);
   if(ema50_handle==INVALID_HANDLE){Print("Failed to create 50 ema indicator handle.");return INIT_FAILED;}   
   ema200_handle = iMA(_Symbol,InpTrendTF,200,0,MODE_EMA,PRICE_CLOSE);
   if(ema200_handle==INVALID_HANDLE){Print("Failed to create 200 ema indicator handle");return INIT_FAILED;}  
   bearsP_handle = iBearsPower(_Symbol,PERIOD_CURRENT,13);
   if(bearsP_handle==INVALID_HANDLE){Print("Failed to create bears power indicator handle");return INIT_FAILED;}  
   bullsP_handle = iBullsPower(_Symbol,PERIOD_CURRENT,13);
   if(bullsP_handle==INVALID_HANDLE){Print("Failed to create bulls power indicator handle");return INIT_FAILED;}   
   ema450_handle = iMA(_Symbol,PERIOD_CURRENT,450,0,MODE_EMA,PRICE_CLOSE);
   if(ema450_handle==INVALID_HANDLE){Print("Failed to create 450 ema indicator handle");return INIT_FAILED;}
   
   ArraySetAsSeries(bbLowerBuffer,true);
   ArraySetAsSeries(bbUpperBuffer,true);
   ArraySetAsSeries(ema50Buffer,true);
   ArraySetAsSeries(ema200Buffer,true);
   ArraySetAsSeries(bearsPBuffer,true);
   ArraySetAsSeries(bullsPBuffer,true);
   ArraySetAsSeries(ema450Buffer,true);   
   
//--------------------------------------------------------------
//Symbol 0 >>>>>>
//-------------------------------------------------------------- 
   bBands_handle_s0 = iBands(symbolArray[0],PERIOD_CURRENT,100,0,2,PRICE_CLOSE);
   if(bBands_handle_s0==INVALID_HANDLE){Print("Failed to create bollinger bands s0 indicator handle.");return INIT_FAILED;}   
   ema50_handle_s0 = iMA(symbolArray[0],InpTrendTF,50,0,MODE_EMA,PRICE_CLOSE);
   if(ema50_handle_s0==INVALID_HANDLE){Print("Failed to create 50 ema s0 indicator handle.");return INIT_FAILED;}   
   ema200_handle_s0 = iMA(symbolArray[0],InpTrendTF,200,0,MODE_EMA,PRICE_CLOSE);
   if(ema200_handle_s0==INVALID_HANDLE){Print("Failed to create 200 ema s0 indicator handle");return INIT_FAILED;}  
   bearsP_handle_s0 = iBearsPower(symbolArray[0],PERIOD_CURRENT,13);
   if(bearsP_handle_s0==INVALID_HANDLE){Print("Failed to create bears power s0 indicator handle");return INIT_FAILED;}  
   bullsP_handle_s0 = iBullsPower(symbolArray[0],PERIOD_CURRENT,13);
   if(bullsP_handle_s0==INVALID_HANDLE){Print("Failed to create bulls power s0 indicator handle");return INIT_FAILED;}   
   ema450_handle_s0 = iMA(symbolArray[0],PERIOD_CURRENT,450,0,MODE_EMA,PRICE_CLOSE);
   if(ema450_handle_s0==INVALID_HANDLE){Print("Failed to create 450 ema s0 indicator handle");return INIT_FAILED;} 
    
   ArraySetAsSeries(bbLowerBuffer_s0,true);
   ArraySetAsSeries(bbUpperBuffer_s0,true);
   ArraySetAsSeries(ema50Buffer_s0,true);
   ArraySetAsSeries(ema200Buffer_s0,true);
   ArraySetAsSeries(bearsPBuffer_s0,true);
   ArraySetAsSeries(bullsPBuffer_s0,true);
   ArraySetAsSeries(ema450Buffer_s0,true);

//--------------------------------------------------------------
//Symbol 1 >>>>>>
//-------------------------------------------------------------- 
   bBands_handle_s1 = iBands(symbolArray[1],PERIOD_CURRENT,100,0,2,PRICE_CLOSE);
   if(bBands_handle_s1==INVALID_HANDLE){Print("Failed to create bollinger bands s1 indicator handle.");return INIT_FAILED;}   
   ema50_handle_s1 = iMA(symbolArray[1],InpTrendTF,50,0,MODE_EMA,PRICE_CLOSE);
   if(ema50_handle_s1==INVALID_HANDLE){Print("Failed to create 50 ema s1 indicator handle.");return INIT_FAILED;}   
   ema200_handle_s1 = iMA(symbolArray[1],InpTrendTF,200,0,MODE_EMA,PRICE_CLOSE);
   if(ema200_handle_s1==INVALID_HANDLE){Print("Failed to create 200 ema s1 indicator handle");return INIT_FAILED;}  
   bearsP_handle_s1 = iBearsPower(symbolArray[1],PERIOD_CURRENT,13);
   if(bearsP_handle_s1==INVALID_HANDLE){Print("Failed to create bears power s1 indicator handle");return INIT_FAILED;}  
   bullsP_handle_s1 = iBullsPower(symbolArray[1],PERIOD_CURRENT,13);
   if(bullsP_handle_s1==INVALID_HANDLE){Print("Failed to create bulls power s1 indicator handle");return INIT_FAILED;}   
   ema450_handle_s1 = iMA(symbolArray[1],PERIOD_CURRENT,450,0,MODE_EMA,PRICE_CLOSE);
   if(ema450_handle_s1==INVALID_HANDLE){Print("Failed to create 450 ema s1 indicator handle");return INIT_FAILED;} 
    
   ArraySetAsSeries(bbLowerBuffer_s1,true);
   ArraySetAsSeries(bbUpperBuffer_s1,true);
   ArraySetAsSeries(ema50Buffer_s1,true);
   ArraySetAsSeries(ema200Buffer_s1,true);
   ArraySetAsSeries(bearsPBuffer_s1,true);
   ArraySetAsSeries(bullsPBuffer_s1,true);
   ArraySetAsSeries(ema450Buffer_s1,true);   
   
//--------------------------------------------------------------
//Symbol 2 >>>>>>
//-------------------------------------------------------------- 
   bBands_handle_s2 = iBands(symbolArray[2],PERIOD_CURRENT,100,0,2,PRICE_CLOSE);
   if(bBands_handle_s2==INVALID_HANDLE){Print("Failed to create bollinger bands s2 indicator handle.");return INIT_FAILED;}   
   ema50_handle_s2 = iMA(symbolArray[2],InpTrendTF,50,0,MODE_EMA,PRICE_CLOSE);
   if(ema50_handle_s2==INVALID_HANDLE){Print("Failed to create 50 ema s2 indicator handle.");return INIT_FAILED;}   
   ema200_handle_s2 = iMA(symbolArray[2],InpTrendTF,200,0,MODE_EMA,PRICE_CLOSE);
   if(ema200_handle_s2==INVALID_HANDLE){Print("Failed to create 200 ema s2 indicator handle");return INIT_FAILED;}  
   bearsP_handle_s2 = iBearsPower(symbolArray[2],PERIOD_CURRENT,13);
   if(bearsP_handle_s2==INVALID_HANDLE){Print("Failed to create bears power s2 indicator handle");return INIT_FAILED;}  
   bullsP_handle_s2 = iBullsPower(symbolArray[2],PERIOD_CURRENT,13);
   if(bullsP_handle_s2==INVALID_HANDLE){Print("Failed to create bulls power s2 indicator handle");return INIT_FAILED;}   
   ema450_handle_s2 = iMA(symbolArray[2],PERIOD_CURRENT,450,0,MODE_EMA,PRICE_CLOSE);
   if(ema450_handle_s2==INVALID_HANDLE){Print("Failed to create 450 ema s2 indicator handle");return INIT_FAILED;} 
    
   ArraySetAsSeries(bbLowerBuffer_s2,true);
   ArraySetAsSeries(bbUpperBuffer_s2,true);
   ArraySetAsSeries(ema50Buffer_s2,true);
   ArraySetAsSeries(ema200Buffer_s2,true);
   ArraySetAsSeries(bearsPBuffer_s2,true);
   ArraySetAsSeries(bullsPBuffer_s2,true);
   ArraySetAsSeries(ema450Buffer_s2,true); 
      
//---
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   ChartBackColorSet(clrBlack,0);
   ChartForeColorSet(clrWhite,0);
   ChartGridColorSet(clrNONE,0);
   ChartUpColorSet(clrWhite,0);
   ChartDownColorSet(clrWhite,0);
   ChartBullColorSet(clrWhite,0);
   ChartBearColorSet(clrBlack,0);
   


    
//---

   return(INIT_SUCCEEDED);
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

//-Current-Symbol
   if(bBands_handle != INVALID_HANDLE){IndicatorRelease(bBands_handle);}   
   if(ema50_handle != INVALID_HANDLE){IndicatorRelease(ema50_handle);}
   if(ema200_handle != INVALID_HANDLE){IndicatorRelease(ema200_handle);} 
   if(bearsP_handle != INVALID_HANDLE){IndicatorRelease(bearsP_handle);}
   if(bullsP_handle != INVALID_HANDLE){IndicatorRelease(bullsP_handle);}
   if(ema450_handle != INVALID_HANDLE){IndicatorRelease(ema450_handle);} 
   
//-Symbol-0
   if(bBands_handle_s0 != INVALID_HANDLE){IndicatorRelease(bBands_handle_s0);}   
   if(ema50_handle_s0 != INVALID_HANDLE){IndicatorRelease(ema50_handle_s0);}
   if(ema200_handle_s0 != INVALID_HANDLE){IndicatorRelease(ema200_handle_s0);} 
   if(bearsP_handle_s0 != INVALID_HANDLE){IndicatorRelease(bearsP_handle_s0);}
   if(bullsP_handle_s0 != INVALID_HANDLE){IndicatorRelease(bullsP_handle_s0);}
   if(ema450_handle_s0 != INVALID_HANDLE){IndicatorRelease(ema450_handle_s0);} 
   
//-Symbol-1
   if(bBands_handle_s1 != INVALID_HANDLE){IndicatorRelease(bBands_handle_s1);}   
   if(ema50_handle_s1 != INVALID_HANDLE){IndicatorRelease(ema50_handle_s1);}
   if(ema200_handle_s1 != INVALID_HANDLE){IndicatorRelease(ema200_handle_s1);} 
   if(bearsP_handle_s1 != INVALID_HANDLE){IndicatorRelease(bearsP_handle_s1);}
   if(bullsP_handle_s1 != INVALID_HANDLE){IndicatorRelease(bullsP_handle_s1);}
   if(ema450_handle_s1 != INVALID_HANDLE){IndicatorRelease(ema450_handle_s1);}
   
//-Symbol-2
   if(bBands_handle_s2 != INVALID_HANDLE){IndicatorRelease(bBands_handle_s2);}   
   if(ema50_handle_s2 != INVALID_HANDLE){IndicatorRelease(ema50_handle_s2);}
   if(ema200_handle_s2 != INVALID_HANDLE){IndicatorRelease(ema200_handle_s2);} 
   if(bearsP_handle_s2 != INVALID_HANDLE){IndicatorRelease(bearsP_handle_s2);}
   if(bullsP_handle_s2 != INVALID_HANDLE){IndicatorRelease(bullsP_handle_s2);}
   if(ema450_handle_s2 != INVALID_HANDLE){IndicatorRelease(ema450_handle_s2);}             
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   //Comment("Original: ",InpMulti_C,"\nSplit: ",symbolArray[0],"  ,  ",symbolArray[1],"  ,  ",symbolArray[2]);
//---

   if(!SymbolInfoTick(_Symbol,currentTick)){
      Print("Failed to get current tick.");
      return;
   }

//---

//--------------------------------------------------------------
//Current Symbol >>>>>>
//-------------------------------------------------------------- 
   barOneClose = iClose(_Symbol,PERIOD_CURRENT,1); 
   CopyBuffer(bBands_handle,UPPER_BAND,0,2,bbUpperBuffer);
   CopyBuffer(bBands_handle,LOWER_BAND,0,2,bbLowerBuffer);
   CopyBuffer(ema50_handle,0,0,2,ema50Buffer);
   CopyBuffer(ema200_handle,0,0,2,ema200Buffer);
   CopyBuffer(bearsP_handle,0,0,3,bearsPBuffer);
   CopyBuffer(bullsP_handle,0,0,3,bullsPBuffer);
   CopyBuffer(ema450_handle,0,0,2,ema450Buffer);
   
   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell,_Symbol);
 
//--------------------------------------------------------------
//Symbol 0 >>>>>>
//-------------------------------------------------------------- 
   barOneClose_s0 = iClose(symbolArray[0],PERIOD_CURRENT,1);
   double Bid_s0 = SymbolInfoDouble(symbolArray[0],SYMBOL_BID);
   double Ask_s0 = SymbolInfoDouble(symbolArray[0],SYMBOL_ASK);
   double s0_point = SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);  
   CopyBuffer(bBands_handle_s0,UPPER_BAND,0,2,bbUpperBuffer_s0);
   CopyBuffer(bBands_handle_s0,LOWER_BAND,0,2,bbLowerBuffer_s0);
   CopyBuffer(ema50_handle_s0,0,0,2,ema50Buffer_s0);
   CopyBuffer(ema200_handle_s0,0,0,2,ema200Buffer_s0);
   CopyBuffer(bearsP_handle_s0,0,0,3,bearsPBuffer_s0);
   CopyBuffer(bullsP_handle_s0,0,0,3,bullsPBuffer_s0);
   CopyBuffer(ema450_handle_s0,0,0,2,ema450Buffer_s0);    

   int cntBuy_s0, cntSell_s0;
   CountOpenPositions(cntBuy_s0,cntSell_s0,symbolArray[0]); 

//--------------------------------------------------------------
//Symbol 1 >>>>>>
//-------------------------------------------------------------- 
   barOneClose_s1 = iClose(symbolArray[1],PERIOD_CURRENT,1);
   double Bid_s1 = SymbolInfoDouble(symbolArray[1],SYMBOL_BID);
   double Ask_s1 = SymbolInfoDouble(symbolArray[1],SYMBOL_ASK);
   double s1_point = SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);  
   CopyBuffer(bBands_handle_s1,UPPER_BAND,0,2,bbUpperBuffer_s1);
   CopyBuffer(bBands_handle_s1,LOWER_BAND,0,2,bbLowerBuffer_s1);
   CopyBuffer(ema50_handle_s1,0,0,2,ema50Buffer_s1);
   CopyBuffer(ema200_handle_s1,0,0,2,ema200Buffer_s1);
   CopyBuffer(bearsP_handle_s1,0,0,3,bearsPBuffer_s1);
   CopyBuffer(bullsP_handle_s1,0,0,3,bullsPBuffer_s1);
   CopyBuffer(ema450_handle_s1,0,0,2,ema450Buffer_s1);    

   int cntBuy_s1, cntSell_s1;
   CountOpenPositions(cntBuy_s1,cntSell_s1,symbolArray[1]);

//--------------------------------------------------------------
//Symbol 2 >>>>>>
//-------------------------------------------------------------- 
   barOneClose_s2 = iClose(symbolArray[2],PERIOD_CURRENT,1);
   double Bid_s2 = SymbolInfoDouble(symbolArray[2],SYMBOL_BID);
   double Ask_s2 = SymbolInfoDouble(symbolArray[2],SYMBOL_ASK);
   double s2_point = SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);  
   CopyBuffer(bBands_handle_s2,UPPER_BAND,0,2,bbUpperBuffer_s2);
   CopyBuffer(bBands_handle_s2,LOWER_BAND,0,2,bbLowerBuffer_s2);
   CopyBuffer(ema50_handle_s2,0,0,2,ema50Buffer_s2);
   CopyBuffer(ema200_handle_s2,0,0,2,ema200Buffer_s2);
   CopyBuffer(bearsP_handle_s2,0,0,3,bearsPBuffer_s2);
   CopyBuffer(bullsP_handle_s2,0,0,3,bullsPBuffer_s2);
   CopyBuffer(ema450_handle_s2,0,0,2,ema450Buffer_s2);    

   int cntBuy_s2, cntSell_s2;
   CountOpenPositions(cntBuy_s2,cntSell_s2,symbolArray[2]);

//---
   
   double bullNegative = InpBearBull*(-1);

   datetime    date1 = TimeCurrent();
   TimeToStruct(date1,today);

//---


//---

   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barstotal != bars){
      barstotal = bars;

                                                         //++++---------------OPEN-SIGNAL-POSITION------------------++++\\





//--                                                  //++++--------------NEXT-MARTINGALE-POSITION-PRICE------------------++++\\

//--------------------------------------------------------------
//Current Symbol Next Positions >>>>>>
//--------------------------------------------------------------   
      if(cntBuy==0){
         nextBuyPrice=0;
         closeBuyPositions=0;
      }
      if(cntSell==0){
         nextSellPrice=0;
         closeSellPositions=0;
      }         
      if(PositionsTotal()>=1){
         int total = PositionsTotal();
         for(int i=total-1; i>=0; i--){
            ulong ticket = PositionGetTicket(i);  
            long type;
            if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return;}
            
            if(type==POSITION_TYPE_BUY && cntBuy==1){
               nextBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN)-pointGridStep*_Point;
               //closeBuyPositions = last_open_price + pointTP*_Point;
            }  
            if(type==POSITION_TYPE_SELL && cntSell==1){
               nextSellPrice=PositionGetDouble(POSITION_PRICE_OPEN)+pointGridStep*_Point;
               //closeSellPositions = last_open_price - pointTP*_Point;
            }
         }
      }
 
//--------------------------------------------------------------
//Symbol 0 Next Positions >>>>>>
//--------------------------------------------------------------  
      if(cntBuy_s0==0){
         nextBuyPrice_s0=0;
      }
      if(cntSell_s0==0){
         nextSellPrice_s0=0;
      }         
      if(PositionsTotal()>=1){
         int total = PositionsTotal();
         for(int i=total-1; i>=0; i--){
            ulong ticket = PositionGetTicket(i);
            string symbol = PositionGetSymbol(i);  
            long type;
            if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return;}          
            if(symbol==symbolArray[0] && type==POSITION_TYPE_BUY && cntBuy_s0==1){
               nextBuyPrice_s0 = PositionGetDouble(POSITION_PRICE_OPEN)-pointGridStep*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);
            }  
            if(symbol==symbolArray[0] && type==POSITION_TYPE_SELL && cntSell_s0==1){
               nextSellPrice_s0=PositionGetDouble(POSITION_PRICE_OPEN)+pointGridStep*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);
            }
         }
      }
      
//--------------------------------------------------------------
//Symbol 1 Next Positions >>>>>>
//--------------------------------------------------------------  
      if(cntBuy_s1==0){
         nextBuyPrice_s1=0;
      }
      if(cntSell_s1==0){
         nextSellPrice_s1=0;
      }         
      if(PositionsTotal()>=1){
         int total = PositionsTotal();
         for(int i=total-1; i>=0; i--){
            ulong ticket = PositionGetTicket(i);
            string symbol = PositionGetSymbol(i);  
            long type;
            if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return;}          
            if(symbol==symbolArray[1] && type==POSITION_TYPE_BUY && cntBuy_s1==1){
               nextBuyPrice_s1 = PositionGetDouble(POSITION_PRICE_OPEN)-pointGridStep*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);
            }  
            if(symbol==symbolArray[1] && type==POSITION_TYPE_SELL && cntSell_s1==1){
               nextSellPrice_s1=PositionGetDouble(POSITION_PRICE_OPEN)+pointGridStep*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);
            }
         }
      }        
 
//--------------------------------------------------------------
//Symbol 2 Next Positions >>>>>>
//--------------------------------------------------------------  
      if(cntBuy_s2==0){
         nextBuyPrice_s2=0;
      }
      if(cntSell_s2==0){
         nextSellPrice_s2=0;
      }         
      if(PositionsTotal()>=1){
         int total = PositionsTotal();
         for(int i=total-1; i>=0; i--){
            ulong ticket = PositionGetTicket(i);
            string symbol = PositionGetSymbol(i);  
            long type;
            if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return;}          
            if(symbol==symbolArray[2] && type==POSITION_TYPE_BUY && cntBuy_s2==1){
               nextBuyPrice_s2 = PositionGetDouble(POSITION_PRICE_OPEN)-pointGridStep*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);
            }  
            if(symbol==symbolArray[2] && type==POSITION_TYPE_SELL && cntSell_s2==1){
               nextSellPrice_s2=PositionGetDouble(POSITION_PRICE_OPEN)+pointGridStep*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);
            }
         }
      } 
 
                     
   
//--                                                 //++++--------------OPEN-MARTINGALE-POSITIONS------------------++++\\

//--------------------------------------------------------------
//Current Symbol Martingale Positions >>>>>>                                     //*******--TO-STOP-[Market Close]-ERROR-MOVE-THESE-OUTSIDE-OF-BARSTOTAL--********//
//--------------------------------------------------------------  
//      double Ask = NormalizeDouble(currentTick.ask,_Digits);     
//      if(Ask <= nextBuyPrice){
//         if(cntBuy < InpMaxPositions && cntBuy > 0){   
//            martiLotSize = NormalizeDouble((last_volume_buy*InpLotMultiplier),2);
//            if(martiLotSize > InpMaxLot){martiLotSize=InpMaxLot;}   
//            trade.Buy(martiLotSize,_Symbol,Ask,0,0,NULL);
//            nextBuyPrice = Ask - pointGridStep*_Point;                    
//         }   
//      }      
//      double Bid = NormalizeDouble(currentTick.bid,_Digits);      
//      if(Bid >= nextSellPrice){
//         if(cntSell < InpMaxPositions && cntSell > 0){
//            martiLotSize = NormalizeDouble((last_volume_sell*InpLotMultiplier),2); 
//            if(martiLotSize > InpMaxLot){martiLotSize=InpMaxLot;}                   
//            trade.Sell(martiLotSize,_Symbol,Bid,0,0,NULL);
//            nextSellPrice = Bid + pointGridStep*_Point;
//         }
//      }
//      
////--------------------------------------------------------------
////Symbol 0 Martingale Positions >>>>>>
////--------------------------------------------------------------     
//      if(Ask_s0 <= nextBuyPrice_s0){
//         if(cntBuy_s0 < InpMaxPositions && cntBuy_s0 > 0){   
//            martiLotSize_s0 = NormalizeDouble((last_volume_buy_s0*InpLotMultiplier),2);
//            if(martiLotSize_s0 > InpMaxLot){martiLotSize_s0=InpMaxLot;}   
//            trade.Buy(martiLotSize_s0,symbolArray[0],Ask_s0,0,0,NULL);
//            nextBuyPrice_s0 = Ask_s0 - pointGridStep*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);                    
//         }   
//      }          
//      if(Bid_s0 >= nextSellPrice_s0){
//         if(cntSell_s0 < InpMaxPositions && cntSell_s0 > 0){
//            martiLotSize_s0 = NormalizeDouble((last_volume_sell_s0*InpLotMultiplier),2); 
//            if(martiLotSize_s0 > InpMaxLot){martiLotSize_s0=InpMaxLot;}                   
//            trade.Sell(martiLotSize_s0,symbolArray[0],Bid_s0,0,0,NULL);
//            nextSellPrice_s0 = Bid_s0 + pointGridStep*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);
//         }
//      }      
//      
////--------------------------------------------------------------
////Symbol 1 Martingale Positions >>>>>>
////--------------------------------------------------------------     
//      if(Ask_s1 <= nextBuyPrice_s1){
//         if(cntBuy_s1 < InpMaxPositions && cntBuy_s1 > 0){   
//            martiLotSize_s1 = NormalizeDouble((last_volume_buy_s1*InpLotMultiplier),2);
//            if(martiLotSize_s1 > InpMaxLot){martiLotSize_s1=InpMaxLot;}   
//            trade.Buy(martiLotSize_s1,symbolArray[1],Ask_s1,0,0,NULL);
//            nextBuyPrice_s1 = Ask_s1 - pointGridStep*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);                    
//         }   
//      }          
//      if(Bid_s1 >= nextSellPrice_s1){
//         if(cntSell_s1 < InpMaxPositions && cntSell_s1 > 0){
//            martiLotSize_s1 = NormalizeDouble((last_volume_sell_s1*InpLotMultiplier),2); 
//            if(martiLotSize_s1 > InpMaxLot){martiLotSize_s1=InpMaxLot;}                   
//            trade.Sell(martiLotSize_s1,symbolArray[1],Bid_s1,0,0,NULL);
//            nextSellPrice_s1 = Bid_s1 + pointGridStep*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);
//         }
//      }       
//
////--------------------------------------------------------------
////Symbol 2 Martingale Positions >>>>>>
////--------------------------------------------------------------     
//      if(Ask_s2 <= nextBuyPrice_s2){
//         if(cntBuy_s2 < InpMaxPositions && cntBuy_s2 > 0){   
//            martiLotSize_s2 = NormalizeDouble((last_volume_buy_s2*InpLotMultiplier),2);
//            if(martiLotSize_s2 > InpMaxLot){martiLotSize_s2=InpMaxLot;}   
//            trade.Buy(martiLotSize_s2,symbolArray[2],Ask_s2,0,0,NULL);
//            nextBuyPrice_s2 = Ask_s2 - pointGridStep*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);                    
//         }   
//      }          
//      if(Bid_s2 >= nextSellPrice_s2){
//         if(cntSell_s2 < InpMaxPositions && cntSell_s2 > 0){
//            martiLotSize_s2 = NormalizeDouble((last_volume_sell_s2*InpLotMultiplier),2); 
//            if(martiLotSize_s2 > InpMaxLot){martiLotSize_s2=InpMaxLot;}                   
//            trade.Sell(martiLotSize_s2,symbolArray[2],Bid_s2,0,0,NULL);
//            nextSellPrice_s2 = Bid_s2 + pointGridStep*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);
//         }
//      }       
                                    
   }//---Close-of-BarsTotal---//







                                                                                    //-----------------------------------------------------//


//-----------------------------------------------------
//-CURRENT-SYMBOL-Open-Position
//-----------------------------------------------------
   //Sell Position
   if(barOneClose > bbUpperBuffer[1] && bearsPBuffer[1] > InpBearBull && bearsPBuffer[2] > InpBearBull && barOneClose > ema450Buffer[1]){                  
      if(InpMartingale==false){
         TP = currentTick.bid - pointTP*_Point;
         SL = currentTick.bid + SLsize;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }
      if(InpMartingale==true){
         TP = 0;
         SL = 0;           
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),_Digits);
         }           
      }         
      if(cntSell < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
            }        
         }
         if(InpTrendFilter==true && ema50Buffer[1]<ema200Buffer[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
            }        
         }
      }            
   }
   
   //BUY position
   if(barOneClose < bbLowerBuffer[1] && bullsPBuffer[1] < bullNegative && bullsPBuffer[2] < bullNegative && barOneClose < ema450Buffer[1]){                           
      if(InpMartingale==false){
         TP = currentTick.ask + pointTP*_Point;
         SL = currentTick.ask - SLsize;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }          
      if(InpMartingale==true){
         TP = 0;
         SL = 0;
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }                      
      }         
      if(cntBuy < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);
            }     
         }
         if(InpTrendFilter==true && ema50Buffer[1] > ema200Buffer[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);
            }    
         }
      }     
   }

//-----------------------------------------------------
//-SYMBOL-0-Open-Position
//-----------------------------------------------------
   //Sell Position
   if(barOneClose_s0 > bbUpperBuffer_s0[1] && bearsPBuffer_s0[1] > InpBearBull && bearsPBuffer_s0[2] > InpBearBull && barOneClose_s0 > ema450Buffer_s0[1]){                  
      if(InpMartingale==false){
         TP = Bid_s0 - pointTP*s0_point;
         SL = Bid_s0 + pointSL*s0_point;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }
      if(InpMartingale==true){
         TP = 0;
         SL = 0;           
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }           
      }         
      if(cntSell_s0 < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,symbolArray[0],Bid_s0,SL,TP,NULL);
            }        
         }
         if(InpTrendFilter==true && ema50Buffer_s0[1]<ema200Buffer_s0[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,symbolArray[0],Bid_s0,SL,TP,NULL);
            }        
         }
      }            
   }
   
   //BUY position
   if(barOneClose_s0 < bbLowerBuffer_s0[1] && bullsPBuffer_s0[1] < bullNegative && bullsPBuffer_s0[2] < bullNegative && barOneClose_s0 < ema450Buffer_s0[1]){                           
      if(InpMartingale==false){
         TP = Ask_s0 + pointTP*s0_point;
         SL = Ask_s0 - pointSL*s0_point;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }          
      if(InpMartingale==true){
         TP = 0;
         SL = 0;
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }                      
      }         
      if(cntBuy_s0 < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,symbolArray[0],Ask_s0,SL,TP,NULL);
            }     
         }
         if(InpTrendFilter==true && ema50Buffer_s0[1] > ema200Buffer_s0[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,symbolArray[0],Ask_s0,SL,TP,NULL);
            }    
         }
      }     
   }      

//-----------------------------------------------------
//-SYMBOL-1-Open-Position
//-----------------------------------------------------
   //Sell Position
   if(barOneClose_s1 > bbUpperBuffer_s1[1] && bearsPBuffer_s1[1] > InpBearBull && bearsPBuffer_s1[2] > InpBearBull && barOneClose_s1 > ema450Buffer_s1[1]){                  
      if(InpMartingale==false){
         TP = Bid_s1 - pointTP*s1_point;
         SL = Bid_s1 + pointSL*s1_point;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }
      if(InpMartingale==true){
         TP = 0;
         SL = 0;           
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }           
      }         
      if(cntSell_s1 < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,symbolArray[1],Bid_s1,SL,TP,NULL);
            }        
         }
         if(InpTrendFilter==true && ema50Buffer_s1[1]<ema200Buffer_s1[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,symbolArray[1],Bid_s1,SL,TP,NULL);
            }        
         }
      }            
   }
   
   //BUY position
   if(barOneClose_s1 < bbLowerBuffer_s1[1] && bullsPBuffer_s1[1] < bullNegative && bullsPBuffer_s1[2] < bullNegative && barOneClose_s1 < ema450Buffer_s1[1]){                           
      if(InpMartingale==false){
         TP = Ask_s1 + pointTP*s1_point;
         SL = Ask_s1 - pointSL*s1_point;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }          
      if(InpMartingale==true){
         TP = 0;
         SL = 0;
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }                      
      }         
      if(cntBuy_s1 < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,symbolArray[1],Ask_s1,SL,TP,NULL);
            }     
         }
         if(InpTrendFilter==true && ema50Buffer_s1[1] > ema200Buffer_s1[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,symbolArray[1],Ask_s1,SL,TP,NULL);
            }    
         }
      }     
   }

//-----------------------------------------------------
//-SYMBOL-2-Open-Position
//-----------------------------------------------------
   //Sell Position
   if(barOneClose_s2 > bbUpperBuffer_s2[1] && bearsPBuffer_s2[1] > InpBearBull && bearsPBuffer_s2[2] > InpBearBull && barOneClose_s2 > ema450Buffer_s2[1]){                  
      if(InpMartingale==false){
         TP = Bid_s2 - pointTP*s2_point;
         SL = Bid_s2 + pointSL*s2_point;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }
      if(InpMartingale==true){
         TP = 0;
         SL = 0;           
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }           
      }         
      if(cntSell_s2 < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,symbolArray[2],Bid_s2,SL,TP,NULL);
            }        
         }
         if(InpTrendFilter==true && ema50Buffer_s2[1]<ema200Buffer_s2[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Sell(lotSize,symbolArray[2],Bid_s2,SL,TP,NULL);
            }        
         }
      }            
   }
   
   //BUY position
   if(barOneClose_s2 < bbLowerBuffer_s2[1] && bullsPBuffer_s2[1] < bullNegative && bullsPBuffer_s2[2] < bullNegative && barOneClose_s2 < ema450Buffer_s2[1]){                           
      if(InpMartingale==false){
         TP = Ask_s2 + pointTP*s2_point;
         SL = Ask_s2 - pointSL*s2_point;
         if(InpLotType == ENUM_PERC){
            lotSize = calcLots(InpRisk,SLsize);
         }
         else{
            lotSize = InpLotSize;
         }
      }          
      if(InpMartingale==true){
         TP = 0;
         SL = 0;
         if(InpAutoLot==false){
            lotSize = InpStartLot;
         }
         if(InpAutoLot==true){              
            lotSize = NormalizeDouble((accountInfo.Balance() / InpAutoLotPer * InpStartLot),2);
         }                      
      }         
      if(cntBuy_s2 < 1){
         if(InpTrendFilter==false){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,symbolArray[2],Ask_s2,SL,TP,NULL);
            }     
         }
         if(InpTrendFilter==true && ema50Buffer_s2[1] > ema200Buffer_s2[1]){
            if(InpStopFriday==true && today.day_of_week==5){
               return;
            }
            else{
               trade.Buy(lotSize,symbolArray[2],Ask_s2,SL,TP,NULL);
            }    
         }
      }     
   }



                                                                              //------------------------------------------------------//

//--------------------------------------------------------------
//Current Symbol Martingale Positions >>>>>>                               
//-------------------------------------------------------------- 
   double Ask = NormalizeDouble(currentTick.ask,_Digits);     
   if(Ask <= nextBuyPrice){
      if(cntBuy < InpMaxPositions && cntBuy > 0){   
         martiLotSize = NormalizeDouble((last_volume_buy*InpLotMultiplier),2);
         if(martiLotSize > InpMaxLot){martiLotSize=InpMaxLot;}   
         trade.Buy(martiLotSize,_Symbol,Ask,0,0,NULL);
         nextBuyPrice = Ask - pointGridStep*_Point;                    
      }   
   }      
   double Bid = NormalizeDouble(currentTick.bid,_Digits);      
   if(Bid >= nextSellPrice){
      if(cntSell < InpMaxPositions && cntSell > 0){
         martiLotSize = NormalizeDouble((last_volume_sell*InpLotMultiplier),2); 
         if(martiLotSize > InpMaxLot){martiLotSize=InpMaxLot;}                   
         trade.Sell(martiLotSize,_Symbol,Bid,0,0,NULL);
         nextSellPrice = Bid + pointGridStep*_Point;
      }
   }
      
//--------------------------------------------------------------
//Symbol 0 Martingale Positions >>>>>>
//--------------------------------------------------------------     
   if(Ask_s0 <= nextBuyPrice_s0){
      if(cntBuy_s0 < InpMaxPositions && cntBuy_s0 > 0){   
         martiLotSize_s0 = NormalizeDouble((last_volume_buy_s0*InpLotMultiplier),2);
         if(martiLotSize_s0 > InpMaxLot){martiLotSize_s0=InpMaxLot;}   
         trade.Buy(martiLotSize_s0,symbolArray[0],Ask_s0,0,0,NULL);
         nextBuyPrice_s0 = Ask_s0 - pointGridStep*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);                    
      }   
   }          
   if(Bid_s0 >= nextSellPrice_s0){
      if(cntSell_s0 < InpMaxPositions && cntSell_s0 > 0){
         martiLotSize_s0 = NormalizeDouble((last_volume_sell_s0*InpLotMultiplier),2); 
         if(martiLotSize_s0 > InpMaxLot){martiLotSize_s0=InpMaxLot;}                   
         trade.Sell(martiLotSize_s0,symbolArray[0],Bid_s0,0,0,NULL);
         nextSellPrice_s0 = Bid_s0 + pointGridStep*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);
      }
   }      
      
//--------------------------------------------------------------
//Symbol 1 Martingale Positions >>>>>>
//--------------------------------------------------------------     
   if(Ask_s1 <= nextBuyPrice_s1){
      if(cntBuy_s1 < InpMaxPositions && cntBuy_s1 > 0){   
         martiLotSize_s1 = NormalizeDouble((last_volume_buy_s1*InpLotMultiplier),2);
         if(martiLotSize_s1 > InpMaxLot){martiLotSize_s1=InpMaxLot;}   
         trade.Buy(martiLotSize_s1,symbolArray[1],Ask_s1,0,0,NULL);
         nextBuyPrice_s1 = Ask_s1 - pointGridStep*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);                    
      }   
   }          
   if(Bid_s1 >= nextSellPrice_s1){
      if(cntSell_s1 < InpMaxPositions && cntSell_s1 > 0){
         martiLotSize_s1 = NormalizeDouble((last_volume_sell_s1*InpLotMultiplier),2); 
         if(martiLotSize_s1 > InpMaxLot){martiLotSize_s1=InpMaxLot;}                   
         trade.Sell(martiLotSize_s1,symbolArray[1],Bid_s1,0,0,NULL);
         nextSellPrice_s1 = Bid_s1 + pointGridStep*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);
      }
   }       

//--------------------------------------------------------------
//Symbol 2 Martingale Positions >>>>>>
//--------------------------------------------------------------     
   if(Ask_s2 <= nextBuyPrice_s2){
      if(cntBuy_s2 < InpMaxPositions && cntBuy_s2 > 0){   
         martiLotSize_s2 = NormalizeDouble((last_volume_buy_s2*InpLotMultiplier),2);
         if(martiLotSize_s2 > InpMaxLot){martiLotSize_s2=InpMaxLot;}   
         trade.Buy(martiLotSize_s2,symbolArray[2],Ask_s2,0,0,NULL);
         nextBuyPrice_s2 = Ask_s2 - pointGridStep*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);                    
      }   
   }          
   if(Bid_s2 >= nextSellPrice_s2){
      if(cntSell_s2 < InpMaxPositions && cntSell_s2 > 0){
         martiLotSize_s2 = NormalizeDouble((last_volume_sell_s2*InpLotMultiplier),2); 
         if(martiLotSize_s2 > InpMaxLot){martiLotSize_s2=InpMaxLot;}                   
         trade.Sell(martiLotSize_s2,symbolArray[2],Bid_s2,0,0,NULL);
         nextSellPrice_s2 = Bid_s2 + pointGridStep*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);
      }
   } 













//--                                                //++++--------------CLOSE-MARTINGALE-POSITIONS------------------++++\\

//--------------------------------------------------------------
//Current Symbol Close Martingale Positions >>>>>>
//-------------------------------------------------------------- 
   if(InpMartingale==true){
      if(currentTick.ask >= breakEvenLineBuy + pointTP*_Point && cntBuy > 0){
         ClosePositions(POSITION_TYPE_BUY,_Symbol);
      }    
      if(currentTick.bid <= breakEvenLineSell - pointTP*_Point && cntSell > 0){
         ClosePositions(POSITION_TYPE_SELL,_Symbol);
      }       
      if(accountInfo.FreeMargin()<= accountInfo.Balance()/2.0){
         return;
      }    
   }   
   tpBuyLine = breakEvenLineBuy + pointTP*_Point;
   tpSellLine = breakEvenLineSell - pointTP*_Point;
 
   
//--------------------------------------------------------------
//Symbol 0 Close Martingale Positions >>>>>>
//-------------------------------------------------------------- 
   if(InpMartingale==true){                                                                                           //try symbol_ticksize
      if(SymbolInfoDouble(symbolArray[0],SYMBOL_ASK) >= breakEvenLineBuy_s0 + pointTP*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT) && cntBuy_s0 > 0){
         ClosePositions(POSITION_TYPE_BUY,symbolArray[0]);
      }    
      if(SymbolInfoDouble(symbolArray[0],SYMBOL_BID) <= breakEvenLineSell_s0 - pointTP*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT) && cntSell_s0 > 0){
         ClosePositions(POSITION_TYPE_SELL,symbolArray[0]);
      }       
      if(accountInfo.FreeMargin()<= accountInfo.Balance()/2.0){
         return;
      }    
   }
   
   tpBuyLine_s0 = breakEvenLineBuy_s0 + pointTP*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT);
   tpSellLine_s0 = breakEvenLineSell_s0 - pointTP*SymbolInfoDouble(symbolArray[0],SYMBOL_POINT); 
      

//--------------------------------------------------------------
//Symbol 1 Close Martingale Positions >>>>>>
//-------------------------------------------------------------- 
   if(InpMartingale==true){                                                                                           //try symbol_ticksize
      if(SymbolInfoDouble(symbolArray[1],SYMBOL_ASK) >= breakEvenLineBuy_s1 + pointTP*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT) && cntBuy_s1 > 0){
         ClosePositions(POSITION_TYPE_BUY,symbolArray[1]);
      }    
      if(SymbolInfoDouble(symbolArray[1],SYMBOL_BID) <= breakEvenLineSell_s1 - pointTP*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT) && cntSell_s1 > 0){
         ClosePositions(POSITION_TYPE_SELL,symbolArray[1]);
      }       
      if(accountInfo.FreeMargin()<= accountInfo.Balance()/2.0){
         return;
      }    
   }
   
   tpBuyLine_s1 = breakEvenLineBuy_s1 + pointTP*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT);
   tpSellLine_s1 = breakEvenLineSell_s1 - pointTP*SymbolInfoDouble(symbolArray[1],SYMBOL_POINT); 

//--------------------------------------------------------------
//Symbol 2 Close Martingale Positions >>>>>>
//-------------------------------------------------------------- 
   if(InpMartingale==true){                                                                                           //try symbol_ticksize
      if(SymbolInfoDouble(symbolArray[2],SYMBOL_ASK) >= breakEvenLineBuy_s2 + pointTP*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT) && cntBuy_s2 > 0){
         ClosePositions(POSITION_TYPE_BUY,symbolArray[2]);
      }    
      if(SymbolInfoDouble(symbolArray[2],SYMBOL_BID) <= breakEvenLineSell_s2 - pointTP*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT) && cntSell_s2 > 0){
         ClosePositions(POSITION_TYPE_SELL,symbolArray[2]);
      }       
      if(accountInfo.FreeMargin()<= accountInfo.Balance()/2.0){
         return;
      }    
   }
   
   tpBuyLine_s2 = breakEvenLineBuy_s2 + pointTP*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);
   tpSellLine_s2 = breakEvenLineSell_s2 - pointTP*SymbolInfoDouble(symbolArray[2],SYMBOL_POINT);



//--                                             //++++---------------MARTI-FAILED-OPEN-POSITION-CHECK------------------++++\\   
   
   if(cntBuy==0){
      close_buy_range=0;
   }
   if(cntSell==0){
      close_sell_range=0;
   }
   
   if(PositionsTotal() >= 1){
      
      if(cntBuy>=1){
         close_buy_range = last_open_price_buy - (pointGridStep*5*_Point);
         if(currentTick.ask <= close_buy_range){
            ClosePositions(POSITION_TYPE_BUY,_Symbol);
         }
      }     
   
      if(cntSell>=1){
         close_sell_range = last_open_price_sell + (pointGridStep*5*_Point); 
         if(currentTick.bid >= close_sell_range){
            ClosePositions(POSITION_TYPE_SELL,_Symbol);
         } 
      }            
   }     



//--                                                     //++++--------------BREAKEVEN-LINE-RESET------------------++++\\
                                                         
   //CURRENT SYMBOL-----------
   if(cntBuy==0){
      totalBuyLots=0;
      totalBuyPrice=0;
      breakEvenLineBuy=0;
   }
   if(cntSell==0){
      totalSellLots=0;
      totalSellPrice=0;
      breakEvenLineSell=0;
   }
   
   //SYMBOL 0-----------------
   if(cntBuy_s0==0){
      totalBuyLots_s0=0;
      totalBuyPrice_s0=0;
      breakEvenLineBuy_s0=0;
   }
   if(cntSell_s0==0){
      totalSellLots_s0=0;
      totalSellPrice_s0=0;
      breakEvenLineSell_s0=0;
   }   

   //SYMBOL 1-----------------
   if(cntBuy_s1==0){
      totalBuyLots_s1=0;
      totalBuyPrice_s1=0;
      breakEvenLineBuy_s1=0;
   }
   if(cntSell_s1==0){
      totalSellLots_s1=0;
      totalSellPrice_s1=0;
      breakEvenLineSell_s1=0;
   }  

   //SYMBOL 2-----------------
   if(cntBuy_s2==0){
      totalBuyLots_s2=0;
      totalBuyPrice_s2=0;
      breakEvenLineBuy_s2=0;
   }
   if(cntSell_s2==0){
      totalSellLots_s2=0;
      totalSellPrice_s2=0;
      breakEvenLineSell_s2=0;
   }  

//--                                                       //++++---------------OBJECT-CREATE------------------++++\\       

   //Buy Breakeven Line
   if(cntBuy>1){
      ObjectCreate(0,"BE_BUY",OBJ_HLINE,0,TimeCurrent(),breakEvenLineBuy);
      ObjectSetInteger(0,"BE_BUY",OBJPROP_COLOR,InpBEcolor);
      ObjectSetInteger(0,"BE_BUY",OBJPROP_STYLE,STYLE_DASH);
      if(ObjectGetDouble(0,"BE_BUY",OBJPROP_PRICE,1) != breakEvenLineBuy){
         ObjectSetDouble(0,"BE_BUY",OBJPROP_PRICE,breakEvenLineBuy);
      }
   }
   if(cntBuy<2){
      ObjectDelete(0,"BE_BUY");
   }          
   
   //Sell Breakeven Line
   if(cntSell>1){
      ObjectCreate(0,"BE_SELL",OBJ_HLINE,0,TimeCurrent(),breakEvenLineSell);
      ObjectSetInteger(0,"BE_SELL",OBJPROP_COLOR,InpBEcolor);
      ObjectSetInteger(0,"BE_SELL",OBJPROP_STYLE,STYLE_DASH);
      if(ObjectGetDouble(0,"BE_SELL",OBJPROP_PRICE,1) != breakEvenLineSell){
         ObjectSetDouble(0,"BE_SELL",OBJPROP_PRICE,breakEvenLineSell);
      }
   }
   if(cntSell<2){
      ObjectDelete(0,"BE_SELL");
   }  
   
   //Buy TP Line
   ObjectCreate(0,"TP_BUY",OBJ_HLINE,0,TimeCurrent(),tpBuyLine);
   ObjectSetInteger(0,"TP_BUY",OBJPROP_COLOR,InpTPcolor);
   ObjectSetInteger(0,"TP_BUY",OBJPROP_STYLE,STYLE_DASH);
   if(ObjectGetDouble(0,"TP_BUY",OBJPROP_PRICE,1) != tpBuyLine){
      ObjectSetDouble(0,"TP_BUY",OBJPROP_PRICE,tpBuyLine);
   }   
    
   //Sell TP Line
   ObjectCreate(0,"TP_SELL",OBJ_HLINE,0,TimeCurrent(),tpSellLine);
   ObjectSetInteger(0,"TP_SELL",OBJPROP_COLOR,InpTPcolor);
   ObjectSetInteger(0,"TP_SELL",OBJPROP_STYLE,STYLE_DASH);
   if(ObjectGetDouble(0,"TP_SELL",OBJPROP_PRICE,1) != tpSellLine){
      ObjectSetDouble(0,"TP_SELL",OBJPROP_PRICE,tpSellLine);
   }
   
   datetime textTime = TimeCurrent() + 2400;
   
   //Text BUY TP Line
   ObjectCreate(0,"BUYTP_TEXT",OBJ_TEXT,0,textTime,tpBuyLine);
   ObjectSetInteger(0,"BUYTP_TEXT",OBJPROP_COLOR,InpTPcolor);
   ObjectSetInteger(0,"BUYTP_TEXT",OBJPROP_FONTSIZE,10);
   ObjectSetString(0,"BUYTP_TEXT",OBJPROP_FONT,"HoloLens MDL2 Assets");
   ObjectSetString(0,"BUYTP_TEXT",OBJPROP_TEXT,"BUY TP");
   if(ObjectGetDouble(0,"BUYTP_TEXT",OBJPROP_PRICE,1) != tpBuyLine){
      ObjectSetDouble(0,"BUYTP_TEXT",OBJPROP_PRICE,tpBuyLine);
   }
   
   //Text BUY BE Line
   if(cntBuy>1){
      ObjectCreate(0,"BUYBE_TEXT",OBJ_TEXT,0,textTime,breakEvenLineBuy);
      ObjectSetInteger(0,"BUYBE_TEXT",OBJPROP_COLOR,InpBEcolor);
      ObjectSetInteger(0,"BUYBE_TEXT",OBJPROP_FONTSIZE,10);
      ObjectSetString(0,"BUYBE_TEXT",OBJPROP_FONT,"HoloLens MDL2 Assets");
      ObjectSetString(0,"BUYBE_TEXT",OBJPROP_TEXT,"BUY BE");
      if(ObjectGetDouble(0,"BUYBE_TEXT",OBJPROP_PRICE,1) != breakEvenLineBuy){
         ObjectSetDouble(0,"BUYBE_TEXT",OBJPROP_PRICE,breakEvenLineBuy);
      }
   }
   if(cntBuy<2){
      ObjectDelete(0,"BUYBE_TEXT");
   }  

      
   double textTPSellLine = tpSellLine + 50*_Point;
   double textBESellLine = breakEvenLineSell + 50*_Point; 
   
   //Text SELL TP Line
   ObjectCreate(0,"SELLTP_TEXT",OBJ_TEXT,0,textTime,textTPSellLine);
   ObjectSetInteger(0,"SELLTP_TEXT",OBJPROP_COLOR,InpTPcolor);
   ObjectSetInteger(0,"SELLTP_TEXT",OBJPROP_FONTSIZE,10);
   ObjectSetString(0,"SELLTP_TEXT",OBJPROP_FONT,"HoloLens MDL2 Assets");
   ObjectSetString(0,"SELLTP_TEXT",OBJPROP_TEXT,"SELL TP");
   if(ObjectGetDouble(0,"SELLTP_TEXT",OBJPROP_PRICE,1) != textTPSellLine){
      ObjectSetDouble(0,"SELLTP_TEXT",OBJPROP_PRICE,textTPSellLine);
   } 
   
   //Text SELL BE Line
   if(cntSell>1){
      ObjectCreate(0,"SELLBE_TEXT",OBJ_TEXT,0,textTime,textBESellLine);
      ObjectSetInteger(0,"SELLBE_TEXT",OBJPROP_COLOR,InpBEcolor);
      ObjectSetInteger(0,"SELLBE_TEXT",OBJPROP_FONTSIZE,10);
      ObjectSetString(0,"SELLBE_TEXT",OBJPROP_FONT,"HoloLens MDL2 Assets");
      ObjectSetString(0,"SELLBE_TEXT",OBJPROP_TEXT,"SELL BE");
      if(ObjectGetDouble(0,"SELLBE_TEXT",OBJPROP_PRICE,1) != textBESellLine){
         ObjectSetDouble(0,"SELLBE_TEXT",OBJPROP_PRICE,textBESellLine);
      }
   }
   if(cntSell<2){
      ObjectDelete(0,"SELLBE_TEXT");
   }
 
 
 
   
//--                                                   //++++-----------------BALANCE-DRAWDOWN-CHECK------------------++++\\   
 
   if(InpDDbalance>0){
      if(accountInfo.Equity() <= accountInfo.Balance() - InpDDbalance){
         ClosePositions(POSITION_TYPE_BUY,_Symbol);
         ClosePositions(POSITION_TYPE_SELL,_Symbol);
      }           
   }   
   

   if(InpProfitDisplay==true){
      DayProfit();   
   }
}




                                                          //++++-----------------CUSTOM-FUNCTIONS------------------++++\\
//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

//Calulate Lot Size for Percentage based risk
double calcLots(double riskPercent, double slDistance){

   double      tickSize       =  SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double      tickValue      =  SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double      lotStep        =  SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(tickSize == 0 || tickValue == 0 || lotStep == 0){
      Print(__FUNCTION__,"> Lotsize cannot be calculated..");
      return 0;
   }
   
   double      riskMoney      =  AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100;
   double      moneyLotStep   =  (slDistance / tickSize) * tickValue * lotStep;

   
   if(moneyLotStep == 0){
      Print(__FUNCTION__,"> Lotsize cannot be calculated..");
      return 0;
   }
   
   double      lots           =  MathFloor(riskMoney / moneyLotStep) * lotStep;
     
   return lots;
}


//---Count-Open-Positions-------------------------------------------------------------------+
bool CountOpenPositions(int &posBuy, int &posSell, string s_symbol){
   
   posBuy   = 0;
   posSell  = 0;
   int total = PositionsTotal();
   for(int i=total-1; i>=0; i--){
      ulong ticket = PositionGetTicket(i);
      string symbol = PositionGetSymbol(i);
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
      if(magic == InpMagicNumber && symbol == s_symbol){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return false;}
         if(type == POSITION_TYPE_BUY){posBuy++;}
         if(type == POSITION_TYPE_SELL){posSell++;}
      }
   }
   
   return true;
}


//---Breakeven-BUY-function------------------------------------------------------------------+
void checkBreakEvenStopBuy(double ask){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL > openPrice - InpStopLoss*_Point){
         return;
      }
      
      else if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         //double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double BEbuyTP = InpTakeProfit == 0 ? 0 : openPrice + InpTakeProfit * _Point;
         if(ask > (openPrice + InpBreakeven * _Point)){
            trade.PositionModify(positionTicket,openPrice,BEbuyTP);   
         }
      }
   }
}




//---Breakeven-SELL-function----------------------------------------------------------------+
void checkBreakEvenStopSell(double bid){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL < openPrice + InpStopLoss*_Point){
         return;
      }
      
      else if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         //double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double BEsellTP = InpTakeProfit == 0 ? 0 : openPrice - InpTakeProfit * _Point;
         if(bid < (openPrice - InpBreakeven * _Point)){
            trade.PositionModify(positionTicket,openPrice,BEsellTP);   
         }
      }
   }
}


//-TradeTransaction-function-----------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result){

//---get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
//---if transaction is result of addition of the transaction in history
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
         
         
//------------------------------------------------------------------
//-CURRENT-SYMBOL->>>>>>>>>  
//------------------------------------------------------------------        
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
            last_volume = 0.0;                              //create last_volume_sell, last_volume_buy, last_open_price_sell etc.
            last_position_type = -1;
         }
      }
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_BUY && deal_entry==DEAL_ENTRY_IN){
            totalBuyPrice += (last_volume_buy*last_open_price_buy);
            totalBuyLots += last_volume_buy;
            breakEvenLineBuy = totalBuyPrice/totalBuyLots;
         }
         if(deal_type==DEAL_TYPE_SELL && deal_entry==DEAL_ENTRY_IN){
            totalSellPrice += (last_volume_sell*last_open_price_sell);
            totalSellLots += last_volume_sell;
            breakEvenLineSell = totalSellPrice/totalSellLots;
         }         
      }

//------------------------------------------------------------------
//-SYMBOL-0->>>>>>>>>  
//------------------------------------------------------------------     
      if(deal_symbol==symbolArray[0] && deal_magic==InpMagicNumber){
         if(deal_entry==DEAL_ENTRY_IN && (deal_type==DEAL_TYPE_BUY || DEAL_TYPE_SELL)){         
            if(deal_type==DEAL_TYPE_BUY){
               last_open_price_buy_s0 = deal_price;
               last_volume_buy_s0 = deal_volume;
            }
            if(deal_type==DEAL_TYPE_SELL){
               last_open_price_sell_s0 = deal_price;
               last_volume_sell_s0 = deal_volume;
            }           
            last_open_price_s0 = deal_price;
            last_volume_S0 = deal_volume;
            last_position_type_s0 = (deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_BUY:POSITION_TYPE_SELL;   
         }
         else if(deal_entry==DEAL_ENTRY_OUT){
            last_open_price_s0 = 0.0;
            last_volume_S0 = 0.0;                              //create last_volume_sell, last_volume_buy, last_open_price_sell etc.
            last_position_type_s0 = -1;
         }
      }
      if(deal_symbol==symbolArray[0] && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_BUY && deal_entry==DEAL_ENTRY_IN){
            totalBuyPrice_s0 += (last_volume_buy_s0*last_open_price_buy_s0);
            totalBuyLots_s0 += last_volume_buy_s0;
            breakEvenLineBuy_s0 = totalBuyPrice_s0/totalBuyLots_s0;
         }
         if(deal_type==DEAL_TYPE_SELL && deal_entry==DEAL_ENTRY_IN){
            totalSellPrice_s0 += (last_volume_sell_s0*last_open_price_sell_s0);
            totalSellLots_s0 += last_volume_sell_s0;
            breakEvenLineSell_s0 = totalSellPrice_s0/totalSellLots_s0;
         }         
      }
 
//------------------------------------------------------------------
//-SYMBOL-1->>>>>>>>>  
//------------------------------------------------------------------     
      if(deal_symbol==symbolArray[1] && deal_magic==InpMagicNumber){
         if(deal_entry==DEAL_ENTRY_IN && (deal_type==DEAL_TYPE_BUY || DEAL_TYPE_SELL)){         
            if(deal_type==DEAL_TYPE_BUY){
               last_open_price_buy_s1 = deal_price;
               last_volume_buy_s1 = deal_volume;
            }
            if(deal_type==DEAL_TYPE_SELL){
               last_open_price_sell_s1 = deal_price;
               last_volume_sell_s1 = deal_volume;
            }           
            last_open_price_s1 = deal_price;
            last_volume_S1 = deal_volume;
            last_position_type_s1 = (deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_BUY:POSITION_TYPE_SELL;   
         }
         else if(deal_entry==DEAL_ENTRY_OUT){
            last_open_price_s1 = 0.0;
            last_volume_S1 = 0.0;                              //create last_volume_sell, last_volume_buy, last_open_price_sell etc.
            last_position_type_s1 = -1;
         }
      }
      if(deal_symbol==symbolArray[1] && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_BUY && deal_entry==DEAL_ENTRY_IN){
            totalBuyPrice_s1 += (last_volume_buy_s1*last_open_price_buy_s1);
            totalBuyLots_s1 += last_volume_buy_s1;
            breakEvenLineBuy_s1 = totalBuyPrice_s1/totalBuyLots_s1;
         }
         if(deal_type==DEAL_TYPE_SELL && deal_entry==DEAL_ENTRY_IN){
            totalSellPrice_s1 += (last_volume_sell_s1*last_open_price_sell_s1);
            totalSellLots_s1 += last_volume_sell_s1;
            breakEvenLineSell_s1 = totalSellPrice_s1/totalSellLots_s1;
         }         
      } 

//------------------------------------------------------------------
//-SYMBOL-2->>>>>>>>>  
//------------------------------------------------------------------     
      if(deal_symbol==symbolArray[2] && deal_magic==InpMagicNumber){
         if(deal_entry==DEAL_ENTRY_IN && (deal_type==DEAL_TYPE_BUY || DEAL_TYPE_SELL)){         
            if(deal_type==DEAL_TYPE_BUY){
               last_open_price_buy_s2 = deal_price;
               last_volume_buy_s2 = deal_volume;
            }
            if(deal_type==DEAL_TYPE_SELL){
               last_open_price_sell_s2 = deal_price;
               last_volume_sell_s2 = deal_volume;
            }           
            last_open_price_s2 = deal_price;
            last_volume_S2 = deal_volume;
            last_position_type_s2 = (deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_BUY:POSITION_TYPE_SELL;   
         }
         else if(deal_entry==DEAL_ENTRY_OUT){
            last_open_price_s2 = 0.0;
            last_volume_S2 = 0.0;                              //create last_volume_sell, last_volume_buy, last_open_price_sell etc.
            last_position_type_s2 = -1;
         }
      }
      if(deal_symbol==symbolArray[2] && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_BUY && deal_entry==DEAL_ENTRY_IN){
            totalBuyPrice_s2 += (last_volume_buy_s2*last_open_price_buy_s2);
            totalBuyLots_s2 += last_volume_buy_s2;
            breakEvenLineBuy_s2 = totalBuyPrice_s2/totalBuyLots_s2;
         }
         if(deal_type==DEAL_TYPE_SELL && deal_entry==DEAL_ENTRY_IN){
            totalSellPrice_s2 += (last_volume_sell_s2*last_open_price_sell_s2);
            totalSellLots_s2 += last_volume_sell_s2;
            breakEvenLineSell_s2 = totalSellPrice_s2/totalSellLots_s2;
         }         
      }

//---
      
      static double   todays_profit_loss;   
      datetime midnight;
      datetime now         = TimeCurrent(today);
      int      year        = today.year;
      int      month       = today.mon;
      int      day         = today.day;

      midnight = StringToTime(string(year)+"."+string(month)+"."+string(day)+" 00:00");
      HistorySelect(midnight,now);
      
      if(now == midnight+PeriodSeconds(PERIOD_D1)){
         todays_profit_loss = 0.0;
      }         
      if(deal_entry==DEAL_ENTRY_OUT && deal_time > midnight){
         todays_profit_loss += (deal_profit - deal_commission);
      }
 
      
               
   }   
}



//-close-grid-positions-function------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type, string s_symbol)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(positionInfo.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(positionInfo.Symbol()==s_symbol && positionInfo.Magic()==InpMagicNumber)
            if(positionInfo.PositionType()==pos_type) // gets the position type
               trade.PositionClose(positionInfo.Ticket()); // close a position by the specified symbol
   }
   
 
void DayProfit()
  {
   double dayprof = 0.0;
   datetime end = TimeCurrent();
   string sdate = TimeToString(TimeCurrent(), TIME_DATE);
   datetime start = StringToTime(sdate);

   HistorySelect(start,end);
   int TotalDeals = HistoryDealsTotal();

   for(int i = 0; i < TotalDeals; i++)
     {
      ulong Ticket = HistoryDealGetTicket(i);

      if(HistoryDealGetInteger(Ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
         double LatestProfit = HistoryDealGetDouble(Ticket, DEAL_PROFIT);
         dayprof += LatestProfit;
        }
     }
   Comment("Today's Profit & Loss: ",NormalizeDouble(dayprof,_Digits));
  }