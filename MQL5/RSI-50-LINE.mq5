//+------------------------------------------------------------------+
//|                                                  RSI-50-LINE.mq5 |
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
CTrade accounInfo;

enum LotType{
   ENUM_PERC,     //%Risk
   ENUM_FIXED     //Fixed Lot   
};

//+------------------------------------------------------------------+
//| Input Variables                                                  |
//+------------------------------------------------------------------+
input int         InpMagicNumber          =  00991;      //Magic Number
input LotType     InpLotType              =  ENUM_PERC;  //Lot Type
input double      InpRisk                 =  1.00;       //Risk Percentage
input double      InpLotSize              =  0.01;       //Fixed Lot Size 
input int         InpStopLoss             =  200;        //Stop Loss
input int         InpTakeProfit           =  500;        //Take Profit 
    


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick  currentTick;
int      rsi_handle;
double   rsiBuffer[];
double   barOneClose;
int      barsTotal;
double   SL, TP;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   rsi_handle = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);
   if(rsi_handle==INVALID_HANDLE){Print("Failed to create indicator handle.");return INIT_FAILED;}
   
   ArraySetAsSeries(rsiBuffer,true);
   

   return(INIT_SUCCEEDED);
}




//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(rsi_handle != INVALID_HANDLE){
      IndicatorRelease(rsi_handle);      
   }
   
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   if(!SymbolInfoTick(_Symbol,currentTick)){
      Print("Failed to get current tick.");
      return;
   }
   
//---

   CopyBuffer(rsi_handle,0,0,3,rsiBuffer);
   barOneClose = iClose(_Symbol,PERIOD_CURRENT,1);
   
//---

   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars;
      
      
      //BUYS
      if(rsiBuffer[2] < 50 && rsiBuffer[1] > 50){
         SL = currentTick.bid - InpStopLoss*_Point;
         TP = currentTick.bid + InpTakeProfit*_Point;
         trade.Buy(0.1,_Symbol,barOneClose,SL,TP,NULL);
      }
      
      //SELLS
      if(rsiBuffer[2] > 50 && rsiBuffer[1] < 50){
         SL = currentTick.ask + InpStopLoss*_Point;
         TP = currentTick.ask - InpTakeProfit*_Point;
         trade.Sell(0.1,_Symbol,barOneClose,SL,TP,NULL);
      }
   }
   
   closeTradeSignal();          
}




//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

bool closeTradeSignal(){
   
   int total = PositionsTotal();  
   for(int i = total-1; 1>=0; i--){  
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
      long type;
      if(!PositionGetInteger(POSITION_TYPE,type)){
         Print("Failed to get position type.");
         return false;
      }
      
      if(type==POSITION_TYPE_BUY && rsiBuffer[2]>50 && rsiBuffer[1]<50){
         trade.PositionClose(ticket,0);
      }        
      
      if(type==POSITION_TYPE_SELL && rsiBuffer[2]<50 && rsiBuffer[1]>50){
         trade.PositionClose(ticket,0);
      }        
   }
   return true;
}