//+------------------------------------------------------------------+
//|                                                RSI Liberator.mq5 |
//|                              Copyright 2023, Shogun Trading Ltd. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Shogun Trading Ltd."
#property link      "info.shoguntrading@gmail.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Includes and Enumerations                                                                  
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;
#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;
#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;

enum t_direction
  {
   ENUM_REGULAR,  //Regular
   ENUM_REVERSE,  //Reverse
   ENUM_DYNAMIC   //Dynamic
  };
enum newsDetect
  {
   ENUM_AUTO,     //Auto Detect
   ENUM_MANUAL    //Manual Input
  };  

//+------------------------------------------------------------------+
//| Input Variables                                                                  
//+------------------------------------------------------------------+

input int            InpMagicNumber          =     10001;         //Magic Number (Change If Opening on Multiple Charts)

input group          "TRADE SETTINGS"
input int            InpRSIPeriod            =     4;             //RSI period
input ENUM_APPLIED_PRICE InpRsiPrice         =     PRICE_CLOSE;   //RSI Applied Price
input int            InpRsiUpperLvl          =     70;            //RSI Upper Level
input t_direction    InpTradeDirection       =     ENUM_REVERSE;  //Trade Mode  
input double         InpStartLot             =     0.01;          //Starting Lot Size
input double         InpLotMultiplier        =     1.1;           //Lot Size Multiplier
input bool           InpAutoLot              =     false;         //Use Auto Lot
input int            InpAutoLotPer           =     1000;          //(Auto Lot) Starting Lot Per: $
input int            InpGridStep             =     20;            //Grid Step (pips)
input int            InpGridSkip             =     0;             //Skip First x Trades in the Grid
input int            InpTakeProfit           =     50;            //Take Profit (pips)
input int            InpStopLoss             =     20;            //Stop Loss (pips)
input double         InpMaxLot               =     5;             //Max Lot Size
input int            InpMaxPoS               =     20;            //Max Positions In One Direction
input bool           InpHedge                =     true;          //Open Hedge Positions
input int            InpDynamicPips          =     100;           //Dynamic Mode Pip Size     

input group          "ACCOUNT PROTECTION SETTINGS"          
input double         InpDDpercent            =     0.0;           //Max Equity Drawdown %   
input int            InpDDbalance            =     0;             //Max Balance Drawdown $ 
input int            InpTrailingStart        =     20;            //Trailing Stop Start (pips)
input int            InpTrailingStep         =     10;            //Trailing Stop Step (pips)
input int            InpProfitClose          =     0;             //Close all Positions once profit reached: $

input group          "TRADE FILTER SETTINGS"
input bool           InpTrendFilter          =     false;         //Use Trend Filter
input ENUM_TIMEFRAMES   InpTrendTF           =     PERIOD_D1;     //Trend Filter Time Frame
input int            InpStartHour            =     0;             //Trading Time Start Hour (24hr)
input int            InpStartMin             =     0;             //Trading Time Start Minutes
input int            InpStopHour             =     0;             //Trading Time Stop Hour (24hr)
input int            InpStopMin              =     0;             //Trading Time Stop Minutes
input bool           InpTradeMon             =     true;          //Trade on Monday
input bool           InpTradeTue             =     true;          //Trade on Tuesday   
input bool           InpTradeWed             =     true;          //Trade on Wednesday
input bool           InpTradeThu             =     true;          //Trade on Thursday
input bool           InpTradeFri             =     true;          //Trade on Friday

input group          "NEWS MODE SETTINGS"
input bool           InpNewsMode             =     false;         //News Mode (stop trading for high impact news events)
input newsDetect     InpNewsDetect           =     ENUM_AUTO;     //Method of News Detection
input int            InpBeforeNews           =     240;           //Stop Trading Minutes Before News
input int            InpAfterNews            =     60;            //Resume Trading Minutes After News
input string         InpNewsNameOne          =     "";            //News Event Name 1
input string         InpNewsNameTwo          =     "";            //News Event Name 2
input string         InpNewsNameThree        =     "";            //News Event Name 3  



//+------------------------------------------------------------------+
//|  Global Variables                                                                
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

int         barsTotal;
double      TP, SL, lotSize;

int         rsi_handle;
double      rsiBuffer[];

double      last_open_price      =  0.0;
double      last_volume          =  0.0;
int         last_position_type   =  -1;

double      last_volume_buy      =  0.0;
double      last_volume_sell     =  0.0;
double      last_open_price_buy  =  0.0;
double      last_open_price_sell =  0.0;

double      closeBuyPositions, closeSellPositions;
static double        nextBuyPrice;
static double        nextSellPrice;
static double        totalBuyPrice, totalSellPrice;
static double        totalBuyLots, totalSellLots;
static double        buyPrice, sellPrice;
static double        breakEvenLineBuy, breakEvenLineSell;
double      tpBuyLine, tpSellLine;

double   barOne_open, barOne_close;
int      rsi_lower;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   if(InpTakeProfit<=0){Alert("Take profit must be greater than 0...");return INIT_PARAMETERS_INCORRECT;}

   if(InpStartLot<=0){Alert("Start lot must be 0.01 or greater...");return INIT_PARAMETERS_INCORRECT;}
   if(InpRsiUpperLvl >= 100 || InpRsiUpperLvl <= 50){Alert("RSI Period must be between 50 - 100.");return INIT_PARAMETERS_INCORRECT;}
   
   rsi_handle = iRSI(_Symbol,PERIOD_CURRENT,InpRSIPeriod,InpRsiPrice);
   
   ArraySetAsSeries(rsiBuffer,true);

   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   if(rsi_handle != INVALID_HANDLE){IndicatorRelease(rsi_handle);}
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

   if(!SymbolInfoTick(_Symbol,currentTick)){Print("Failed to get current tick.");return;}

//---


int         beforeNews_seconds = InpBeforeNews*60;
int         afterNews_seconds  = InpAfterNews*60;
int         signal_points      =  InpDynamicPips*10; //15000
int         point_TP           =  InpTakeProfit*10;
int         point_SL           =  InpStopLoss*10;
int         point_Grid         =  InpGridStep*10;
int         point_TStart       =  InpTrailingStart*10;
int         point_TStep        =  InpTrailingStep*10;


//---

   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
//---

   rsi_lower = 100 - InpRsiUpperLvl;
   barOne_open = iOpen(_Symbol,PERIOD_CURRENT,1);
   barOne_close = iClose(_Symbol,PERIOD_CURRENT,1);
   CopyBuffer(rsi_handle,0,0,6,rsiBuffer);
    
   
   
   //SELL SIGNAL
   if(cntSell == 0){
      if(rsiBuffer[1] < rsiBuffer[2] && rsiBuffer[3] < rsiBuffer[2] && barOne_close < barOne_open && rsiBuffer[1] > InpRsiUpperLvl){  
         SL = currentTick.bid + point_SL*_Point;
         TP = currentTick.bid - point_TP*_Point;     
         trade.Sell(0.01,_Symbol,currentTick.bid,SL,TP,NULL);  
      }
      if(rsiBuffer[2] < rsiBuffer[3] && rsiBuffer[4] < rsiBuffer[3] && barOne_close < barOne_open && rsiBuffer[2] > InpRsiUpperLvl){
         SL = currentTick.bid + point_SL*_Point;
         TP = currentTick.bid - point_TP*_Point;    
         trade.Sell(0.01,_Symbol,currentTick.bid,SL,TP,NULL);    
      }
   }
   

   //BUY SIGNAL
   if(cntBuy == 0){
      if(rsiBuffer[1] > rsiBuffer[2] && rsiBuffer[3] > rsiBuffer[2] && barOne_close > barOne_open && rsiBuffer[1] < rsi_lower){
         SL = currentTick.ask - point_SL*_Point;
         TP = currentTick.ask + point_TP*_Point;      
         trade.Buy(0.01,_Symbol,currentTick.ask,SL,TP,NULL);  
      }   
      if(rsiBuffer[2] > rsiBuffer[3] && rsiBuffer[4] > rsiBuffer[3] && barOne_close > barOne_open && rsiBuffer[2] < rsi_lower){
         SL = currentTick.ask - point_SL*_Point;
         TP = currentTick.ask + point_TP*_Point;      
         trade.Buy(0.01,_Symbol,currentTick.ask,SL,TP,NULL);        
      }    
   }   
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

//===COUNT OPEN POSITIONS==================================================================================================//
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