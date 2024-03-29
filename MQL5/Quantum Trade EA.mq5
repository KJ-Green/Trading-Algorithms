//+------------------------------------------------------------------+
//|                                             Quantum Trade EA.mq5 |
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

bool ChartVolumesColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_VOLUME,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }
   return(true); 
}

bool ChartAskLineColorSet(const color clr,const long chart_ID=0){ 
//--- reset the error value 
   ResetLastError(); 
//--- set the color of bearish candlestick's body 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_ASK,clr)){ 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
   }
   return(true); 
}




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

input int         InpMagicNumber       = 303909;       //Magic Number
input string      InpStartHour         = "03:00";     //Range Start Time
input string      InpEndHour           = "11:00";     //Range End Time 
input int         InpRangePoints       = 10;          //Points Outside Range
input bool        InpOCO               = true;        //Cancel Other Order
input string      InpClosePending      = "21:30";     //Close Pending Orders Time

input group       "TRADE SETTINGS"
input bool        InpAutoLot           = true;        //Use Auto Lot
input double      InpLotSize           = 0.01;        //Lot Size
input int         InpLotsPer           = 1000;        //Auto Lot - Lot Size Per:
input bool        InpUsePercentage     = false;       //Use Percentage Based Risk
input double      InpRiskPerc          = 5;           //Risk Percentage
//input riskLevel   InpRiskLevel         = ENUM_MEDIUM; //Risk Level
input int         InpTakeProfit        = 100;          //Take Profit (pips)
input int         InpStopLoss          = 100;          //Stop Loss (pips)
input int         InpTrailingStart     = 10;          //Trailing Stop Start (pips)
input int         InpTrailingStep      = 2;           //Trailing Stop Step From Price (pips)
input int         InpMaxPositions      = 1;           //Max Open Positions  

input group       "RECOVERY SETTINGS"
input bool        InpUseRecovery       = true;        //Use Recovery Mode
input double      InpRecoveryMulti     = 3;           //Recovery Lot Multiplier
input int         InpRecoveryTimes     = 1;           //Number of Recovery Trades 

input group       "DAY SETTINGS"     
input bool        InpStopFriday        = true;        //Disable Trading on Friday
input bool        InpStopNFP           = false;       //Disable Trading for NFP Friday



//+------------------------------------------------------------------+
//| global variables                                                                
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

double      range_top, range_Bottom;
double      buySL, sellSL, buyTP, sellTP, buyTS, buyTS_TP, sellTS, sellTS_TP, slSize, tpSize, lotSize, original_lotSize;
double      buyTS_level, sellTS_level;
double      autoLot_multi, acc_balance;
double      tp_points, sl_points, ts_startPoints, ts_stepPoints, percSL_size;
double      currentTrade_openPrice, currentBuy_openPrice, currentSell_openPrice;
double      trade_profit, trade_closePrice, acc_profit;;

datetime    dayStart, rangeStart, rangeEnd, rangeLength, rangeCheck, pendingClose, next_dayStart;
string      str_dayStart;
int         barsTotal;
int         range_count, today_sells, today_buys;
int         tradeLoss, recTrades, trade_closed, obj_name_count, obj_clr;
string      obj_name, trade_profit_string, acc_profit_string, currency_symbol;
long        trade_closeTime;
int         label_x, label_y;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   trade.SetExpertMagicNumber(InpMagicNumber);   
   
   barsTotal = iBars(_Symbol,PERIOD_D1);
   
   obj_name_count = 0;
   
   ChartBackColorSet(clrBlack,0);
   ChartForeColorSet(clrLime,0); //clrDarkGreen
   ChartGridColorSet(clrBlack,0);     //C'36,43,49'
   ChartUpColorSet(clrForestGreen,0);
   ChartDownColorSet(clrForestGreen,0);
   ChartBullColorSet(clrBlack,0);
   ChartBearColorSet(clrBlack,0);
   ChartVolumesColorSet(clrSpringGreen,0);
   ChartAskLineColorSet(clrSpringGreen,0);
   ChartSetInteger(0,CHART_SHOW_VOLUMES,1);
   
   if(accountInfo.Currency()=="USD"){currency_symbol="$";}
   if(accountInfo.Currency()=="GBP"){currency_symbol="£";}
   if(accountInfo.Currency()=="EUR"){currency_symbol="€";}         

   
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

   if(!SymbolInfoTick(_Symbol,currentTick)){Alert("Failed to get current tick.");return;}
   
//---
   //Comment("obj_name_count: ",obj_name_count,"\nobj_name_string: ",obj_name,"\ntrade_closed: ",trade_closed,"\ntrade_profit: ",trade_profit,"\ntrade_closetime: ",trade_closeTime,
   //         "\ntrade_closeprice: ",trade_closePrice,"\nlabel_x: ",label_x,"\nlabel_y: ",label_y);

   //counting open positions for max positions
   int posBuy, posSell;
   CountOpenPositions(posBuy,posSell);
   
   //couting current orders
   int ordBuy, ordSell;
   CountOrders(ordBuy,ordSell);
 
   if(InpOCO==true){
      if(posBuy>0 && ordSell>0){
         deletePendingOrder();
      }
      if(posSell>0 && ordBuy>0){
         deletePendingOrder();
         trade_closed=0;
      }      
   }
   

   
   acc_profit = accountInfo.Profit();
   acc_profit_string = DoubleToString(acc_profit,2);
   
   if(trade_closed==1){
      if(trade_profit>0){obj_clr=clrLime;}
      if(trade_profit<0){obj_clr=clrRed;}
      ObjectCreate(0,obj_name,OBJ_TEXT,0,trade_closeTime,trade_closePrice);
      //ObjectSetInteger(0,obj_name,OBJPROP_XDISTANCE,label_x);
      //ObjectSetInteger(0,obj_name,OBJPROP_YDISTANCE,label_y);
      ObjectSetInteger(0,obj_name,OBJPROP_FONTSIZE,10);
      ObjectSetString(0,obj_name,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_name,OBJPROP_COLOR,obj_clr);
      ObjectSetString(0,obj_name,OBJPROP_TEXT,currency_symbol + trade_profit_string);
      
      trade_closed=0;   
   }
   
   ObjectCreate(0,"total_profit",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"total_profit",OBJPROP_XDISTANCE,11);
   ObjectSetInteger(0,"total_profit",OBJPROP_YDISTANCE,80);
   ObjectSetString(0,"total_profit",OBJPROP_TEXT,"{ 8bit breakout bot; }"); //"total profit" + acc_profit_string
   ObjectSetInteger(0,"total_profit",OBJPROP_FONTSIZE,10);
   ObjectSetString(0,"total_profit",OBJPROP_FONT,"Terminal");
   ObjectSetInteger(0,"total_profit",OBJPROP_COLOR,clrLime);       
   
   int bars = iBars(_Symbol,PERIOD_D1);
   if(barsTotal != bars){
      barsTotal = bars;
      today_buys=0;
      today_sells=0;
   }


   if(ordBuy==0 && posBuy==0){buyTS_level=0;}
   if(ordSell==0 && posSell==0){sellTS_level=0;}
   if(recTrades==InpRecoveryTimes){recTrades=0; tradeLoss=0;}     

   tp_points = InpTakeProfit*10*_Point;
   sl_points = InpStopLoss*10*_Point;
   ts_startPoints = InpTrailingStart*10*_Point;
   ts_stepPoints = InpTrailingStep*10*_Point;
   percSL_size = InpStopLoss*10;   
   
//---

   dayStart = iTime(_Symbol,PERIOD_D1,0);
   next_dayStart = dayStart + PeriodSeconds(PERIOD_D1);
   str_dayStart = TimeToString(dayStart,TIME_DATE);
   rangeStart = StringToTime(InpStartHour);
   rangeEnd = StringToTime(InpEndHour);
   rangeLength = rangeEnd - rangeStart; 
   pendingClose = StringToTime(InpClosePending); 
   
   string str_lengthHour = TimeToString(rangeLength,TIME_MINUTES);
   int index_length = StringToInteger(str_lengthHour) + 1;
   
   range_top = iHigh(_Symbol,PERIOD_H1,iHighest(_Symbol,PERIOD_H1,MODE_HIGH,index_length,1));
   range_Bottom = iLow(_Symbol,PERIOD_H1,iLowest(_Symbol,PERIOD_H1,MODE_LOW,index_length,1));
   
   if(TimeCurrent() > rangeEnd && range_count == 0){
      range_count = 1;
   }
   if(TimeCurrent() > pendingClose){
      range_count = 0;
   }
   

   //Comment("trade loss: ",tradeLoss,"\n\nInpRecoveryTimes: ",InpRecoveryTimes,"\n\nrecTrades: ",recTrades,"\n\noriginal_lotSize: ",original_lotSize,"\n\nlotSize: ",lotSize);
   
//=== LOT SIZE =======================================================================================//

   if(InpUsePercentage==false){
      if(InpAutoLot==false){lotSize = InpLotSize;}
      
      if(InpAutoLot==true){
         autoLot_multi = accountInfo.Balance()/InpLotsPer;
         lotSize = NormalizeDouble(InpLotSize*autoLot_multi,2);
      }
      original_lotSize=lotSize;
   }
   
   if(InpUsePercentage==true){
      lotSize = calcLots(InpRiskPerc,sl_points);
      original_lotSize=lotSize;      
   }
   
   //Recovery Lot Size
   if(tradeLoss==1 && recTrades==0){lotSize = NormalizeDouble(lotSize*InpRecoveryMulti,2);}
   
   if(recTrades>0 && InpRecoveryTimes > 1){
      if(recTrades < InpRecoveryTimes){
         lotSize = NormalizeDouble(original_lotSize*InpRecoveryMulti,2);   
      }
   }     
   
   //Comment("LotSize: ",lotSize);     
   

//=== Setting Pending Orders ==========================================================================================================//

   if(posBuy==0 && posSell==0){

      //BUYS
      if(ordBuy<InpMaxPositions){ //ordBuy==0
         if(!haveTradedToday() && TimeCurrent() > rangeEnd){
            //sl 2500 points
            buySL = range_top - sl_points;
            buyTP = range_top + tp_points;
            trade.BuyStop(lotSize,range_top,_Symbol,buySL,buyTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
            buyTS_level = NormalizeDouble(range_top + ts_startPoints,_Digits);
         }
      }    
      
      if(ordSell<InpMaxPositions){
         if(!haveTradedToday() && TimeCurrent() > rangeEnd){
            sellSL = range_Bottom + sl_points;
            sellTP = range_Bottom - tp_points;
            trade.SellStop(lotSize,range_Bottom,_Symbol,sellSL,sellTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
            sellTS_level = NormalizeDouble(range_Bottom - ts_startPoints,_Digits);
         }
      }        
   }
 

  
//=== TRAILING STOP ==================================================================================================================//  

   double Ask;
   Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK,Ask);
   if(posBuy>0){
      checkTrailingSLBuy(Ask);
                                       
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
 

//=== GET OPEN PRICE OF CURRENT POSITION =============================================================================================//

   if(posBuy > 0 || posSell > 0){
      int total = PositionsTotal();
      for(int i=total-1; i>=0; i--){
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket)){
            Print("Failed to select position.");
         }
         long magic;
         if(!PositionGetInteger(POSITION_MAGIC,magic)){
            Print("Failed to get position magic number.");
         }
         double openPrice;
         if(!PositionGetDouble(POSITION_PRICE_OPEN,openPrice)){
            Print("Failed to get current position open price.");
         }
         long posType = PositionGetInteger(POSITION_TYPE);
         //if(!PositionGetInteger(POSITION_TYPE,posType)){
         //   Print("Failed to get current position type.");
         //}
         if(magic==InpMagicNumber && posType==POSITION_TYPE_BUY){
            currentBuy_openPrice = openPrice;
         }
         if(magic==InpMagicNumber && posType==POSITION_TYPE_SELL){
            currentSell_openPrice = openPrice;
         }         
      }                 
   }  
   
   //Comment("buy price: ",currentBuy_openPrice,"\nsell price: ",currentSell_openPrice);
   
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Custom Functions                                                                
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
         buyTS = NormalizeDouble(buyTS_level - ts_stepPoints,_Digits);
         if(buyTS > currentTick.bid){
            buyTS = NormalizeDouble(currentTick.bid - ts_stepPoints,_Digits);
         }
         buyTS_TP = openPrice + tp_points;


         if(magic==InpMagicNumber && type==POSITION_TYPE_BUY && currentTick.ask>=buyTS_level){
            trade.PositionModify(positionTicket,buyTS,buyTS_TP); 
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
         double pos_SL = PositionGetDouble(POSITION_SL);
         sellTS = NormalizeDouble(sellTS_level + ts_stepPoints,_Digits);
         if(sellTS < currentTick.ask){
            sellTS = NormalizeDouble(currentTick.ask + ts_stepPoints,_Digits);
         }
         sellTS_TP = openPrice - tp_points;
  

         if(magic==InpMagicNumber && type==POSITION_TYPE_SELL && currentTick.bid<=sellTS_level){
            trade.PositionModify(positionTicket,sellTS,sellTS_TP);
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
      
      double price_buffer = 200*_Point;
      double sl_buffer_sell = currentSell_openPrice + price_buffer;
      double sl_buffer_buy = currentBuy_openPrice - price_buffer;
      
      if(deal_profit<0 && deal_magic==InpMagicNumber){
         if(deal_entry==DEAL_ENTRY_OUT && deal_type==DEAL_TYPE_BUY){
            if(deal_price > sl_buffer_sell){
               tradeLoss=1;
            }
         }    
         if(deal_entry==DEAL_ENTRY_OUT && deal_type==DEAL_TYPE_SELL){
            if(deal_price < sl_buffer_buy){
               tradeLoss=1;
            }
         }    
         original_lotSize = deal_volume;
      }
      if(deal_profit>0 && deal_magic==InpMagicNumber){
         tradeLoss=0;
      }
      if(deal_entry==DEAL_ENTRY_OUT && deal_volume > original_lotSize){
         recTrades++;   
      }
      if(deal_entry==DEAL_ENTRY_OUT){
         trade_profit = deal_profit;
         trade_closePrice = deal_price;
         trade_closeTime = deal_time;
         trade_closed = 1;
         obj_name_count++;
         obj_name = IntegerToString(obj_name_count,0);
         trade_profit_string = DoubleToString(trade_profit,2);
         ChartTimePriceToXY(0,0,trade_closeTime,trade_closePrice,label_x,label_y);  
      }   
   }   
}