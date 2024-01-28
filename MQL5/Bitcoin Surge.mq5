//+------------------------------------------------------------------+
//|                                             Bitcoin Surge EA.mq5 |
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
   ENUM_FIXED, //Fixed Lot
   ENUM_PERC   //%Risk
};

enum orderType{
   ENUM_STOP,  //Stop Orders
   ENUM_LIMIT  //Limit Orders
};



//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

input long        InpMagicNumber    =     012450;     //Magic Number
input orderType   InpOrderType      =     ENUM_STOP;  //Order Type
input lotType     InpLotType        =     ENUM_PERC;  //Lot Type
input double      InpLotSize        =     0.01;       //Fixed Lot Size
input double      InpRisk           =     1.00;       //Risk Percentage
input int         InpTakeProfit     =     9500;       //Take Profit (in points)
input int         InpStopLoss       =     3500;       //Stop Loss (in points)
input int         InpPointDist      =     0;          //Points Order Distance
input int         InpBreakeven      =     2000;       //Points to Break Even
input int         InpTSLStart       =     0;          //Trailing Stop Start
input int         InpTSLDistance    =     0;          //Trailing Stop Distance
input string      InpTradeComment   =     "Bitcoin Surge EA";         //Trade Comment

input group       "Trade Days"
input bool        InpTradeMon       =     true;       //Monday
input bool        InpTradeTue       =     true;       //Tuesday
input bool        InpTradeWed       =     true;       //Wednesday
input bool        InpTradeThu       =     true;       //Thursday
input bool        InpTradeFri       =     true;       //Friday
input bool        InpTradeSat       =     true;       //Sturday
input bool        InpTradeSun       =     true;       //Sunday



//input string      InpStartTime      =     "06:00";    //Trading Start Time (00:00)
//input string      InpEndTime        =     "18:00";    //Trading End Time (00:00)



//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

MqlTick     currentTick;
MqlDateTime day_Today;
datetime    openTimeBuy    =  0;
datetime    openTimeSell   =  0;
int         barsTotal;
ulong       posTicket;
int         Inp_StopLoss, Inp_TakeProfit, Inp_Breakeven;

double      surgeBuyLow, surgeBuyUp, surgeBuyMid;
double      surgeSellLow, surgeSellUp, surgeSellMid;
double      surgeZoneSize;

//double      percentSL      =  InpStopLoss * _Point;


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

   
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   

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

   if(!SymbolInfoTick(_Symbol,currentTick)){
      Print("Failed to get current tick...");
      return;
   }
   
   //Comment("today.day_of_week: ",day_Today.day_of_week,"\nEnumToString: ",EnumToString((ENUM_DAY_OF_WEEK)day_Today.day_of_week));
      
//---Time Filter settings-----

//      datetime timeStart   =  StringToTime(InpStartTime);
//      datetime timeEnd     =  StringToTime(InpEndTime);
//      
//      bool isTime = TimeCurrent() >= timeStart && TimeCurrent() < timeEnd;
      
      //Comment("Time start input: ",InpStartTime,"\nTime start datetime: ",timeStart,
      //         "\nTime end input: ",InpEndTime,"\nTime end datetime: ",timeEnd,"\nTime Filter: ",isTime);
   
//---

   int digitsTotal = Digits();
   
   if(digitsTotal == 3){
      Inp_StopLoss = InpStopLoss * 10;
      Inp_TakeProfit = InpTakeProfit * 10;
      Inp_Breakeven = InpBreakeven * 10;
      surgeZoneSize = 30000;
   }
   
   if(digitsTotal == 2){
      Inp_StopLoss = InpStopLoss;
      Inp_TakeProfit = InpTakeProfit;
      Inp_Breakeven = InpBreakeven;
      surgeZoneSize = 3000;
   }
   
   if(digitsTotal == 1){
      Inp_StopLoss = InpStopLoss / 10;
      Inp_TakeProfit = InpTakeProfit / 10;
      Inp_Breakeven = InpBreakeven / 10;
      surgeZoneSize = 300;
   }
   
   double slDistance = Inp_StopLoss * _Point;



//---

   
   //Getting high and low price of previous daily candle
   double high = iHigh(_Symbol,PERIOD_D1,1);
   double low  = iLow(_Symbol,PERIOD_D1,1);
         
   
   //setting value of lots depending on fixed or risk        
   double lots;
   if(InpLotType == ENUM_PERC){
      lots = calcLots(InpRisk,slDistance);
   }
   else{
      lots = InpLotSize;
   }
         
   
   //setting the price for pending order         
   double buyStop = high + InpPointDist*_Point;
   double sellStop = low - InpPointDist*_Point;
         
   //counting open positions for max positions
   int posBuy, posSell;
   CountOpenPositions(posBuy,posSell);
   
   //couting current orders
   int ordBuy, ordSell;
   CountOrders(ordBuy,ordSell);
   
   datetime zoneEnd = TimeCurrent()+PeriodSeconds(PERIOD_D1);
   
//---

   //long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   //Comment("Account Leverage is 1:",leverage,"\nLot Size: ",lots,"\nBuyStop level: ",buyStop,"\nSellStop level: ",sellStop);   

//---
   
   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars; 
      
   
         //Sell SL and TP
      double sellSL = InpStopLoss==0 ? 0 : sellStop + Inp_StopLoss * _Point;
      double sellTP = InpTakeProfit==0 ? 0 : sellStop - Inp_TakeProfit * _Point;
   
         //Buy SL and TP
      double buySL = InpStopLoss==0 ? 0 : buyStop - Inp_StopLoss * _Point;
      double buyTP = InpTakeProfit==0 ? 0 : buyStop + Inp_TakeProfit * _Point;
      

      
      surgeBuyMid = buyStop - (surgeZoneSize*_Point/2);
      surgeBuyLow = surgeBuyMid - surgeZoneSize*_Point;
      surgeBuyUp = buyStop + (surgeZoneSize*_Point/2);

      surgeSellLow = sellStop - (surgeZoneSize*_Point/2);
      surgeSellMid = sellStop + (surgeZoneSize*_Point/2);
      surgeSellUp = surgeSellMid + surgeZoneSize*_Point; 
      

//***IF currentDay != noTradeDay

   
      if(!haveTradedToday()){      
         if(InpOrderType==ENUM_STOP){
            //Buy Stop
            if(posBuy < 1 && ordBuy < 1){
               trade.BuyStop(lots,buyStop,_Symbol,buySL,buyTP,ORDER_TIME_DAY,0,InpTradeComment); 
               
               //BUY SURGE ZONES
               ObjectCreate(0,"Surge Buy Zone",OBJ_RECTANGLE,0,TimeCurrent(),surgeBuyUp,zoneEnd,surgeBuyLow);
               ObjectSetInteger(0,"Surge Buy Zone",OBJPROP_COLOR,clrAqua);
               ObjectSetInteger(0,"Surge Buy Zone",OBJPROP_STYLE,STYLE_DASH);
                             
            }
             
                     
            //Sell Stop
            if(posSell < 1 && ordSell < 1){
               trade.SellStop(lots,sellStop,_Symbol,sellSL,sellTP,ORDER_TIME_DAY,0,InpTradeComment);
               
               //SELL SURGE ZONE
               ObjectCreate(0,"Surge Sell Zone",OBJ_RECTANGLE,0,TimeCurrent(),surgeSellLow,zoneEnd,surgeSellUp);
               ObjectSetInteger(0,"Surge Sell Zone",OBJPROP_COLOR,clrAqua);
               ObjectSetInteger(0,"Surge Sell Zone",OBJPROP_STYLE,STYLE_DASH);     
            }
         }
         
         if(InpOrderType==ENUM_LIMIT){

            double sellLimitSL = InpStopLoss==0 ? 0 : buyStop + InpStopLoss * _Point;
            double sellLimitTP = InpTakeProfit==0 ? 0 : buyStop - InpTakeProfit * _Point;         

            double buyLimitSL = InpStopLoss==0 ? 0 : sellStop - InpStopLoss * _Point;
            double buyLimitTP = InpTakeProfit==0 ? 0 : sellStop + InpTakeProfit * _Point; 
               
                        
            //Sell Limit
            if(posSell < 1 && ordSell < 1){
               trade.SellLimit(lots,buyStop,_Symbol,sellLimitSL,sellLimitTP,ORDER_TIME_DAY,0,InpTradeComment);
            }
            
            //Buy Limit
            if(posBuy < 1 && ordBuy < 1){
               trade.BuyLimit(lots,sellStop,_Symbol,buyLimitSL,buyLimitTP,ORDER_TIME_DAY,0,InpTradeComment);
            }
         }            
      }         
   }
   

   //Get ask and bid price
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);


   //---Moving-SL-to-Breakeven----------   
   checkBreakEvenStopBuy(ask);
   checkBreakEvenStopSell(bid);     
   
   
   //---Trailing-Stop-Check-------------
   checkTrailingSLBuy(ask);
   checkTrailingSLSell(bid);
   
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




//---Count-Open-Positions-------------------------------+
 
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




//---Count total orders---------------------------------+
 
bool CountOrders(int &ordBuy, int &ordSell){
   
   ordBuy   = 0;
   ordSell  = 0;
   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--){
      ulong ticket = OrderGetTicket(i);
      if(ticket <= 0){
         Print("Failed to get position ticket.");
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
         if(type == ORDER_TYPE_BUY_STOP || ORDER_TYPE_BUY_LIMIT){ordBuy++;}
         if(type == ORDER_TYPE_SELL_STOP || ORDER_TYPE_SELL_LIMIT){ordSell++;}
      }
   }
   
   return true;
}




//---Check if one trade per day----------------------------+

bool haveTradedToday(){
   MqlDateTime today;
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




//---Breakeven-BUY-function---------------------------+

void checkBreakEvenStopBuy(double ask){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL > openPrice - Inp_StopLoss*_Point){
         return;
      }
      
      else if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         //double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double BEbuyTP = InpTakeProfit == 0 ? 0 : openPrice + Inp_TakeProfit * _Point;
         if(ask > (openPrice + Inp_Breakeven * _Point)){
            trade.PositionModify(positionTicket,openPrice,BEbuyTP);   
         }
      }
   }
}




//---Breakeven-SELL-function------------------------------+

void checkBreakEvenStopSell(double bid){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL < openPrice + Inp_StopLoss*_Point){
         return;
      }
      
      else if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         //double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double BEsellTP = InpTakeProfit == 0 ? 0 : openPrice - Inp_TakeProfit * _Point;
         if(bid < (openPrice - Inp_Breakeven * _Point)){
            trade.PositionModify(positionTicket,openPrice,BEsellTP);   
         }
      }
   }
}




//------Trailing-Stop-Function------------------------------------+

void  checkTrailingSLBuy(double ask){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      
      if(InpTSLStart==0){
         return;
      }
      
      if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC);
         double tsl = openPrice + InpTSLDistance*_Point;
         double tsltp = InpTakeProfit == 0 ? 0 : openPrice + InpTakeProfit * _Point;
         
         if(magic==InpMagicNumber && type==POSITION_TYPE_BUY && currentTick.ask==openPrice + InpTSLStart*_Point){
            trade.PositionModify(positionTicket,tsl,tsltp);
            openPrice = openPrice + tsl;
         }
      }   
   }                     
}

void checkTrailingSLSell(double bid){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      
      if(InpTSLStart==0){
         return;
      }
      
      if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         long magic = PositionGetInteger(POSITION_MAGIC);
         double tsl = openPrice - InpTSLDistance*_Point;
         double tsltp = InpTakeProfit == 0 ? 0 : openPrice - InpTakeProfit * _Point;
         
         if(magic==InpMagicNumber && type==POSITION_TYPE_SELL && currentTick.bid==openPrice - InpTSLStart*_Point){
            trade.PositionModify(positionTicket,tsl,tsltp);
            openPrice = openPrice - tsl;
         }
      }   
   }
}




//---Current-Day-Function----------------------
