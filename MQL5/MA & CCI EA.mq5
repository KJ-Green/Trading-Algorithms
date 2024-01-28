//+------------------------------------------------------------------+
//|                                                  MA & CCI EA.mq5 |
//|                              Copyright 2023, Shogun Trading Ltd. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Shogun Trading Ltd."
#property link      "info.shoguntrading@gmail.com"
#property version   "1.00"



//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;

enum lotType{
   ENUM_PERC,  //%Risk
   ENUM_FIXED  //Fixed Lot
};



//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int      InpMagicNumber       =  445873;     //Magic Number
input lotType  InpLotType           =  ENUM_PERC;  //Lot Type
input double   InpRisk              =  1.00;       //Risk Percentage
input double   InpLotSize           =  0.01;       //Fixed Lot Size
input int      InpTakeProfit        =  400;        //Take Profit (points)
input int      InpStopLoss          =  200;        //Stop Loss (points)
input int      InpBreakeven         =  200;        //Break Even (points)




//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick currentTick;
int barsTotal;

int fMA_Handle;
int sMA_Handle;
int CCI_Handle;

double fastMABuffer[];
double slowMABuffer[];
double CCIBuffer[];

double buyTP, buySL, sellSL, sellTP;
double barOneHigh, barOneLow, barOneClose;
double barTwoHigh, barTwoLow, barTwoClose;

double   percentSL      =  InpStopLoss * _Point;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){


   if(InpMagicNumber < 1){Alert("Invalid Input, Magic Number must be greater than 0...");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpBreakeven < 0){Alert("Invalid Input, Break Even cannot be less than 0...");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotSize < 0){Alert("Invalid Input, Lot Size cannot be less than 0.01");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpRisk < 0){Alert("Invalid Input, Risk Percentage must be greater than 0...");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpStopLoss < 0){Alert("Invalid Input, Stop Loss cannot be less than 0..");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpTakeProfit < 0){Alert("Invalid Input, Take Profit cannot be less than 0..");return INIT_PARAMETERS_INCORRECT;}   
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   fMA_Handle = iMA(_Symbol,PERIOD_CURRENT,49,0,MODE_EMA,PRICE_CLOSE);
   if(fMA_Handle == INVALID_HANDLE){
      Print("Failed to create Fast EMA indicator handle.");
      return INIT_FAILED;
   }
   
   sMA_Handle = iMA(_Symbol,PERIOD_CURRENT,100,0,MODE_EMA,PRICE_CLOSE);
   if(sMA_Handle == INVALID_HANDLE){
      Print("Failed to create Slow EMA indicator handle.");
      return INIT_FAILED;
   }
   
   CCI_Handle = iCCI(_Symbol,PERIOD_CURRENT,14,PRICE_TYPICAL);
   if(CCI_Handle == INVALID_HANDLE){
      Print("Failed to create CCI indicator handle.");
      return INIT_FAILED;
   }
   
   
   ArraySetAsSeries(fastMABuffer,true);
   ArraySetAsSeries(slowMABuffer,true);
   ArraySetAsSeries(CCIBuffer,true);

   return(INIT_SUCCEEDED);
}
  
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(fMA_Handle != INVALID_HANDLE){
      IndicatorRelease(fMA_Handle);
   }
   
   if(sMA_Handle != INVALID_HANDLE){
      IndicatorRelease(sMA_Handle);
   }
   
   if(CCI_Handle != INVALID_HANDLE){
      IndicatorRelease(CCI_Handle);
   }
   
}





//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   if(!SymbolInfoTick(_Symbol,currentTick)){
   Alert("Failed to get current tick..");
      return;
   }
   
//---

   barOneHigh = iHigh(_Symbol,PERIOD_CURRENT,1);
   barOneLow = iLow(_Symbol,PERIOD_CURRENT,1);
   barOneClose = iClose(_Symbol,PERIOD_CURRENT,1);
   
   barTwoHigh = iHigh(_Symbol,PERIOD_CURRENT,2);
   barTwoLow = iLow(_Symbol,PERIOD_CURRENT,2);
   barTwoClose = iClose(_Symbol,PERIOD_CURRENT,2);
   
   CopyBuffer(fMA_Handle,0,0,3,fastMABuffer);
   CopyBuffer(sMA_Handle,0,0,3,slowMABuffer);
   CopyBuffer(CCI_Handle,0,0,3,CCIBuffer);   
         
//---

   sellSL = currentTick.bid + InpStopLoss*_Point;
   sellTP = currentTick.bid - InpTakeProfit*_Point;
   buySL = currentTick.ask - InpStopLoss*_Point;
   buyTP = currentTick.ask + InpTakeProfit*_Point; 
   
   
   //setting value of lots depending on fixed or risk        
   double lots;
   if(InpLotType == ENUM_PERC){
      lots = calcLots(InpRisk,percentSL);
   }
   else{
      lots = InpLotSize;
   }      

//---

   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
   checkBreakEvenBuy(currentTick.ask);
   checkBreakEvenSell(currentTick.bid);     
   
//---


   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars;
   
   
      //buy
      if(barTwoClose < fastMABuffer[2] && barOneClose > fastMABuffer[1] && barOneHigh > slowMABuffer[1] && CCIBuffer[1] > 100.00){
         trade.Buy(lots,_Symbol,currentTick.ask,buySL,buyTP,NULL);
      }
      
      //Sell
      if(barTwoClose > fastMABuffer[2] && barOneClose < fastMABuffer[1] && barOneLow < slowMABuffer[1] && CCIBuffer[1] < -100.00){
         trade.Sell(lots,_Symbol,currentTick.bid,sellSL,sellTP,NULL);
      }              
   }   
   
}




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
   double      moneyLotStep   =  (percentSL / tickSize) * tickValue * lotStep;
   
   if(moneyLotStep == 0){
      Print(__FUNCTION__,"> Lotsize cannot be calculated..");
      return 0;
   }
   
   double      lots           =  MathFloor(riskMoney / moneyLotStep) * lotStep;
     
   return lots;
}




//Count Open Positions 
bool CountOpenPositions(int &cntBuy, int &cntSell){
   
   cntBuy   = 0;
   cntSell  = 0;
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
         if(type == POSITION_TYPE_BUY){cntBuy++;}
         if(type == POSITION_TYPE_SELL){cntSell++;}
      }
   }
   
   return true;
}




//---Breakeven-BUY-function---------------------------+

void checkBreakEvenBuy(double ask){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      long posType = PositionGetInteger(POSITION_TYPE); 
      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL > openPrice - InpStopLoss*_Point){
         return;
      }
      
      else if(_Symbol==symbol && posType==POSITION_TYPE_BUY){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double BEbuyTP = InpTakeProfit == 0 ? 0 : openPrice + InpTakeProfit * _Point;
         if(ask > (openPrice + InpBreakeven * _Point)){
            trade.PositionModify(positionTicket,openPrice,BEbuyTP);   
         }
      }
   }
}




//---Breakeven-SELL-function------------------------------+

void checkBreakEvenSell(double bid){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      long posType = PositionGetInteger(POSITION_TYPE);
      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL < openPrice + InpStopLoss*_Point){
         return;
      }
      
      else if(_Symbol==symbol && posType==POSITION_TYPE_SELL){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double BEsellTP = InpTakeProfit == 0 ? 0 : openPrice - InpTakeProfit * _Point;
         if(bid < (openPrice - InpBreakeven * _Point)){
            trade.PositionModify(positionTicket,openPrice,BEsellTP);   
         }
      }
   }
}