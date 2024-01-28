//+------------------------------------------------------------------+
//|                                              MACD & Stoch EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"



//+------------------------------------------------------------------+
//| Uncludes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;

enum lotType{
   ENUM_PERC,     //%Risk
   ENUM_FIXEDlot  //Fixed Lot
};

enum tpType{
   ENUM_RR,       //Risk:Reward
   ENUM_FIXEDtp   //Fixed Take Profit   
};

enum slType{
   ENUM_CANDLE,   //Signal Candle
   ENUM_FIXEDsl   //Fixed Stop Loss   
};

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int         InpMagicNumber       =  102020;        //Magic Number
input lotType     InpLotType           =  ENUM_PERC;     //Lot Type
input double      InpRisk              =  1.0;           //Risk Percentage
input double      InpLotSize           =  0.01;          //Fixed Lot Size
input tpType      InptpType            =  ENUM_FIXEDtp;  //Take Profit Method
input int         InpTakeProfit        =  200;           //Take Profit (points)
input double      InpRR                =  2;             //Risk to Reward - 1:
input slType      InpslType            =  ENUM_FIXEDsl;  //Stop Loss Method
input int         InpStopLoss          =  100;           //Stop Loss (points)
input bool        InpCompound          =  false;         //Compound Trade Position



//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick     currentTick;
MqlDateTime today;

int         barsTotal;
double      SL, TP;
double      slSize, tpSize;
double      lotSize;
int         fMac_handle, sMac_handle, stoch_handle;
double      fMacBuffer[], sMacBuffer[], stochBuffer[];
double      barOneHigh, barOneLow;
double      barTwoHigh, barTwoLow;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

//---

   if(InpMagicNumber < 0){Alert("Invalid Magic Number, Must be > 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotSize < 0){Alert("Invalid Lot Size, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpRisk < 0){Alert("Invalid Risk Percentage, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpStopLoss < 0){Alert("Invalid Stop Loss, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpTakeProfit < 0){Alert("Invalid Take Profit, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   stoch_handle = iStochastic(_Symbol,PERIOD_CURRENT,7,3,3,MODE_SMA,STO_LOWHIGH);
   if(stoch_handle == INVALID_HANDLE){
      Print("Failed to create Stochastic indicator handle.");
      return INIT_FAILED;
   }
   
   fMac_handle = iMACD(_Symbol,PERIOD_CURRENT,3,8,9,PRICE_CLOSE);
   if(fMac_handle == INVALID_HANDLE){
      Print("Failed to create Fast MACD indicator handle.");
      return INIT_FAILED;
   }
   
   sMac_handle = iMACD(_Symbol,PERIOD_CURRENT,7,17,9,PRICE_CLOSE);
   if(sMac_handle == INVALID_HANDLE){
      Print("Failed to create Slow MACD indicator handle.");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(stochBuffer,true);
   ArraySetAsSeries(fMacBuffer,true);
   ArraySetAsSeries(sMacBuffer,true);

   return(INIT_SUCCEEDED);
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(stoch_handle != INVALID_HANDLE){
      IndicatorRelease(stoch_handle);
   }

   if(fMac_handle != INVALID_HANDLE){
      IndicatorRelease(fMac_handle);
   }
   
   if(sMac_handle != INVALID_HANDLE){
      IndicatorRelease(sMac_handle);
   }
   
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   if(!SymbolInfoTick(_Symbol,currentTick)){
      Print("Failed to get current tick..");
      return;
   }

//---

   CopyBuffer(stoch_handle,MAIN_LINE,0,2,stochBuffer);
   
   CopyBuffer(fMac_handle,MAIN_LINE,0,2,fMacBuffer);
   
   CopyBuffer(sMac_handle,MAIN_LINE,0,2,sMacBuffer);
   
   barOneHigh = iHigh(_Symbol,PERIOD_CURRENT,1);
   barOneLow = iLow(_Symbol,PERIOD_CURRENT,1);
   
   barTwoHigh = iHigh(_Symbol,PERIOD_CURRENT,2);
   barTwoLow = iLow(_Symbol,PERIOD_CURRENT,2);
   
//---

   //count open positions
   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
//---
   

   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars;
      

      //BUY-ENTRY---------+
      if(sMacBuffer[1] > 0 && fMacBuffer[1] < 0 && stochBuffer[1] < 20){
   
         //FIXED-SL-
         if(InpslType == ENUM_FIXEDsl){
            SL = currentTick.ask - InpStopLoss*_Point;
            slSize = InpStopLoss*_Point;
         
            //----------------------------+
         
            if(InptpType == ENUM_FIXEDtp){
               TP = currentTick.ask + InpTakeProfit*_Point;
            }
            else if(InptpType == ENUM_RR){
               tpSize = slSize*InpRR;
               TP = currentTick.ask + tpSize;
            }
         
            //----------------------------+

            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,slSize);
            }
            else{
               lotSize = InpLotSize;
            }
         
            //----------------------------+
                 
            if(cntBuy == 0){
               trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);
            }    
         }

         //CANDLE-SL-
         if(InpslType == ENUM_CANDLE){
            if(barOneLow < barTwoLow){
               SL = barOneLow;
               slSize = currentTick.ask - barOneLow;
            }
            else if(barTwoLow < barOneLow){
               SL = barTwoLow;
               slSize = currentTick.ask - barTwoLow;
            }
         
            //----------------------------+
         
            if(InptpType == ENUM_FIXEDtp){
               TP = currentTick.ask + InpTakeProfit*_Point;
            }
            
            if(InpTakeProfit == ENUM_RR){
               tpSize = slSize*InpRR;
               TP = currentTick.ask + tpSize;
            }

         
            //----------------------------+
         
            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,slSize);
            }
            else{
               lotSize = InpLotSize;
            }
         
            //----------------------------+
            
            if(cntBuy < 1){
               trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL); 
            }            
         }
      }
   
   
      //SELL-ENTRY---------+
      if(sMacBuffer[1] < 0 && fMacBuffer[1] > 0 && stochBuffer[1] > 80){
   
         //FIXED-SL-
         if(InpslType == ENUM_FIXEDsl){
            SL = currentTick.bid + InpStopLoss*_Point;
            slSize = InpStopLoss*_Point;
      
            //-------------------------+
      
            if(InptpType == ENUM_FIXEDtp){
               TP = currentTick.bid - InpTakeProfit*_Point;         
            }
            if(InptpType == ENUM_RR){
               tpSize = slSize*InpRR;
               TP = currentTick.bid - tpSize;
            }
      
            //-------------------------+
 
            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,slSize);
            }
            else{
               lotSize = InpLotSize;
            }
         
            //-------------------------+
            
            if(cntSell < 1){   
               trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
            }    
         }
      
         //CANDLE-SL-
         if(InpslType == ENUM_CANDLE){
            if(barOneHigh > barTwoHigh){
               SL = barOneHigh;
            }
            else if(barTwoHigh > barOneHigh){
               SL = barTwoHigh;
            }
         
            slSize = SL - currentTick.bid;
         
            //-------------------------+
         
            if(InptpType == ENUM_FIXEDtp){
               TP = currentTick.bid - InpTakeProfit*_Point;
            }
            else if(InptpType == ENUM_RR){
               tpSize = slSize*InpRR;
               TP = currentTick.bid - tpSize;
            }
         
            //-------------------------+
         
            if(InpLotType == ENUM_PERC){
               lotSize = calcLots(InpRisk,slSize);
            }
            else{
               lotSize = InpLotSize;
            }
         
            //-------------------------+
         
            if(cntSell < 1){
               trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
            }             
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
   
   double   lots           =  MathFloor(riskMoney / moneyLotStep) * lotStep;
     
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