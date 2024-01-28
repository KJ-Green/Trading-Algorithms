//+------------------------------------------------------------------+
//|                                                   FVG expert.mq5 |
//|                              Copyright 2023, Shogun Trading Ltd. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Shogun Trading Ltd."
#property link      "info.shoguntrading@gmail.com"
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
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;

enum lotType{
   ENUM_FIXED, //Fixed Lot
   ENUM_PERC   //%Risk
};

enum EntryMethod{
   ENUM_ORD,   //Limit Orders
   ENUM_PA     //Price Action
};


//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

input int               InpMagicNumber    =  458890;     //Magic Number
input int               InpFVGmin         =  100;        //Fair Vaule Gap minimum points
input EntryMethod       InpEntryM         =  ENUM_ORD;   //Entry Method
input bool              InpMACD           =  true;       //Use MACD
input int               InpHighest        =  30;         //Bars Analysed for Take Profit
input lotType           InpLotType        =  ENUM_PERC;  //Lot Type
input double            InpRisk           =  1.00;       //Risk Percentage
input double            InpLotSize        =  0.01;       //Fixed Lot Size        
input double            InpRR             =  2;          //Risk to Reward - 1:
input int               InpStopLoss       =  200;        //Fixed Stop Loss (Points)
input int               InpTakeProfit     =  200;        //Fixed Take Profit (Points)
input ENUM_TIMEFRAMES   InpTF             =  PERIOD_H1;  //FVG Time Frame
input int               InpLossTrades     =  2;          //Pause Trading After x Losing Trades
input int               InpPauseDays      =  2;          //Pause Trading for x Days After Losing Trades

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick  currentTick;
MqlDateTime dateTime;

//Bar data for detecting FVG
double   highestClose;
double   barOneHigh, barOneLow;
double   barTwoHigh, barTwoLow;
double   barThreeHigh, barThreeLow;
double   barFourHigh, barFourLow;

//Bar data for 5M timeframe to detect entry
double   FmBarOneLow, FmBarOneHigh;
double   FmBarTwoHigh, FmBarTwoLow;
double   FmBarThreeHigh, FmBarThreeLow;

double   fvgHighBuy, fvgLowBuy, fvgMidBuy;
double   fvgHighSell, fvgLowSell, fvgMidSell;
double   fvgSize;
datetime fvgStart;
datetime fvgEnd = TimeCurrent()+72000;
datetime currentTime, limitExpire, objectStart, objectExpire, orderTime;
int      barsTotal;
int      totalObjects;
double   objectDeletePrice;
double   SL, TP;
double   SLsize, TPsize;
double   lotSize;
double   fvgPrice;
double   pa_Threshold;
int      macd_handle;
double   macdML_Buffer[], macdSL_Buffer[];






//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   ChartBackColorSet(clrSnow,0);
   ChartForeColorSet(clrBlack,0);
   ChartGridColorSet(clrLavender,0);
   ChartUpColorSet(clrBlack,0);
   ChartDownColorSet(clrBlack,0);
   ChartBullColorSet(clrSilver,0);
   ChartBearColorSet(clrBlack,0);
   
   macd_handle = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE);
   if(macd_handle == INVALID_HANDLE){
      Print("Failed to create indicator handle.");
      return INVALID_HANDLE;
   }
   
   ArraySetAsSeries(macdML_Buffer,true);
   ArraySetAsSeries(macdSL_Buffer,true);
      
   return(INIT_SUCCEEDED);
}




//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(macd_handle != INVALID_HANDLE){
      IndicatorRelease(macd_handle);
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

   barOneHigh = iHigh(_Symbol,PERIOD_CURRENT,1);
   barOneLow = iLow(_Symbol,PERIOD_CURRENT,1);
   
   barTwoHigh = iHigh(_Symbol,PERIOD_CURRENT,2);
   barTwoLow = iLow(_Symbol,PERIOD_CURRENT,2);
   
   barThreeHigh = iHigh(_Symbol,PERIOD_CURRENT,3);
   barThreeLow = iLow(_Symbol,PERIOD_CURRENT,3);
   
   barFourHigh = iHigh(_Symbol,PERIOD_CURRENT,4);
   barFourLow = iLow(_Symbol,PERIOD_CURRENT,4);
   
   highestClose = iHighest(_Symbol,PERIOD_CURRENT,MODE_CLOSE,InpHighest,0); 
   
   FmBarOneHigh = iHigh(_Symbol,PERIOD_M1,1);
   FmBarOneLow = iLow(_Symbol,PERIOD_M1,1);
   
   FmBarTwoHigh = iHigh(_Symbol,PERIOD_M1,2);
   FmBarTwoLow = iLow(_Symbol,PERIOD_M1,2);
   
   FmBarThreeHigh = iHigh(_Symbol,PERIOD_M1,3);
   FmBarThreeLow = iLow(_Symbol,PERIOD_M1,3);
   
   fvgStart = iTime(_Symbol,PERIOD_CURRENT,2);
   
   CopyBuffer(macd_handle,MAIN_LINE,0,4,macdML_Buffer);
   CopyBuffer(macd_handle,SIGNAL_LINE,0,4,macdSL_Buffer);
   
   
//---

   fvgSize = InpFVGmin*_Point;
   
   fvgHighBuy = barOneLow;
   fvgLowBuy = barThreeHigh;
   fvgMidBuy = fvgHighBuy - fvgLowBuy;
   
   fvgHighSell = barThreeLow;
   fvgLowSell = barOneHigh;
   fvgMidSell = fvgHighSell - fvgLowSell;

   currentTime = iTime(_Symbol,0,0);
   limitExpire = currentTime + 86400;
   
   totalObjects = ObjectsTotal(0,0,OBJ_RECTANGLE);
   //Comment("FVG's Detected: ",totalObjects);
         
   
//---

   //count open positions
   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
   //Checking for Consecutive Losses  
   datetime now         =  TimeCurrent(dateTime); //Current time right now
   datetime lookBack    =  now - 60*60*24*5; //Checking deal history of previous 5 days
   datetime resume      =  now + 60*60*24*InpPauseDays; //Time in future to resume trading if pause is executed
   
   int      total       =  HistoryDealsTotal();
   int      dealLoss    = 0;
   double   totalProfit = 0;
   datetime lastDeal_Resume = 0;
   HistorySelect(lookBack,now);
   
   for(int i = total-1; i>=0; i--){
   
      ulong    deal_ticket = HistoryDealGetTicket(i);
      datetime deal_time   = (datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);      
      long     deal_entry  = HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
      long     deal_magic  = HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
      double   deal_profit = HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);
      string   deal_symbol = HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
      long     deal_reason = HistoryDealGetInteger(deal_ticket,DEAL_REASON);
      
      if(deal_time > lookBack && deal_reason == DEAL_REASON_SL){
         dealLoss ++;     
         totalProfit += deal_profit;            
      }
      
      if(deal_time > lookBack && deal_reason == DEAL_REASON_TP){
         dealLoss = 0;
         totalProfit += deal_profit;
      }
      
      if(dealLoss >= InpLossTrades){
         //dealLoss = 0;
         lastDeal_Resume = deal_time + 60*60*24*InpPauseDays;
         
         if(now < lastDeal_Resume){
            return;
         }
         else if(now >= lastDeal_Resume){
         dealLoss = 0;
         }
      }
   }     

//---


   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars;


      //Checking-for-SELL-opportunities----------------------------------------+
      
      if(barOneHigh < barThreeLow-fvgSize){
         if(barFourLow < barThreeLow && barFourLow > barOneHigh+fvgSize){
            if(totalObjects < 1){
               ObjectCreate(0,"fvgSell",OBJ_RECTANGLE,0,fvgStart,barFourLow,fvgEnd,barOneHigh);
               ObjectSetInteger(0,"fvgSell",OBJPROP_COLOR,clrPaleGreen);
               ObjectSetInteger(0,"fvgSell",OBJPROP_FILL,true);

               //Instantly set limit order on creation of FVG
               if(InpEntryM == ENUM_ORD){            
                  SL = barThreeHigh;
                  SLsize = barThreeHigh - fvgLowSell;
                  TPsize = SLsize*InpRR;
                  TP = fvgLowSell - TPsize;
                  
                  //if fvg bar2 is long candle, SL at high of bar2
                  if(barTwoHigh-barTwoLow >= 1000*_Point){
                     SL = barTwoHigh;
                  }
            
                  if(InpLotType == ENUM_PERC){
                     lotSize = calcLots(InpRisk,SLsize);
                  }
                  else{
                     lotSize = InpLotSize;
                  }           
                  
               //Pausing Trade Function After Losses     
                  if(dealLoss >= InpLossTrades && now < lastDeal_Resume){
                     return;
                  }
                  
               //Normal Trade Function
                  else{    
                     if(InpMACD == true && macdML_Buffer[3] >= 0){      
                        trade.SellLimit(lotSize,fvgLowSell,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                     if(InpMACD == false){
                        trade.SellLimit(lotSize,fvgLowSell,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);   
                     }
                  }             
               }
            
               //Wait for when price is in fvg && bearish engulfing candle on 5min time frame, execute sell. 
               if(InpEntryM == ENUM_PA){
                  fvgPrice = ObjectGetDouble(0,"fvgSell",OBJPROP_PRICE,1);
                  if(currentTick.bid >= fvgPrice || currentTick.bid >= fvgPrice-500*_Point){
                     if(FmBarOneLow < FmBarTwoLow && FmBarOneLow < FmBarThreeLow){
                        
                        SL = currentTick.bid + InpStopLoss*_Point;
                        SLsize = InpStopLoss*_Point;
                        TP = currentTick.bid - InpTakeProfit*_Point;
                        
                        if(InpLotType == ENUM_PERC){
                           lotSize = calcLots(InpRisk,SLsize);
                        }
                        else{
                           lotSize = InpLotSize;
                        }                          
                        trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
                     }  
                  }                        
               }
            }
         }
         
         else{
            if(totalObjects < 1){
               ObjectCreate(0,"fvgSell",OBJ_RECTANGLE,0,fvgStart,barThreeLow,0,barOneHigh);
               ObjectSetInteger(0,"fvgSell",OBJPROP_COLOR,clrPaleGreen);
               ObjectSetInteger(0,"fvgSell",OBJPROP_FILL,true);               
            
               //Instant limit order
               if(InpEntryM == ENUM_ORD){
                  SL = barThreeHigh;
                  SLsize = barThreeHigh - fvgLowSell;
                  TPsize = SLsize*InpRR;
                  TP = fvgLowSell - TPsize;
                  
                  if(barTwoHigh-barTwoLow >= 1000*_Point){
                     SL = barTwoHigh;
                  }
            
                  if(InpLotType == ENUM_PERC){
                     lotSize = calcLots(InpRisk,SLsize);
                  }
                  else{
                     lotSize = InpLotSize;
                  }
                                    
               //Pausing Trade Function After Losses     
                  if(dealLoss >= InpLossTrades && now < lastDeal_Resume){
                     return;
                  }
                                    
               //Normal Trade Function
                  else{    
                     if(InpMACD == true && macdML_Buffer[3] >= 0){      
                        trade.SellLimit(lotSize,fvgLowSell,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                     if(InpMACD == false){
                        trade.SellLimit(lotSize,fvgLowSell,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                  }          
               }
            
               //Wait for price action in FVG to confirm entry
               if(InpEntryM == ENUM_PA){
                  fvgPrice = ObjectGetDouble(0,"fvgSell",OBJPROP_PRICE,1);
                  if(currentTick.bid >= fvgPrice-1500*_Point){
                     pa_Threshold = 100*_Point;
                     
                     if(FmBarOneHigh-FmBarOneLow >= pa_Threshold){
                        
                        SL = currentTick.bid + InpStopLoss*_Point;
                        SLsize = InpStopLoss*_Point;
                        TP = currentTick.bid - InpTakeProfit*_Point;
                        
                        if(InpLotType == ENUM_PERC){
                           lotSize = calcLots(InpRisk,SLsize);
                        }
                        else{
                           lotSize = InpLotSize;
                        }                          
                        trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
                     }
                  }
               }          
            }
         }
      }
      
      
      //Checking-for-BUY-opportunities---------------------------------+
      
      if(barOneLow > barThreeHigh+fvgSize){
         if(barFourHigh > barThreeHigh && barFourHigh < barOneLow-fvgSize){
            if(totalObjects<1){
               ObjectCreate(0,"fvgBuy",OBJ_RECTANGLE,0,fvgStart,barFourHigh,fvgEnd,barOneLow);
               ObjectSetInteger(0,"fvgBuy",OBJPROP_COLOR,clrThistle);
               ObjectSetInteger(0,"fvgBuy",OBJPROP_FILL,true);
               
               //Limit Order
               if(InpEntryM==ENUM_ORD){
                  SL = barThreeLow;
                  SLsize = fvgHighBuy - barThreeLow;
                  TPsize = SLsize*InpRR;
                  TP = fvgHighBuy + TPsize;
                  
                  if(barTwoHigh-barTwoLow >= 1000*_Point){
                     SL = barTwoLow;
                  }
                  
                  if(InpLotType == ENUM_PERC){
                     lotSize = calcLots(InpRisk,SLsize);
                  }
                  else{
                     lotSize = InpLotSize;
                  }
                  
               //Pausing Trade Function After Losses     
                  if(dealLoss >= InpLossTrades && now < lastDeal_Resume){
                     return;
                  }
                  
               //Normal Trade Function
                  else{                       
                     if(InpMACD == true && macdML_Buffer[3] <= 0){
                        trade.BuyLimit(lotSize,fvgHighBuy,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                     if(InpMACD == false){
                        trade.BuyLimit(lotSize,fvgHighBuy,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                  }                                                
               }
               
               if(InpEntryM==ENUM_PA){
                  fvgPrice = ObjectGetDouble(0,"fvgBuy",OBJPROP_PRICE,1);
                  if(currentTick.ask <= fvgPrice+500*_Point){
                     pa_Threshold = 100*_Point;
                  
                     if(FmBarOneHigh-FmBarOneLow >= pa_Threshold){
               
                        SL = currentTick.ask - InpStopLoss*_Point;
                        SLsize = InpStopLoss*_Point;
                        TP = currentTick.ask + InpTakeProfit*_Point;
                  
                        if(InpLotType == ENUM_PERC){
                           lotSize = calcLots(InpRisk,SLsize);
                        }
                        else{
                           lotSize = InpLotSize;
                        }
                                     
                        trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);
                     }     
                  }      
               }
            }
         }
         
         else{
            if(totalObjects<1){
               ObjectCreate(0,"fvgBuy",OBJ_RECTANGLE,0,fvgStart,barThreeHigh,fvgEnd,barOneLow);
               ObjectSetInteger(0,"fvgBuy",OBJPROP_COLOR,clrThistle);
               ObjectSetInteger(0,"fvgBuy",OBJPROP_FILL,true);
               
               if(InpEntryM==ENUM_ORD){
                  SL = barThreeLow;
                  SLsize = fvgHighBuy - barThreeLow;
                  TPsize = SLsize*InpRR;
                  TP = fvgHighBuy + TPsize;
                  
                  if(barTwoHigh-barTwoLow >= 1000*_Point){
                     SL = barTwoLow;
                  }
                  
                  if(InpLotType == ENUM_PERC){
                     lotSize = calcLots(InpRisk,SLsize);
                  }
                  else{
                     lotSize = InpLotSize;
                  }

               //Pausing Trade Function After Losses     
                  if(dealLoss >= InpLossTrades && now < lastDeal_Resume){
                     return;
                  }
                  
               //Normal Trade Function
                  else{                      
                     if(InpMACD == true && macdML_Buffer[3] <= 0){
                        trade.BuyLimit(lotSize,fvgHighBuy,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                     if(InpMACD == false){
                        trade.BuyLimit(lotSize,fvgHighBuy,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,limitExpire,NULL);
                     }
                  }                                   
               }
               
               if(InpEntryM==ENUM_PA){
                  fvgPrice = ObjectGetDouble(0,"fvgBuy",OBJPROP_PRICE,1);
                  if(currentTick.ask <= fvgPrice+500*_Point){
                     pa_Threshold = 100*_Point;
                     
                     if(FmBarOneHigh-FmBarOneLow >= pa_Threshold){
                  
                        SL = currentTick.ask - InpStopLoss*_Point;
                        SLsize = InpStopLoss*_Point;
                        TP = currentTick.ask + InpTakeProfit;
                  
                        if(InpLotType == ENUM_PERC){
                           lotSize = calcLots(InpRisk,SLsize);
                        }
                        else{
                           lotSize = InpLotSize;
                        }
                  
                        trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);                                              
                     }     
                  }                        
               }
            }
         }
      }
      
   }      
   
//---

   //updating right end of fvg rectangle object to current time
   ObjectSetInteger(0,"fvgSell",OBJPROP_TIME,1,currentTime);
   ObjectSetInteger(0,"fvgBuy",OBJPROP_TIME,1,currentTime); 
         

//-deleting current SELL FVG rectangle object---------------------------+   
   if(totalObjects > 0){

      //if price enters object, delete object for SELL
      objectDeletePrice = ObjectGetDouble(0,"fvgSell",OBJPROP_PRICE,1);
      
      //get object start time and set expiry in 24h
      objectStart = (datetime)ObjectGetInteger(0,"fvgSell",OBJPROP_TIME,0);
      objectExpire = objectStart + 100000;
    
      if(InpEntryM == ENUM_ORD){      
         //if price reaches fvg, delete object
         if(currentTick.bid > objectDeletePrice){
            ObjectDelete(0,"fvgSell");
         }
      }
      
      if(InpEntryM == ENUM_PA){
         if(cntSell>0 && currentTick.bid >= objectDeletePrice-500*_Point){
            ObjectDelete(0,"fvgSell");
         }
         if(currentTick.bid >= objectDeletePrice+500*_Point){
            ObjectDelete(0,"fvgSell");
         }
      }
      
      //when time reaches object expiration time, delete objec
      if(currentTime >= objectExpire){
         ObjectDelete(0,"fvgSell");
      }   
   }

//-deleting current BUY FVG rectangle object----------------------------+   
   if(totalObjects > 0){

      //if price enters object, delete object for BUY
      objectDeletePrice = ObjectGetDouble(0,"fvgBuy",OBJPROP_PRICE,1);
      
      //get object start time and set expiry in 24h
      objectStart = (datetime)ObjectGetInteger(0,"fvgBuy",OBJPROP_TIME,0);
      objectExpire = objectStart + 100000;
    
      if(InpEntryM == ENUM_ORD){      
         //if price reaches fvg, delete object
         if(currentTick.ask < objectDeletePrice){
            ObjectDelete(0,"fvgBuy");
         }
      }
      
      if(InpEntryM == ENUM_PA){
         if(cntBuy>0 && currentTick.ask <= objectDeletePrice+500*_Point){
            ObjectDelete(0,"fvgBuy");
         }
         if(currentTick.ask <= objectDeletePrice-500*_Point){
            ObjectDelete(0,"fvgBuy");
         }
      }
      
      //when time reaches object expiration time, delete objec
      if(currentTime >= objectExpire){
         ObjectDelete(0,"fvgBuy");
      }   
   
   }     
   
}




//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

//Count current objects



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


//---Check-For-Consecutive-Losses-To-Stop-Trading--------+

bool consecutiveLosingTrades(){
   
   MqlDateTime today;
   datetime midnight;
   datetime now   = TimeCurrent(today);
   int year       = today.year;
   int month      = today.mon;
   int day        = today.day;

   midnight = StringToTime(string(year)+"."+string(month)+"."+string(day)+" 00:00");
   HistorySelect(midnight,now);
   int total = HistoryDealsTotal();
   long dealLoss = 0;
   
   for(int i=0; i<total; i++){
      ulong ticket = HistoryDealGetTicket(i);
      string symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
      datetime time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      long dealSL = HistoryDealGetInteger(ticket,DEAL_REASON);
      if(time > midnight && dealSL == DEAL_REASON_SL){
         dealLoss++;      
      }
   }
   if(dealLoss>=2){
      return true;   
   }
   return false;
}

bool maxLosses(){

   MqlDateTime             today;
   datetime now         =  TimeCurrent(today); //Current time right now
   datetime lookBack    =  now - 60*60*24*5; //Checking deal history of previous 5 days
   datetime resume      =  now + 60*60*24*InpPauseDays; //Time in future to resume trading
   
   int      total       =  HistoryDealsTotal();
   int      dealLoss    = 0;
   double   totalProfit = 0;
   HistorySelect(lookBack,now);
   
   for(int i = total-1; i>0; i--){
   
      ulong    deal_ticket = HistoryDealGetTicket(i);
      long     deal_time   = (datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);      
      long     deal_entry  = HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
      long     deal_magic  = HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
      double   deal_profit = HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);
      string   deal_symbol = HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
      
      if(deal_time > lookBack && deal_symbol == _Symbol && deal_magic == InpMagicNumber){
         if(deal_profit < 0){
            dealLoss = dealLoss + 1;     
            totalProfit = totalProfit + deal_profit;
            

         }
      }
      
   Comment("TOTAL LOSSES: ",dealLoss,"\nDEAL PROFIT: ",deal_profit,"\nTOTAL PROFIT: ",totalProfit);      
      

      
      
   }    
   
   
   return true;
 
}





