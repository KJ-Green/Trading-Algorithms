//+------------------------------------------------------------------+
//|                                           Fractal MA Scalper.mq5 |
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
input int      InpMagicNumber       =  333043;     //Magic Number
input lotType  InpLotType           =  ENUM_PERC;  //Lot Type
input double   InpRisk              =  1.00;       //Risk Percentage
input double   InpLotSize           =  0.01;       //Fixed Lot Size



//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick     currentTick;
double      lotSize;
double      SL, TP, SLsize, TPsize;
double      barThreeHigh, barThreeLow, barThreeClose;
double      barOneClose;
int         emaF_handle, emaM_handle, emaS_handle, fra_handle;
double      emaFBuffer[];
double      emaMBuffer[];
double      emaSBuffer[];
double      fracUpper[];
double      fracLower[];
int         barsTotal;

double      stopLoss, takeProfit, percentSL;






//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   if(InpMagicNumber < 1){Alert("Invalid input, Magic number must be greater than 0..");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotType == ENUM_FIXED && InpLotSize < 0.01){Alert("Invalid input, Lot size must be greater than 0..");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotType == ENUM_PERC && InpRisk < 0.01){Alert("Invalid input, Risk percentage must be greater than 0..");return INIT_PARAMETERS_INCORRECT;}
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   emaF_handle = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_EMA,PRICE_CLOSE);
   if(emaF_handle == INVALID_HANDLE){
      Print("Failed to create fast EMA indicator handle.");
      return INIT_FAILED;
   }
   
   emaM_handle = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
   if(emaM_handle == INVALID_HANDLE){
      Print("Failed to create Medium EMA indicator handle.");
      return INIT_FAILED;
   }
   
   emaS_handle = iMA(_Symbol,PERIOD_CURRENT,100,0,MODE_EMA,PRICE_CLOSE);
   if(emaS_handle == INVALID_HANDLE){
      Print("Failed to create Slow EMA indicator handle.");
      return INIT_FAILED;
   }
   
   fra_handle = iFractals(_Symbol,PERIOD_CURRENT);
   if(fra_handle == INVALID_HANDLE){
      Print("Failed to create Fractals indicator handle.");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(emaFBuffer,true);
   ArraySetAsSeries(emaMBuffer,true);
   ArraySetAsSeries(emaSBuffer,true);
   ArraySetAsSeries(fracUpper,true);
   ArraySetAsSeries(fracLower,true);
   
   return(INIT_SUCCEEDED);
}
  
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(emaF_handle != INVALID_HANDLE){
      IndicatorRelease(emaF_handle);
   }
   
   if(emaM_handle != INVALID_HANDLE){
      IndicatorRelease(emaM_handle);
   }
   
   if(emaS_handle != INVALID_HANDLE){
      IndicatorRelease(emaS_handle);
   }
   
   if(fra_handle != INVALID_HANDLE){
      IndicatorRelease(fra_handle);
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

   barThreeHigh = iHigh(_Symbol,PERIOD_CURRENT,3);
   barThreeLow = iLow(_Symbol,PERIOD_CURRENT,3);
   barThreeClose = iClose(_Symbol,PERIOD_CURRENT,3);
   barOneClose = iClose(_Symbol,PERIOD_CURRENT,1);
   
   CopyBuffer(emaF_handle,0,0,4,emaFBuffer);
   CopyBuffer(emaM_handle,0,0,4,emaMBuffer);
   CopyBuffer(emaS_handle,0,0,4,emaSBuffer);
   CopyBuffer(fra_handle,UPPER_LINE,3,1,fracUpper);
   CopyBuffer(fra_handle,LOWER_LINE,3,1,fracLower);
   
   //Comment("bar3High: ",barThreeHigh,"\nbar3close: ",barThreeClose,"\nbar3Low: ",barThreeLow,
   //        "\nbar1close: ",barOneClose,"\nEMAf[2]: ",emaFBuffer[3],"\nEMAm[2]: ",emaMBuffer[3],
   //        "\nEMAs[2]: ",emaSBuffer[3],"\nUfrac: ",fracUpper[2],"\nLfrac: ",fracLower[2]); 

//---


   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars;
      
//---
      
      bool isSell = false;
      bool isBuy = false;
      
      if(fracUpper[0] != EMPTY_VALUE){
         Print("Sell Signal..");
         isSell = true;
      }
      if(fracLower[0] != EMPTY_VALUE){
         Print("Buy Signal..");
         isBuy = true;
      }
      
//---
            
      if(emaFBuffer[3] < emaMBuffer[3] && emaMBuffer[3] < emaSBuffer[3]){
      
         if(isSell && barThreeHigh > emaFBuffer[3] && barThreeHigh < emaMBuffer[3]){
         
            SL       = emaMBuffer[3];
            SLsize   = SL - barOneClose;
            TPsize   = SLsize*1.5;
            TP       = barOneClose - TPsize;
            
            //---           
            
            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,SL);
            }
            else{
               lotSize = InpLotSize;
            }
            
            //---
            
            trade.Sell(lotSize,_Symbol,barOneClose,SL,TP,NULL);                              
         }         
         
         if(isSell && barThreeHigh > emaMBuffer[3] && barThreeHigh < emaSBuffer[3]){
            
            SL       = emaSBuffer[3];
            SLsize   = SL - barOneClose;
            TPsize   = SLsize*1.5;
            TP       = barOneClose - TPsize;
            
            //---
            
            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,SL);
            }
            else{
               lotSize = InpLotSize;
            }
            
            //---
            
            trade.Sell(lotSize,_Symbol,barOneClose,SL,TP,NULL);            
         }      
      }
      
      
      if(emaFBuffer[3] > emaMBuffer[3] && emaMBuffer[3] > emaSBuffer[3]){
      
         if(isBuy && barThreeLow < emaFBuffer[3] && barThreeLow > emaMBuffer[3]){
            
            SL       = emaMBuffer[3];
            SLsize   = barOneClose - SL;
            TPsize   = SLsize*1.5;
            TP       = barOneClose + TPsize;
            
            //---

            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,SL);
            }
            else{
               lotSize = InpLotSize;
            }
            
            //---
            
            trade.Buy(lotSize,_Symbol,barOneClose,SL,TP,NULL);                        
         }
         
         if(isBuy && barThreeLow < emaMBuffer[3] && barThreeLow > emaSBuffer[3]){
         
            SL       = emaSBuffer[3];
            SLsize   = barOneClose - SL;
            TPsize   = SLsize*1.5;
            TP       = barOneClose + TPsize;
            
            //---

            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,SL);
            }
            else{
               lotSize = InpLotSize;
            }
            
            //---
            
            trade.Buy(lotSize,_Symbol,barOneClose,SL,TP,NULL);            
         }
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
   double      moneyLotStep   =  (slDistance / tickSize) * tickValue * lotStep;
   
   if(moneyLotStep == 0){
      Print(__FUNCTION__,"> Lotsize cannot be calculated..");
      return 0;
   }
   
   double      lots           =  MathFloor(riskMoney / moneyLotStep) * lotStep;
     
   return lots;
}
