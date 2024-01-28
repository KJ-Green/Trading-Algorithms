//+------------------------------------------------------------------+
//|                                                   Quantum EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| includes and enums                                                                
//+------------------------------------------------------------------
#include <Trade\Trade.mqh>
CTrade trade;
#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;
#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;

enum riskLevel
  {
   ENUM_VERYLOW,  //Very Low
   ENUM_LOW,      //Low
   ENUM_MEDIUM,   //Medium
   ENUM_MEDIUMHIGH, //Medium-High
   ENUM_HIGH,     //High
   ENUM_VERYHIGH, //Very High
  };


//+------------------------------------------------------------------+
//| input parameters                                                                 
//+------------------------------------------------------------------+
input int         InpMagicNumber       = 00211;       //Magic Number
input string      InpStartHour         = "03:00";     //Range Start Time
input string      InpEndHour           = "11:00";     //Range End Time 
input int         InpRangePoints       = 10;          //Points Outside Range
input bool        InpOCO               = true;        //Cancel Other Order
input riskLevel   InpRiskLevel         = ENUM_MEDIUM; //Risk Level
input int         InpTakeProfit        = 1000;        //Take Profit Points;
input string      InpClosePending      = "21:30";     //Close Pending Orders Time
input bool        InpStopFriday        = true;        //Disable Trading on Friday
input bool        InpStopNFP           = false;       //Disable Trading for NFP Friday
input int         InpTrailingStart     = 100;         //Trailing Stop Start (points)
input int         InpTrailingStep      = 50;          //Trailing Stop Step From Price (points)  

input group       "RECOVERY SETTINGS"
input bool        InpUseRecovery       = true;        //Use Recovery Mode
input double      InpRecoveryMulti     = 1.7;         //Recovery Lot Multiplier
input double      InpRecoveryTimes     = 3;           //Recovery Times Multiplier    


//+------------------------------------------------------------------+
//| global variables                                                                
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

double      range_top, range_Bottom;
double      buySL, sellSL, buyTP, sellTP, buyTS, buyTS_TP, sellTS, sellTS_TP, slSize, tpSize, slDistance, lotSize, original_lotSize;
double      buyTS_level, sellTS_level;

datetime    dayStart, rangeStart, rangeEnd, rangeLength, rangeCheck, pendingClose, next_dayStart;
string      str_dayStart;

int         range_count, today_sells, today_buys, dd_sellsRecovered, dd_buysRecovered;;
int         recovery_sellsClose=0; 
int         recovery_buysClose=0;
int         barsTotal;
int         dd_posBuy, dd_posSell, org_vol_sell, rec_vol_sell, org_vol_buy, rec_vol_buy;
int         open_recSells, open_recBuys, open_orgnlSells, open_orgnlBuys;

double      sell_Pnl, buy_pnl, balance_dd;
bool        in_drawdown; 
bool        recovery=false;
datetime    nextTS_check;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   trade.SetExpertMagicNumber(InpMagicNumber);   
   
   barsTotal = iBars(_Symbol,PERIOD_D1);
   
//---
   return(INIT_SUCCEEDED);
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{


   
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!SymbolInfoTick(_Symbol,currentTick)){Alert("Failed to get current tick.");return;}
   
//---

   //counting open positions for max positions
   int posBuy, posSell;
   CountOpenPositions(posBuy,posSell);
   
   //couting current orders
   int ordBuy, ordSell;
   CountOrders(ordBuy,ordSell);
 
   if(InpOCO==true){
      if(posBuy>0 || posSell>0){
         deletePendingOrder();
      }
   }     
   
   int bars = iBars(_Symbol,PERIOD_D1);
   if(barsTotal != bars){
      barsTotal = bars;
      today_buys=0;
      today_sells=0;
   }
   
   if(posBuy==0 && posSell==0){in_drawdown=false;}
   if(accountInfo.Profit()>0){in_drawdown=false;}
   if(accountInfo.Profit() < 0){in_drawdown=true;}
   
   if(ordBuy==0 && posBuy==0){buyTS_level=0;}
   if(ordSell==0 && posSell==0){sellTS_level=0;}

   if(posBuy==0){dd_buysRecovered=0;}
   if(posSell==0){dd_sellsRecovered=0;}
   //Comment("recvoery buys close: ",recovery_buysClose,"recovery sells close: ",recovery_sellsClose);
//---

   dayStart = iTime(_Symbol,PERIOD_D1,0);
   next_dayStart = dayStart + PeriodSeconds(PERIOD_D1);
   str_dayStart = TimeToString(dayStart,TIME_DATE);
   rangeStart = StringToTime(InpStartHour);
   rangeEnd = StringToTime(InpEndHour);
   rangeLength = rangeEnd - rangeStart; 
   rangeCheck = rangeEnd + PeriodSeconds(PERIOD_H1); 
   pendingClose = StringToTime(InpClosePending); 
   
   string str_lengthHour = TimeToString(rangeLength,TIME_MINUTES);
   int index_length = StringToInteger(str_lengthHour) + 1;
   
   range_top = iHigh(_Symbol,PERIOD_H1,iHighest(_Symbol,PERIOD_H1,MODE_HIGH,index_length,1));
   range_Bottom = iLow(_Symbol,PERIOD_H1,iLowest(_Symbol,PERIOD_H1,MODE_LOW,index_length,1));
   
   if(TimeCurrent() > rangeEnd && range_count == 0){
      //ObjectCreate(0,"range_high",OBJ_HLINE,0,rangeStart,range_top);
      //ObjectCreate(0,"range_low",OBJ_HLINE,0,rangeStart,range_Bottom);
      range_count = 1;
   }
   if(TimeCurrent() > pendingClose){
      //ObjectDelete(0,"range_high");
      //ObjectDelete(0,"range_low");
      range_count = 0;
   }

     
//auto lot (based on 100k balance | 7 orders)
   
  //very low (0.01 per 10,000 | 0.7 lots total)
  if(InpRiskLevel==ENUM_VERYLOW){lotSize = NormalizeDouble((accountInfo.Balance() / 10000 * 0.01),2);}
  //low (0.01 per 7150 | 1 lot total)
  if(InpRiskLevel==ENUM_LOW){lotSize = NormalizeDouble((accountInfo.Balance() / 7150 * 0.01),2);}
  //medium (0.01 per 2450 | 2.9 lots total)
  if(InpRiskLevel==ENUM_MEDIUM){lotSize = NormalizeDouble((accountInfo.Balance() / 2450 * 0.01),2);}
  //medium-high (0.01 per 1410 | 5 lots total)
  if(InpRiskLevel==ENUM_MEDIUMHIGH){lotSize = NormalizeDouble((accountInfo.Balance() / 1410 * 0.01),2);}
  //high (0.01 per 1050 | 6.7 lots total)
  if(InpRiskLevel==ENUM_HIGH){lotSize = NormalizeDouble((accountInfo.Balance() / 1050 * 0.01),2);}
  //very-high (0.01 per 700 | 10 lots total)
  if(InpRiskLevel==ENUM_VERYHIGH){lotSize = NormalizeDouble((accountInfo.Balance() / 700 * 0.01),2);}
  
  if(in_drawdown==true){original_lotSize=lotSize; lotSize = NormalizeDouble((lotSize*InpRecoveryMulti),2);}



//=== Setting Pending Orders ==========================================================================================================//

   if(ordBuy < 7 && !haveTradedToday() && TimeCurrent() > rangeEnd){
      //sl 2500 points
      buySL = range_top - 2500*_Point;
      buyTP = range_top + InpTakeProfit*_Point;
      trade.BuyStop(lotSize,range_top,_Symbol,buySL,buyTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
      buyTS_level = range_top + InpTrailingStart*_Point;
   }
   
   if(ordSell < 7 && !haveTradedToday() && TimeCurrent() > rangeEnd){
      sellSL = range_Bottom + 2500*_Point;
      sellTP = range_Bottom - InpTakeProfit*_Point;
      trade.SellStop(lotSize,range_Bottom,_Symbol,sellSL,sellTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
      sellTS_level = range_Bottom - InpTrailingStart*_Point;
   }

     
//=== TRAILING STOP ==================================================================================================================//  

   double Ask;
   Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK,Ask);
   if(posBuy>0){
      checkTrailingSLBuy(Ask);
                                          //bug in trailing stop buyTS_level
   }  
   if(currentTick.ask>buyTS_level){
      buyTS_level=currentTick.ask+InpTrailingStep*_Point;
   }

   double Bid;
   Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID,Bid);
   if(posSell>0){
      checkTrailingSLSell(Bid);  
   } 
   if(currentTick.bid<sellTS_level){
      sellTS_level=currentTick.bid-InpTrailingStep*_Point;
   }



//=== CHECKING FOR OPEN RECOVERY POSITIONS ==============================================//
     
   if(in_drawdown==true){
      open_recSells=0;
      open_orgnlSells=0;
      open_recBuys=0;
      open_orgnlBuys=0;
      for(int i = PositionsTotal()-1; i>=0; i--){
         string symbol = PositionGetSymbol(i);
         double volume = PositionGetDouble(POSITION_VOLUME);
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC); 
         if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && volume==lotSize){//original lot size is changing when positions close and balance increases
            open_recSells++;
         }
         if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && volume < lotSize){
            open_orgnlSells++;
         }  
         if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && volume==lotSize){
            open_recBuys++;
         }
         if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && volume < lotSize){
            open_orgnlBuys++;
         }                                              
      }
   }
   if(in_drawdown==false){
      open_recSells = 0;
      open_orgnlSells = 0;
      open_recBuys = 0;
      open_orgnlBuys = 0;
   }
  
       
   //Comment("open_recSells: ",open_recSells,"\nopen_orgnlSells: ",open_orgnlSells,"\nposSell: ",posSell,"\ndd_sellsRecovered: ",dd_sellsRecovered,"\nrecovery_sellsClose: ",recovery_sellsClose,
   //         "\n\nopen_recBuys: ",open_recBuys,"\nopen_orgnlBuys: ",open_orgnlBuys,"\nposBuy: ",posBuy,"\ndd_buysRecovered: ",dd_buysRecovered,"\nrecovery_buysClose: ",recovery_buysClose,
   //         "\n\noriginal lotsize: ",original_lotSize,"\nlotSize: ",lotSize,"\nin_drawdown: ",in_drawdown,"\n\nbuyTS_level: ",buyTS_level,"\nsellTS_level: ",sellTS_level,"\n\nnextTS_check: ",nextTS_check);
      
   Comment("recovery: ",recovery,"\n\ndd_BuysRecovered: ",dd_buysRecovered);

//=== RECOVERY MODE CLOSE SELLS =====================================================================//
   //Comment("recovery_buysclose: ",recovery_buysClose,"\nrecovery_sellsclose: ",recovery_sellsClose,"\ndd posSell: ",dd_posSell,"\norg_sell: ",org_vol_sell,"\nrec sell: ",rec_vol_sell);
   //Closing single sell positions in DD   
   if((in_drawdown==true && recovery_buysClose>0 && recovery_buysClose<8) || (in_drawdown==true && recovery_sellsClose>0 && recovery_sellsClose<8)){
      if(dd_sellsRecovered==0 && open_orgnlSells>0){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==0){
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=1; 
            }                       
         }   
      }
   }
   
   //if(open_orgnlSells>0 && open_recSells==0){recovery_sellsClose=0;}
   //if(open_orgnlSells>0 && open_recBuys==0){recovery_buysClose=0;}   

   if((in_drawdown==true && recovery_buysClose>7 && recovery_buysClose<15) || (in_drawdown==true && recovery_sellsClose>7 && recovery_sellsClose<15)){         
      if(dd_sellsRecovered==1 && open_orgnlSells>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==1){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=2;
            }                       
         }
      }   
   }
   
   if((in_drawdown==true && recovery_buysClose>14 && recovery_buysClose<23) || (in_drawdown==true && recovery_sellsClose>14 && recovery_sellsClose<23)){         
      if(dd_sellsRecovered==2 && open_orgnlSells>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==2){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=3;
            }                       
         }
      }   
   }

   if((in_drawdown==true && recovery_buysClose>22 && recovery_buysClose<31) || (in_drawdown==true && recovery_sellsClose>22 && recovery_sellsClose<31)){         
      if(dd_sellsRecovered==3 && open_orgnlSells>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==3){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=4;
            }                       
         }
      }   
   }   
   
   if((in_drawdown==true && recovery_buysClose>31 && recovery_buysClose<39) || (in_drawdown==true && recovery_sellsClose>31 && recovery_sellsClose<39)){         
      if(dd_sellsRecovered==4 && open_orgnlSells>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==4){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=5;
            }                       
         }
      }   
   }

   if((in_drawdown==true && recovery_buysClose>39 && recovery_buysClose<47) || (in_drawdown==true && recovery_sellsClose>39 && recovery_sellsClose<47)){         
      if(dd_sellsRecovered==5 && open_orgnlSells>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==5){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=6;
            }                       
         }
      }   
   }

   if((in_drawdown==true && recovery_buysClose>47 && recovery_buysClose<55) || (in_drawdown==true && recovery_sellsClose>47 && recovery_sellsClose<55)){         
      if(dd_sellsRecovered==6 && open_orgnlSells>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_SELL && magic==InpMagicNumber && dd_sellsRecovered==6){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_sellsRecovered=7;
            }                       
         }
      }   
   }   
 
 
 
 
 
 
 
//== RECOVERY MODE CLOSE BUYS ======================================================================================//   
   
   //Closing single buy positions in DD
   //if(in_drawdown==true && recovery_sellsClose==1){
   //   if(dd_buysRecovered==0){
   //      for(int i = PositionsTotal()-1; i>=0; i--){
   //         string symbol = PositionGetSymbol(i);
   //         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
   //         long type = PositionGetInteger(POSITION_TYPE);
   //         long magic = PositionGetInteger(POSITION_MAGIC); 
   //         if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && dd_buysRecovered==0){
   //            trade.PositionClose(positionTicket,-1);
   //            dd_buysRecovered=1;
   //         }                       
   //      }
   //   }
   //} 



   
   //if(in_drawdown==true && recovery==true && dd_buysRecovered==0){
   if((in_drawdown==true && recovery_buysClose>0 && recovery_buysClose<8) || (in_drawdown==true && recovery_sellsClose>0 && recovery_sellsClose<8)){
      if(dd_buysRecovered==0 && open_orgnlBuys>0){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && posVolume<lotSize && dd_buysRecovered==0){
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=1;
            }                       
         }
      }               
   }   
   //if(dd_buysRecovered==1){
   //   recovery=false;
   //}     

   //if(in_drawdown==true && recovery==true && dd_buysRecovered==1){
   if((in_drawdown==true && recovery_buysClose>7 && recovery_buysClose<15) || (in_drawdown==true && recovery_sellsClose>7 && recovery_sellsClose<15)){
      if(dd_buysRecovered==0 && open_orgnlBuys>0){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && posVolume<lotSize && dd_buysRecovered==1){
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=2;
            }                       
         }
      }               
   }          
   //if(dd_buysRecovered==2){
   //   recovery=false;
   //} 

   if((in_drawdown==true && recovery_buysClose>14 && recovery_buysClose<23) || (in_drawdown==true && recovery_sellsClose>14 && recovery_sellsClose<23)){         
      if(dd_buysRecovered==2 && open_orgnlBuys>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && dd_buysRecovered==2){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=3;
               nextTS_check = TimeCurrent()+PeriodSeconds(PERIOD_M5);                
            }                       
         }
      }   
   }
  
   if((in_drawdown==true && recovery_buysClose>22 && recovery_buysClose<31) || (in_drawdown==true && recovery_sellsClose>22 && recovery_sellsClose<31)){         
      if(dd_buysRecovered==3 && open_orgnlBuys>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && dd_buysRecovered==3){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=4;
               nextTS_check = TimeCurrent()+PeriodSeconds(PERIOD_M5);                
            }                       
         }
      }   
   }   

   if((in_drawdown==true && recovery_buysClose>31 && recovery_buysClose<39) || (in_drawdown==true && recovery_sellsClose>31 && recovery_sellsClose<39)){         
      if(dd_buysRecovered==4 && open_orgnlBuys>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && dd_buysRecovered==4){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=5;
            }                       
         }
      }   
   }  
  
   if((in_drawdown==true && recovery_buysClose>39 && recovery_buysClose<47) || (in_drawdown==true && recovery_sellsClose>39 && recovery_sellsClose<47)){         
      if(dd_buysRecovered==5 && open_orgnlBuys>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && dd_buysRecovered==5){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=6;
            }                       
         }
      }   
   }  

   if((in_drawdown==true && recovery_buysClose>47 && recovery_buysClose<55) || (in_drawdown==true && recovery_sellsClose>47 && recovery_sellsClose<55)){         
      if(dd_buysRecovered==6 && open_orgnlBuys>0){   //      if((dd_sellsRecovered==1 && recovery_sellsClose==1) || (dd_sellsRecovered==1 && recovery_buysClose==1)){
         for(int i = PositionsTotal()-1; i>=0; i--){
            string symbol = PositionGetSymbol(i);
            ulong positionTicket = PositionGetInteger(POSITION_TICKET);
            long type = PositionGetInteger(POSITION_TYPE);
            long magic = PositionGetInteger(POSITION_MAGIC); 
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            if(symbol==_Symbol && type==POSITION_TYPE_BUY && magic==InpMagicNumber && dd_buysRecovered==6){ //posVolume < lotSize
               trade.PositionClose(positionTicket,-1);
               dd_buysRecovered=7;
            }                       
         }
      }   
   }   
   
     
   
   //if(posBuy==0){recovery_buysClose=0;}
   //if(posSell==0){recovery_sellsClose=0;}
   
   //if(rec_vol_buy==0){recovery_buysClose=0;}
   //if(rec_vol_sell==0){recovery_sellsClose=0;}
   
   if(posBuy==0 && posSell==0){recovery_buysClose=0; recovery_sellsClose=0;}
   
   //if(open_orgnlSells>0 && open_recSells==0){recovery_sellsClose=0;}
   //if(open_orgnlSells>0 && open_recBuys==0){recovery_buysClose=0;}
}


//+------------------------------------------------------------------+
//| Custom Functions                                                                
//+------------------------------------------------------------------+


//=== COUNT PENDING ORDERS =========================================================================//
 
bool CountOrders(int &ordBuy, int &ordSell){
   
   ordBuy   = 0;
   ordSell  = 0;
   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--){
   //for(int i = 0; i <= total; i++){
      ulong ticket = OrderGetTicket(i);
      if(ticket <= 0){
         Print("Failed to get order ticket.");
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
         if(!OrderGetInteger(ORDER_TYPE,type)){Print("Failed to get order type."); return false;}
         if(type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT){ordBuy++;}
         if(type == ORDER_TYPE_SELL_STOP || type == ORDER_TYPE_SELL_LIMIT){ordSell++;}
      }
   }
   
   return true;
}

//=== DELETE PENDING ORDER =========================================================================//

void deletePendingOrder(){
   int totalOrders = OrdersTotal();
   for(int i=totalOrders-1; i>=0; i--){
      ulong ticket = OrderGetTicket(i);
      long type; 
      if(!OrderGetInteger(ORDER_TYPE,type)){Print("Failed to get order type.");}
      long magic;
      if(!OrderGetInteger(ORDER_MAGIC,magic)){Print("Failed to get order magic number");}
      //delete sell orders
      if(today_buys>0 && type==ORDER_TYPE_SELL_STOP && magic==InpMagicNumber){
         trade.OrderDelete(ticket);
      }
      //delete buy orders
      if(today_sells>0 && type==ORDER_TYPE_BUY_STOP && magic==InpMagicNumber){
         trade.OrderDelete(ticket);
      }
   }
}


//=== COUNT OPEN POSITIONS ========================================================================//
 
bool CountOpenPositions(int &posBuy, int &posSell){
   
   posBuy   = 0;
   posSell  = 0;
   int total = PositionsTotal();
   for(int i=total-1; i>=0; i--){
      ulong ticket = PositionGetTicket(i);
      double posVol = PositionGetDouble(POSITION_VOLUME);
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
         
//         if(in_drawdown==true){
//            if(type == POSITION_TYPE_BUY){dd_posBuy=1;}
//            if(type == POSITION_TYPE_SELL){dd_posSell=1;}
//            
//            if(type == POSITION_TYPE_BUY && posVol==original_lotSize){org_vol_buy=1;}
//            if(type == POSITION_TYPE_SELL && posVol==original_lotSize){org_vol_sell=1;}  
//            
//            if(type == POSITION_TYPE_BUY && posVol==lotSize){rec_vol_buy=1;}
//            if(type == POSITION_TYPE_SELL && posVol==lotSize){rec_vol_sell=1;}                       
//         }
      }
   }
   
   return true;
}


//=== CHECK IF HAVE TRADED TODAY ===================================================================//

bool haveTradedToday(){
   //MqlDateTime today;
   datetime midnight;
   datetime now   = TimeCurrent(today);
   int year       = today.year;
   int month      = today.mon;
   int day        = today.day;

   midnight = StringToTime(string(year)+"."+string(month)+"."+string(day)+" 00:00");
   HistorySelect(midnight,now);
   int total = HistoryDealsTotal();
   
   for(int i=0; 1<total; i++){
      ulong ticket = HistoryDealGetTicket(i);
      string symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
      datetime time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(time>midnight){
         return true;
      }
   }
   
   return false;
}



//=== TRAILING STOP FUNCTION =============================================================================//

void  checkTrailingSLBuy(double ask){
   int ordBuy, ordSell;
   CountOrders(ordBuy,ordSell);

   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      
      if(InpTrailingStart==0){
         return;
      }
      
      if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC);
         double volume = PositionGetDouble(POSITION_VOLUME);         
         buyTS = buyTS_level - InpTrailingStep*_Point;
         buyTS_TP = openPrice + InpTakeProfit*_Point;
 
 
         if(in_drawdown==true && open_recBuys==0 && ordBuy==0){
            if(volume<lotSize && type==POSITION_TYPE_BUY){
               if(currentTick.ask<openPrice){
                  buyTS_level=openPrice+InpTrailingStart*_Point;
               }
            }
         }
         if(in_drawdown==true && type==POSITION_TYPE_BUY && volume==lotSize && magic==InpMagicNumber){
            buyTS_level = openPrice+InpTrailingStart*_Point;
         } 
 
 
         if(in_drawdown==false){
            if(magic==InpMagicNumber && type==POSITION_TYPE_BUY && currentTick.ask>=buyTS_level){
               trade.PositionModify(positionTicket,buyTS,buyTS_TP); 
            }
         }   
            
         //if(in_drawdown==true && open_recBuys==0 && ordBuy==0 && type==POSITION_TYPE_BUY && magic==InpMagicNumber){
         //   buyTS_level = openPrice + InpTrailingStart*_Point;
         //}
         if(in_drawdown==true){    
            if(magic==InpMagicNumber && type==POSITION_TYPE_BUY && currentTick.bid>=buyTS_level && volume==lotSize){ // && volume==lotSize
               trade.PositionModify(positionTicket,buyTS,buyTS_TP);
            }
            if(currentTick.bid>=buyTS_level){
               buyTS_level = buyTS_level+InpTrailingStep*_Point;
            }            
         }

                  
      }         
   }                     
}


void  checkTrailingSLSell(double bid){
   int ordBuy, ordSell;
   CountOrders(ordBuy,ordSell); 
 
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      
      if(InpTrailingStart==0){
         return;
      }
      
      if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC);
         double volume = PositionGetDouble(POSITION_VOLUME);
         sellTS = sellTS_level + InpTrailingStep*_Point;
         sellTS_TP = openPrice - InpTakeProfit*_Point;
         
         //if(in_drawdown==false){
         if(magic==InpMagicNumber && type==POSITION_TYPE_SELL && currentTick.bid<=sellTS_level){
            trade.PositionModify(positionTicket,sellTS,sellTS_TP);
         }
         //}   
         if(in_drawdown==true){    
            if(magic==InpMagicNumber && type==POSITION_TYPE_SELL && currentTick.bid<=sellTS_level && volume==lotSize){
               trade.PositionModify(positionTicket,sellTS,sellTS_TP);
            }            
         }
      }         
   }
}   

//=== TRADE TRANSACTION FUNCTION =====================================================================//

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
      double   deal_tp           =0.0;
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
         deal_tp           =HistoryDealGetDouble(trans.deal,DEAL_TP);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);         
      }
      else
         return;
         
      datetime midnight = iTime(_Symbol,PERIOD_D1,0);
      if(deal_entry==DEAL_ENTRY_IN && deal_type==DEAL_TYPE_BUY && deal_time>midnight && deal_magic==InpMagicNumber){
         today_buys=1;      
      }
      if(deal_entry==DEAL_ENTRY_IN && deal_type==DEAL_TYPE_SELL && deal_time>midnight && deal_magic==InpMagicNumber){
         today_sells=1;
      }
      
      if(in_drawdown==true){
         //detecting recovery sells exit (to close one buy position in dd)                     
         if(deal_entry==DEAL_ENTRY_OUT && deal_type==DEAL_TYPE_BUY && deal_magic==InpMagicNumber){
            //recovery_sellsClose = 1;
            recovery_sellsClose++;
         }
         //detecting recovery buys exit (to close one sell position in dd)
         if(deal_entry==DEAL_ENTRY_OUT && deal_type==DEAL_TYPE_SELL && deal_magic==InpMagicNumber){
            //recovery_buysClose = 1;
            recovery_buysClose++;
         }
      }
      
//      if(in_drawdown==true){
//      
//         //detecting recovery sell basket close  //(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) &&
//         if(deal_entry==DEAL_ENTRY_OUT && deal_volume==lotSize && deal_magic==InpMagicNumber && recovery==false){
//            recovery=true;
//         }
//         if(deal_entry==DEAL_ENTRY_OUT && deal_volume<lotSize && deal_magic==InpMagicNumber && recovery==true){
//            recovery=false;
//         }
//      }

               
   }   
}