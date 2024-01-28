//+------------------------------------------------------------------+
//|                                               Money Gaurdian.mq5 |
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


enum protectType
  {
   enum_startBal,    //Max DD From Starting Balance (Prop Firm)
   enum_currentBal,  //Max DD From Current Balance
   enum_equity,      //Max DD From Equity
   enum_equityMax,   //Equity Cutoff
   enum_startBalMax  //Starting Balance Cutoff (Prop Firm)   
  };
  
enum riskType
  {
   enum_currency,   //Currency
   enum_perc        //%
  };  
  
enum action
  {
   enum_closeTrades,    //Close All Open Trades
   enum_closeNegative,  //Close Only Negative Trades
   enum_alert           //Send Alert / Leave Trades Open
  };  
//+------------------------------------------------------------------+
//| Inputs                                                     
//+------------------------------------------------------------------+

input protectType    InpProtectType    =  enum_startBal;    //Account Protection Type
input riskType       InpRiskType       =  enum_currency;    //Risk Type
input double         InpAmount         =  0.0;              //Protection Amount
input action         InpAction         =  enum_closeTrades;  //Action When Amount Met


//+------------------------------------------------------------------+
//|  Global Variables                                                          
//+------------------------------------------------------------------+

double   start_balance, current_balance, equity, balance_dd_amount, equity_dd_amount, equity_cutoff;
double   trigger_close; 
  

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   HistorySelect(0,TimeCurrent());
   
   int total = HistoryDealsTotal();
   ulong ticket = 0;
   ulong deal_type;
   double deal_profit;
   
   for(int i=0; i<total; i++){
      //--- try to get deals ticket
      if((ticket=HistoryDealGetTicket(i))>0){
         
         deal_type = HistoryDealGetInteger(ticket,DEAL_TYPE);
         deal_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         
         if(deal_type==DEAL_TYPE_BALANCE && deal_profit>0){
            start_balance=deal_profit;
         }
      }  
   }
   

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

   current_balance = accountInfo.Balance();
   equity = accountInfo.Equity();

//---

   if(InpProtectType==enum_startBal && InpRiskType==enum_currency){
      trigger_close = start_balance-InpAmount;
   }   
   if(InpProtectType==enum_startBal && InpRiskType==enum_perc){
      trigger_close = start_balance-(start_balance/100*InpAmount);
   } 
         
//---

   if(InpProtectType==enum_currentBal && InpRiskType==enum_currency){
      trigger_close = current_balance-InpAmount;
   }   
   if(InpProtectType==enum_currentBal && InpRiskType==enum_perc){
      trigger_close = current_balance-(current_balance/100*InpAmount);
   } 

//---

   if(InpProtectType==enum_equity && InpRiskType==enum_currency){
      trigger_close = equity-InpAmount;
   }   
   if(InpProtectType==enum_equity && InpRiskType==enum_perc){
      trigger_close = equity-(equity/100*InpAmount);
   } 
   
//---

   if(InpProtectType==enum_equityMax && InpRiskType==enum_currency){
   trigger_close = InpAmount;
   }   
   if(InpProtectType==enum_equityMax && InpRiskType==enum_perc){
      trigger_close = equity/100*InpAmount;
   } 

//---

   if(InpProtectType==enum_startBalMax && InpRiskType==enum_currency){
      trigger_close = InpAmount;
   }   
   if(InpProtectType==enum_startBalMax && InpRiskType==enum_perc){
      trigger_close = start_balance/100*InpAmount;
   }    
   
   
               
}


//===CLOSE ALL OPEN TRADES =======================================================================//

void closeTrades(){
   int total = PositionsTotal();
   for(int i=0; i<total; i++){
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0){Print("Failed to get position ticket.");}
      trade.PositionClose(ticket);      
   }
}

void closeLosingTrades(){
   int total = PositionsTotal();
   for(int i=0; i<total; i++){
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0){Print("Failed to get position ticket.");}
      double posProf = PositionGetDouble(POSITION_PROFIT);
      if(posProf<0){
         trade.PositionClose(ticket);
      }          
   }
}
