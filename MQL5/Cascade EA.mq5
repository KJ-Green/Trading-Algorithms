//+------------------------------------------------------------------+
//|                                                   Cascade EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;
#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;
#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;


enum LotType{
   ENUM_PERC,     //%Risk
   ENUM_FIXED,    //Fixed Lot
   ENUM_AUTO      //Auto Lot   
};


//+------------------------------------------------------------------+
//| Input Variables                                       
//+------------------------------------------------------------------+
input int         InpMagicNumber       =  001002;      //Magic Number
input LotType     InpLotType           =  ENUM_PERC;   //Lot Type
input double      InpFixedLot          =  0.01;        //Fixed Lot Size
input double      InpRiskPerc          =  1;           //Risk Percentage
input double      InpAutoLot           =  1000;        //Auto Lot - Fixed lot per x balance 
input int         InpStopLoss          =  10;          //Stop Loss (pips)
input int         InpGrid              =  20;          //Grid Size (pips)
input int         InpTakeProfit        =  5;           //Take Profit From Grid (pips)
input int         InpRsiPeriod         =  7;           //RSI Period
input int         InpRsiLevels         =  70;          //RSI Upper Level (Mirrored at Lower Level)
input bool        InpRsiInvert         =  false;       //Invert RSI Entry 


//+------------------------------------------------------------------+
//| Global Variables                                       
//+------------------------------------------------------------------+
MqlTick currentTick;

int      rsiHandle;
double   rsiBuffer[];
double   SL, TP, grid_buyLevel, grid_sellLevel, buy_tpLevel, sell_tpLevel;
double   sl_size, sl_points, grid_points, tp_points;
int      barsTotal, rsi_upper, rsi_lower;
double   lotSize;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   trade.SetExpertMagicNumber(InpMagicNumber);
      
   rsiHandle = iRSI(_Symbol,PERIOD_CURRENT,InpRsiPeriod,PRICE_CLOSE);

   ArraySetAsSeries(rsiBuffer,true);
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   return(INIT_SUCCEEDED);
}



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(rsiHandle!=INVALID_HANDLE){IndicatorRelease(rsiHandle);}
   
}



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   if(!SymbolInfoTick(_Symbol,currentTick)){Alert("Failed to get current tick.");}

//---

   CopyBuffer(rsiHandle,0,0,3,rsiBuffer);

   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
   rsi_upper = InpRsiLevels;
   rsi_lower = (-InpRsiLevels)+100;
   
   sl_points = InpStopLoss*10*_Point;
   grid_points = InpGrid*10*_Point;
   tp_points = InpTakeProfit*10*_Point;
   
   double ask = NormalizeDouble(currentTick.ask,_Digits);
   double bid = NormalizeDouble(currentTick.bid,_Digits);   

//---
   
   //BUYS
   if(cntBuy==0 && rsiBuffer[1]<=rsi_upper && rsiBuffer[0]>rsi_upper && InpRsiInvert==false){
      
      SL = ask - sl_points;
      sl_size = ask - SL;
      grid_buyLevel = ask + grid_points;
      
      if(InpLotType==ENUM_FIXED){lotSize=InpFixedLot;}     
      if(InpLotType==ENUM_PERC){lotSize = NormalizeDouble(calcLots(InpRiskPerc,sl_size),2);}     
      if(InpLotType==ENUM_AUTO){lotSize = NormalizeDouble(((accountInfo.Balance() / InpAutoLot) * InpFixedLot),2);}   
      trade.Buy(lotSize,_Symbol,ask,SL,0,NULL);
   }
   if(cntSell==0 && rsiBuffer[1]<=rsi_upper && rsiBuffer[0]>rsi_upper && InpRsiInvert==true){
      
      SL = bid + sl_points;
      sl_size = SL - bid;
      grid_sellLevel = bid - grid_points;
      
      if(InpLotType==ENUM_FIXED){lotSize=InpFixedLot;}     
      if(InpLotType==ENUM_PERC){lotSize = NormalizeDouble(calcLots(InpRiskPerc,sl_size),2);}     
      if(InpLotType==ENUM_AUTO){lotSize = NormalizeDouble(((accountInfo.Balance() / InpAutoLot) * InpFixedLot),2);}   
      trade.Sell(lotSize,_Symbol,ask,SL,0,NULL);
   }
   
   //SELLS
   if(cntSell==0 && rsiBuffer[1]>=rsi_lower && rsiBuffer[0]<rsi_lower && InpRsiInvert==false){

      SL = bid + sl_points;
      sl_size = SL - bid;
      grid_sellLevel = bid - grid_points;
      
      if(InpLotType==ENUM_FIXED){lotSize=InpFixedLot;}     
      if(InpLotType==ENUM_PERC){lotSize = NormalizeDouble(calcLots(InpRiskPerc,sl_size),2);}     
      if(InpLotType==ENUM_AUTO){lotSize = NormalizeDouble(((accountInfo.Balance() / InpAutoLot) * InpFixedLot),2);}   
      trade.Sell(lotSize,_Symbol,ask,SL,0,NULL);   
   }   
   if(cntBuy==0 && rsiBuffer[1]>=rsi_lower && rsiBuffer[0]<rsi_lower && InpRsiInvert==true){
      SL = ask - sl_points;
      sl_size = ask - SL;
      grid_buyLevel = ask + grid_points;
      
      if(InpLotType==ENUM_FIXED){lotSize=InpFixedLot;}     
      if(InpLotType==ENUM_PERC){lotSize = NormalizeDouble(calcLots(InpRiskPerc,sl_size),2);}     
      if(InpLotType==ENUM_AUTO){lotSize = NormalizeDouble(((accountInfo.Balance() / InpAutoLot) * InpFixedLot),2);}   
      trade.Buy(lotSize,_Symbol,ask,SL,0,NULL);   
   } 
   

////// Opening New Positions In The Grid /////////////////////////////////////////////////////////////////////////////////////////

   if(cntBuy>0 && ask>=grid_buyLevel){
      trade.Buy(lotSize,_Symbol,ask,0,0,NULL);
      grid_buyLevel = ask + grid_points;
      buy_tpLevel = ask - tp_points;
   }   
      
   if(cntSell>0 && bid<=grid_sellLevel){
      trade.Sell(lotSize,_Symbol,bid,0,0,NULL);
      grid_sellLevel = bid - grid_points;
      sell_tpLevel = bid + tp_points;
   }   


////// Closeing Positions Take Profit ///////////////////////////////////////////////////////////////////////////////////////////

   if(cntBuy>1 && ask<=buy_tpLevel){ClosePositions(POSITION_TYPE_BUY);}
   
   if(cntSell>1 && bid>=sell_tpLevel){ClosePositions(POSITION_TYPE_SELL);}
  
}



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


//Calulate Lot Size for Percentage based risk
double calcLots(double riskPercent, double slDistance){

   double      tickSize       =  SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double      tickValue      =  SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double      lotStep        =  SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(tickSize == 0 || tickValue == 0 || lotStep == 0){
      Print(__FUNCTION__,"> Lotsize tick cannot be calculated..");
      return 0;
   }
   
   double      riskMoney      =  AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100;
   double      moneyLotStep   =  (slDistance / tickSize) * tickValue * lotStep;
   
   if(moneyLotStep == 0){
      Print(__FUNCTION__,"> Lotsize cannot be calculated..");
      return 0;
   }
   
   double   lots           =  MathFloor(riskMoney / moneyLotStep) * lotStep;
     
   return lots;
}


//===CLOSE POSITIONS BY TYPE FUNCTION=======================================================================================================//

void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(positionInfo.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(positionInfo.Symbol()==_Symbol && positionInfo.Magic()==InpMagicNumber)
            if(positionInfo.PositionType()==pos_type) // gets the position type
               trade.PositionClose(positionInfo.Ticket()); // close a position by the specified symbol
   }