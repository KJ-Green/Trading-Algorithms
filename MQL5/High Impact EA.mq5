//+------------------------------------------------------------------+
//|                                               High Impact EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;

enum LotType{
   ENUM_PERC,     //%Risk
   ENUM_FIXED     //Fixed Lot   
};

enum EntryMethod{
   ENUM_MARKET,   //Market Execution
   ENUM_STOP,     //Stop Orders
   ENUM_LIMIT     //Limit Orders   
};



//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int         InpMagicNumber          =  220887;        //Magic Number
input string      InpTradeComment         =  "High Impact EA"; //Trade Comment

input group       "-POSITION SIZE-"
input LotType     InpLotType              =  ENUM_PERC;     //Lot Type
input double      InpRisk                 =  1.00;          //Risk Percentage
input double      InpLotSize              =  0.01;          //Fixed Lot Size
input double      InpRR                   =  3;             //Risk to Reward - 1:

input group       "-NEWS EVENTS-"
input string      InpNewsNameOne          =  "";            //News Event Name 1
input string      InpNewsNameTwo          =  "";            //News Event Name 2

input group       "-TRADE PARAMETERS-"
input EntryMethod InpEntryMethod          =  ENUM_MARKET;   //Trade Entry Method
input int         InpOrderDist            =  10;            //Order Distance - Pips
input bool        InpOCO                  =  false;         //Order Cancels Other Order
input int         InpMinBefore            =  0;             //Entry Minutes Before News
input int         InpMinExpire            =  0;             //Order Expire in Minutes
input int         InpStopLoss             =  10;            //Stop Loss - Pips   



//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick     currentTick;
MqlDateTime today;
datetime    eventTime, entryTime, expiryTime;
double      buyStop, sellStop, buyLimit, sellLimit;
double      lotSize, buySlSize, buyTpSize, sellSlSize, sellTpSize;
double      buySL, buyTP, sellSL, sellTP;
double      buyStopSL, buyStopTP, sellStopSL, sellStopTP;
double      buyLimitSL, buyLimitTP, sellLimitSL, sellLimitTP;
double      buyStopSLsize, buyStopTPsize, sellStopSLsize, sellStopTPsize;
double      buyLimitSLsize, buyLimitTPsize, sellLimitSLsize, sellLimitTPsize;
double      slPoints, tpPoints, ordDistPoints;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

//---

   if(InpMagicNumber < 0){Alert("Invalid Magic Number, Must be > 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotSize < 0){Alert("Invalid Lot Size, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpRisk < 0){Alert("Invalid Risk Percentage, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpStopLoss < 0){Alert("Invalid Stop Loss, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
//---

   slPoints       = InpStopLoss * 10 * _Point;
   ordDistPoints  = InpOrderDist * 10 * _Point;

   trade.SetExpertMagicNumber(InpMagicNumber);
   
//---


   return(INIT_SUCCEEDED);
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

//---

   if(!SymbolInfoTick(_Symbol,currentTick)){
      Print("Failed to get current tick.");
      return;
   }

//---

   slPoints       = InpStopLoss * 10 * _Point;
   ordDistPoints  = InpOrderDist * 10 * _Point;


//---


   //count open positions
   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
   //couting current orders
   int ordBuy, ordSell;
   CountOrders(ordBuy,ordSell);   
   
//---   

   datetime startTimeDay   = iTime(_Symbol,PERIOD_D1,0);
   datetime endTimeDay     = startTimeDay + PeriodSeconds(PERIOD_D1);
   
//---
      
   MqlCalendarValue values[];   
   CalendarValueHistory(values,startTimeDay,endTimeDay,NULL,NULL);
   
//---

   for(int i = 0; i < ArraySize(values); i++){
      
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id,event);  
      
      MqlCalendarCountry country;
      CalendarCountryById(event.country_id,country);
      
      if(StringFind(_Symbol,country.currency) < 0) continue;
      if(event.importance == CALENDAR_IMPORTANCE_NONE) continue;
      if(event.importance == CALENDAR_IMPORTANCE_LOW) continue;   

//---      

      string strtodaydate  = TimeToString(TimeCurrent(),TIME_DATE);
      string strtimenow    = TimeToString(TimeCurrent(),TIME_MINUTES);
      //Comment("trading high impact on ",strtodaydate,"\ncurrent time: ",strtimenow,"\nNo tradeable events today...");

//---
      
      if(event.name == InpNewsNameOne || event.name == InpNewsNameTwo){
         
         eventTime = values[i].time;
         entryTime = eventTime - InpMinBefore * PeriodSeconds(PERIOD_M1);
         expiryTime = entryTime + InpMinExpire * PeriodSeconds(PERIOD_M1);
         
         string strEventTime = TimeToString(values[i].time,TIME_MINUTES);
         string strEntryTime = TimeToString(entryTime,TIME_MINUTES);
         string strExpiryTime = TimeToString(expiryTime,TIME_MINUTES);        
        
         
         //---
         
         buySL       = currentTick.ask - slPoints;
         buySlSize   = currentTick.ask - buySL; 
         buyTpSize   = buySlSize * InpRR;
         buyTP       = currentTick.ask + buyTpSize;
         
         //---
         
         sellSL      = currentTick.bid + slPoints;
         sellSlSize  = sellSL - currentTick.bid;
         sellTpSize  = sellSlSize * InpRR;
         sellTP      = currentTick.bid - sellTpSize;
         
         //---
         
         buyStop     = currentTick.ask + ordDistPoints;
         buyStopSL   = buyStop - slPoints;
         buyStopSLsize = buyStop - buyStopSL;
         buyStopTPsize = buyStopSLsize * InpRR;
         buyStopTP   = buyStop + buyStopTPsize;
         
         //---
         
         sellStop    = currentTick.bid - ordDistPoints;
         sellStopSL  = sellStop + slPoints;
         sellStopSLsize = sellStopSL - sellStop;
         sellStopTPsize = sellStopSLsize * InpRR;
         sellStopTP  = sellStop - sellStopTPsize;
         
         //---
         
         buyLimit    = currentTick.ask - ordDistPoints;
         buyLimitSL  = buyLimit - slPoints;
         buyLimitSLsize = buyLimit - buyLimitSL;
         buyLimitTPsize = buyLimitSLsize * InpRR;
         buyLimitTP  = buyLimit + buyLimitTPsize;
         
         //---
         
         sellLimit   = currentTick.bid + ordDistPoints;
         sellLimitSL = sellLimit + slPoints;
         sellLimitSLsize = sellLimitSL - sellLimit;
         sellLimitTPsize = sellLimitSLsize * InpRR;
         sellLimitTP = sellLimit - sellLimitTPsize;        
         
         //---
         
         //setting value of lots depending on fixed or risk        
          double lots;
         if(InpLotType == ENUM_PERC){
            lots = calcLots(InpRisk,slPoints);
         }
         else{
            lots = InpLotSize;
         }
         
         //---                  
         
                

         
         if(InpEntryMethod==ENUM_MARKET){
         
            Comment("|||[ Trading High Impact ]|||","\n\n  ",strtodaydate,"   |   ",strtimenow,
                    "\nUpcoming High Impact: ",event.name,"\nEventTime: ",strEventTime,"\nEntryTime: ",strEntryTime);
         
            if(cntBuy < 1 && cntSell < 1){
               if(TimeCurrent() >= entryTime && TimeCurrent() <= expiryTime + 15){                           
                  trade.Buy(lots,_Symbol,currentTick.ask,buySL,buyTP,InpTradeComment);
                  trade.Sell(lots,_Symbol,currentTick.bid,sellSL,sellTP,InpTradeComment);
               }      
            }
         }    

         if(InpEntryMethod==ENUM_STOP){
         
            Comment("|||[ Trading High Impact ]|||","\n\n  ",strtodaydate,"   |   ",strtimenow,
                    "\nUpcoming High Impact: ",event.name,"\nEventTime: ",strEventTime,"\nEntryTime: ",strEntryTime,"\nExpiryTime: ",strExpiryTime);  
                           
            if(ordBuy < 1 && ordSell < 1){
               //if(InpMinExpire <= 0){Alert("Pending orders must have an expiry time. Order Expiry in Minutes must be greater than 0.");}             
               if(TimeCurrent() >= entryTime && TimeCurrent() <= expiryTime + 15){           
                  trade.BuyStop(lots,buyStop,_Symbol,buyStopSL,buyStopTP,ORDER_TIME_SPECIFIED,expiryTime,InpTradeComment);
                  trade.SellStop(lots,sellStop,_Symbol,sellStopSL,sellStopTP,ORDER_TIME_SPECIFIED,expiryTime,InpTradeComment);
               }  
                 
            }
         }    
            
         if(InpEntryMethod==ENUM_LIMIT){
         
            Comment("|||[ Trading High Impact ]|||","\n\n  ",strtodaydate,"   |   ",strtimenow,
                    "\nUpcoming High Impact: ",event.name,"\nEventTime: ",strEventTime,"\nEntryTime: ",strEntryTime,"\nExpiryTime: ",strExpiryTime);         
            
            if(ordBuy < 1 && ordSell < 1){
               if(TimeCurrent() >= entryTime && TimeCurrent() <= expiryTime + 15){            
                  trade.BuyLimit(lots,buyLimit,_Symbol,buyLimitSL,buyLimitTP,ORDER_TIME_SPECIFIED,expiryTime,InpTradeComment);
                  trade.SellLimit(lots,sellLimit,_Symbol,sellLimitSL,sellLimitTP,ORDER_TIME_SPECIFIED,expiryTime,InpTradeComment);
               }
            }           
         }         
      }
      
//      else{
//      
//         string strtodaydate  = TimeToString(TimeCurrent(),TIME_DATE);
//         string strtimenow    = TimeToString(TimeCurrent(),TIME_MINUTES);
//         Comment("trading high impact on ",strtodaydate,"\ncurrent time: ",strtimenow,"\nno tradeable events today...");
//      }        
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




//---Count total orders---------------------------------+ 
bool CountOrders(int &ordBuy, int &ordSell){
   
   ordBuy   = 0;
   ordSell  = 0;
   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--){
      ulong ticket = OrderGetTicket(i);
      if(ticket <= 0){
         Print("Failed to get Order ticket.");
         return false;
      }
      //if(!PositionSelectByTicket(ticket)){
      //   Print("Failed to select position.");
      //   return false;
      //}
      long magic;
      if(!OrderGetInteger(ORDER_MAGIC,magic)){
         Print("Failed to get position magic number.");
         return false;
      }
      //if magic number of a position belongs to this ea
      if(magic == InpMagicNumber){
         long type;
         if(!OrderGetInteger(ORDER_TYPE,type)){Print("Failed to get position type."); return false;}
         if(type == ORDER_TYPE_BUY_STOP){ordBuy++;}
         if(type == ORDER_TYPE_SELL_STOP){ordSell++;}
         if(type == ORDER_TYPE_BUY_LIMIT){ordBuy++;}
         if(type == ORDER_TYPE_SELL_LIMIT){ordSell++;}
      }
   }
   
   return true;
}

