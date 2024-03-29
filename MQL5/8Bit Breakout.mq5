//+------------------------------------------------------------------+
//|                                                8Bit Breakout.mq5 |
//|                              Copyright 2023, Shogun Trading Ltd. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Shogun Trading Ltd."
#property link      "info.shoguntrading@gmail.com"
#property version   "1.10"

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
#include <Arrays\ArrayString.mqh>
CArrayString ArrayString;



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
input bool        InpUsePartials       = false;       //Close Partials in Drawdown
input int         InpPartialsPerc      = 50;          //Percent of Position to close
input int         InpPatrialsTrigger   = 50;          //Percentage of SL to Trigger Partials 

input group       "DAY SETTINGS"     
input bool        InpStopFriday        = true;        //Disable Trading on Friday
input bool        InpStopNFP           = false;       //Disable Trading for NFP Friday

input group       "HIGH IMPACT NEWS SETTINGS" 
input bool        InpNewsMode          = false;       //Use News Mode (Prop Firms)     
input int         InpStopMin           = 10;          //Pause EA Minutes Before News
input int         InpResumeMin         = 10;          //Resume EA Minutes After News

input group       "MISC SETTING"
input bool        InpShowPanel         = true;        //Show Info Panel
input int         InpFontSize          = 8;           //Font Size


//+------------------------------------------------------------------+
//| global variables                                                                
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

double      range_top, range_Bottom;
double      buySL, sellSL, buyTP, sellTP, buyTS, buyTS_TP, sellTS, sellTS_TP, slSize, tpSize, lotSize, original_lotSize, symbol_maxLots, max_start_vol;
double      buyTS_level, sellTS_level;
double      autoLot_multi, acc_balance;
double      tp_points, sl_points, ts_startPoints, ts_stepPoints, percSL_size;
double      currentTrade_openPrice, currentBuy_openPrice, currentSell_openPrice;
double      trade_profit, trade_closePrice, acc_profit, partials_trigger, partials_points;
double      ea_profit, daily_return_perc, weekly_return_perc, monthly_return_perc, total_return_perc, balance_onePerc, win_rate;
string      ea_profit_string, daily_return_String, weekly_return_String, monthly_return_string, total_return_string, lots_String, win_rate_string, win_loss_string;
double      total_trades_count, total_win_count, total_loss_count, start_balance, month_start_balance, weekly_start_balance;

datetime    dayStart, rangeStart, rangeEnd, rangeLength, rangeCheck, pendingClose, next_dayStart;
string      str_dayStart;
int         barsTotal, w_barsTotal, m_barsTotal;
int         range_count, today_sells, today_buys, partials_count, news_count, high_impact_count, total_high_impact=-1;
int         tradeLoss, recTrades, trade_closed, obj_name_count, obj_clr;
string      obj_name, trade_profit_string, acc_profit_string, currency_symbol;
long        trade_closeTime;

bool        in_recovery=false;

//=== NEWS MODE VARIABLES =================================
string   strtodaydate, strtimenow, strEventTime, strStopTime, strResumeTime, newsTime; 
datetime eventTime, stopTime, resumeTime;
string   news_list[], news_copy[], news_time[], time_copy[];
 


//=== OBJECT NAMES STRING VARIABLES =======================
string      ea_title="ea_title", title_border="title_border",background="background", background_Edge="background_edge";
string      top_div="top_dive", obj_ea_prof="ea_prof", d_return="d_return", w_return="w_return", m_return="m_return", t_return="t_return", obj_lotsize="lotsize";
string      bottom_div="bottom_div", obj_inrec="in_recovery", ea_prof_return="ea_prof_return", d_perc="d_perc", w_perc="w_perc", m_perc="m_perc", t_perc="t_perc", obj_lots_return="lots_return";
string      obj_inrec_string="inrec_string", obj_inrec_lots="inrec_lots", obj_lots_return_rec="lots_return_rec", obj_win_rate="win_rate", obj_win_loss="win_loss";
string      obj_rec_div="rec_div"; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   trade.SetExpertMagicNumber(InpMagicNumber);   
   
   barsTotal = iBars(_Symbol,PERIOD_D1);
   w_barsTotal = iBars(_Symbol,PERIOD_W1);
   m_barsTotal = iBars(_Symbol,PERIOD_MN1);
   
   obj_name_count = 0;
   start_balance = accountInfo.Balance();
   
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
   if(accountInfo.Currency()=="JPY"){currency_symbol="¥";}            
   if(accountInfo.Currency()=="CHF"){currency_symbol="₣";}

   if(InpShowPanel==true){
      //background border
      ObjectCreate(0,background_Edge,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,background_Edge,OBJPROP_XDISTANCE,18);
      ObjectSetInteger(0,background_Edge,OBJPROP_YDISTANCE,48);
      ObjectSetInteger(0,background_Edge,OBJPROP_XSIZE,402);
      ObjectSetInteger(0,background_Edge,OBJPROP_YSIZE,462);
      ObjectSetInteger(0,background_Edge,OBJPROP_BGCOLOR,clrLime);
      //ObjectSetInteger(0,background_Edge,OBJPROP_BACK,true);
      ObjectSetInteger(0,background_Edge,OBJPROP_BORDER_TYPE,BORDER_FLAT); 
 
      //background
      ObjectCreate(0,background,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,background,OBJPROP_XDISTANCE,20);
      ObjectSetInteger(0,background,OBJPROP_YDISTANCE,50);
      ObjectSetInteger(0,background,OBJPROP_XSIZE,400);
      ObjectSetInteger(0,background,OBJPROP_YSIZE,460);
      ObjectSetInteger(0,background,OBJPROP_BGCOLOR,C'0,19,0');
      ObjectSetInteger(0,background,OBJPROP_BORDER_TYPE,BORDER_FLAT);    
        
      //main ea text
      ObjectCreate(0,ea_title,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,ea_title,OBJPROP_XDISTANCE,50);//110
      ObjectSetInteger(0,ea_title,OBJPROP_YDISTANCE,75);
      ObjectSetString(0,ea_title,OBJPROP_TEXT,"{ 8bit breakout bot; }  |  v1.0");
      ObjectSetInteger(0,ea_title,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,ea_title,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,ea_title,OBJPROP_COLOR,clrLime);
      //top divider
      ObjectCreate(0,top_div,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,top_div,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,top_div,OBJPROP_YDISTANCE,120);
      ObjectSetInteger(0,top_div,OBJPROP_XSIZE,350);
      ObjectSetInteger(0,top_div,OBJPROP_YSIZE,1);
      ObjectSetInteger(0,top_div,OBJPROP_BGCOLOR,clrNONE);
      ObjectSetInteger(0,top_div,OBJPROP_COLOR,clrDarkSlateGray);
      ObjectSetInteger(0,top_div,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      //ea profit
      ObjectCreate(0,obj_ea_prof,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,obj_ea_prof,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,obj_ea_prof,OBJPROP_YDISTANCE,140);
      ObjectSetString(0,obj_ea_prof,OBJPROP_TEXT,"ea profit:");
      ObjectSetInteger(0,obj_ea_prof,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,obj_ea_prof,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_ea_prof,OBJPROP_COLOR,clrLime);  
      //daily return
      ObjectCreate(0,d_return,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,d_return,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,d_return,OBJPROP_YDISTANCE,190);
      ObjectSetString(0,d_return,OBJPROP_TEXT,"daily return:");
      ObjectSetInteger(0,d_return,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,d_return,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,d_return,OBJPROP_COLOR,clrLime);
      //weekly return
      ObjectCreate(0,w_return,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,w_return,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,w_return,OBJPROP_YDISTANCE,240);
      ObjectSetString(0,w_return,OBJPROP_TEXT,"weekly return:");
      ObjectSetInteger(0,w_return,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,w_return,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,w_return,OBJPROP_COLOR,clrLime);  
      //monthly return
      ObjectCreate(0,m_return,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,m_return,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,m_return,OBJPROP_YDISTANCE,290);
      ObjectSetString(0,m_return,OBJPROP_TEXT,"monthly return:");
      ObjectSetInteger(0,m_return,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,m_return,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,m_return,OBJPROP_COLOR,clrLime);
      //total return
      ObjectCreate(0,t_return,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,t_return,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,t_return,OBJPROP_YDISTANCE,340);
      ObjectSetString(0,t_return,OBJPROP_TEXT,"total return:");
      ObjectSetInteger(0,t_return,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,t_return,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,t_return,OBJPROP_COLOR,clrLime);
      //lot size
      ObjectCreate(0,obj_lotsize,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,obj_lotsize,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,obj_lotsize,OBJPROP_YDISTANCE,390);
      ObjectSetString(0,obj_lotsize,OBJPROP_TEXT,"lot size:");
      ObjectSetInteger(0,obj_lotsize,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,obj_lotsize,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_lotsize,OBJPROP_COLOR,clrLime);      
      //bottom divider
      ObjectCreate(0,bottom_div,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,bottom_div,OBJPROP_XDISTANCE,45);
      ObjectSetInteger(0,bottom_div,OBJPROP_YDISTANCE,440);
      ObjectSetInteger(0,bottom_div,OBJPROP_XSIZE,350);
      ObjectSetInteger(0,bottom_div,OBJPROP_YSIZE,1);
      ObjectSetInteger(0,bottom_div,OBJPROP_BGCOLOR,clrNONE);
      ObjectSetInteger(0,bottom_div,OBJPROP_COLOR,clrDarkSlateGray);
      ObjectSetInteger(0,bottom_div,OBJPROP_BORDER_TYPE,BORDER_FLAT);                                           
   }

   
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
//=== NEWS READ FROM CALENDAR ===============================================================================//
//---   
   CArrayString array;
   //string nTime_Array[];

   string base_currency = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   string second_currency = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   datetime startTimeDay   = iTime(_Symbol,PERIOD_D1,0);
   datetime endTimeDay     = startTimeDay + PeriodSeconds(PERIOD_D1);
      
   MqlCalendarValue values[];   
   CalendarValueHistory(values,startTimeDay,endTimeDay,NULL,NULL);

//---

   for(int i = 0; i < ArraySize(values); i++){
      
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id,event);  
      
      MqlCalendarCountry country;
      CalendarCountryById(event.country_id,country);
      
      
      //if(StringFind(_Symbol,country.currency) < 0) continue;
      if(event.importance == CALENDAR_IMPORTANCE_NONE) continue;
      if(event.importance == CALENDAR_IMPORTANCE_LOW) continue;

      if((event.importance == CALENDAR_IMPORTANCE_MODERATE && high_impact_count>total_high_impact && country.currency==base_currency) ||
         (event.importance == CALENDAR_IMPORTANCE_HIGH && high_impact_count>total_high_impact && country.currency==base_currency) || 
         (event.importance == CALENDAR_IMPORTANCE_MODERATE && high_impact_count>total_high_impact && country.currency==second_currency) ||
         (event.importance == CALENDAR_IMPORTANCE_HIGH && high_impact_count>total_high_impact && country.currency==second_currency)){
         high_impact_count += 1;
         
         newsTime = TimeToString(values[i].time,TIME_MINUTES);
         
         array.Add(event.name);
         news_list[i]=array[i];

      }   

      strtodaydate  = TimeToString(TimeCurrent(),TIME_DATE);
      strtimenow    = TimeToString(TimeCurrent(),TIME_MINUTES);
      
      //f(event.name == InpNewsNameOne || event.name == InpNewsNameTwo){
         
      eventTime = values[i].time;
      stopTime = eventTime - InpStopMin * PeriodSeconds(PERIOD_M1);
      resumeTime = eventTime + InpResumeMin * PeriodSeconds(PERIOD_M1);
      
      strEventTime = TimeToString(values[i].time,TIME_MINUTES);
      strStopTime = TimeToString(stopTime,TIME_MINUTES);
      strResumeTime = TimeToString(resumeTime,TIME_MINUTES);
        
   }

   total_high_impact = high_impact_count;
   
      
   //Comment("total: ",total_high_impact,"\ncount: ",high_impact_count);
   //Comment("news_Time[0]: ",news_time[0],"\nnews_time[1]: ",news_time[1]);
   //Comment("news_list[0]: ",news_list[0],"\nnews_list[1]: ",news_list[1]);   
//---

   weekly_return_perc = NormalizeDouble(weekly_return_perc,2);
   monthly_return_perc = NormalizeDouble(monthly_return_perc,2);
   total_return_perc = NormalizeDouble(total_return_perc,2);         
   ea_profit = NormalizeDouble(ea_profit,2);
   if(total_trades_count>0){win_rate = NormalizeDouble(total_win_count/total_trades_count*100,2);}
   win_loss_string = "win/loss: " + DoubleToString(total_win_count,0) + "/" + DoubleToString(total_loss_count,0);
   symbol_maxLots = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);     
   max_start_vol = NormalizeDouble(symbol_maxLots/InpRecoveryMulti,2);

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
   balance_onePerc = accountInfo.Balance()/100;
   ea_profit_string = DoubleToString(ea_profit,2);
   daily_return_String = DoubleToString(daily_return_perc,2);
   weekly_return_String = DoubleToString(weekly_return_perc,2);
   monthly_return_string = DoubleToString(monthly_return_perc,2);
   total_return_string = DoubleToString(total_return_perc,2);
   lots_String = DoubleToString(lotSize,2);
   win_rate_string = DoubleToString(win_rate,2);
   
   
   
 
//=== PROFIT OBJECT CREATE =========================================================================================//   
   if(trade_closed==1){
      if(trade_profit>0){obj_clr=clrLime;}
      if(trade_profit<0){obj_clr=clrRed;}
      ObjectCreate(0,obj_name,OBJ_TEXT,0,trade_closeTime,trade_closePrice);
      ObjectSetInteger(0,obj_name,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,obj_name,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_name,OBJPROP_COLOR,obj_clr);
      ObjectSetString(0,obj_name,OBJPROP_TEXT,currency_symbol + trade_profit_string);
      
      trade_closed=0;   
   }
   
//=== GUI PANEL OBJECTS ============================================================================================//
   if(InpShowPanel==true){

      //ea profit
      ObjectCreate(0,ea_prof_return,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,ea_prof_return,OBJPROP_XDISTANCE,380);
      ObjectSetInteger(0,ea_prof_return,OBJPROP_YDISTANCE,140);
      ObjectSetString(0,ea_prof_return,OBJPROP_TEXT,currency_symbol + ea_profit_string);
      ObjectSetInteger(0,ea_prof_return,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,ea_prof_return,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,ea_prof_return,OBJPROP_COLOR,clrLime); 
      ObjectSetInteger(0,ea_prof_return,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);             
      //daily return
      ObjectCreate(0,d_perc,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,d_perc,OBJPROP_XDISTANCE,380);
      ObjectSetInteger(0,d_perc,OBJPROP_YDISTANCE,190);
      ObjectSetString(0,d_perc,OBJPROP_TEXT,daily_return_String+"%");
      ObjectSetInteger(0,d_perc,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,d_perc,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,d_perc,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,d_perc,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);       
      //weekly return
      ObjectCreate(0,w_perc,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,w_perc,OBJPROP_XDISTANCE,380);
      ObjectSetInteger(0,w_perc,OBJPROP_YDISTANCE,240);
      ObjectSetString(0,w_perc,OBJPROP_TEXT,weekly_return_String+"%");
      ObjectSetInteger(0,w_perc,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,w_perc,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,w_perc,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,w_perc,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);         
      //monthly return
      ObjectCreate(0,m_perc,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,m_perc,OBJPROP_XDISTANCE,380);
      ObjectSetInteger(0,m_perc,OBJPROP_YDISTANCE,290);
      ObjectSetString(0,m_perc,OBJPROP_TEXT,monthly_return_string+"%");
      ObjectSetInteger(0,m_perc,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,m_perc,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,m_perc,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,m_perc,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);       
      //total return
      ObjectCreate(0,t_perc,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,t_perc,OBJPROP_XDISTANCE,380);
      ObjectSetInteger(0,t_perc,OBJPROP_YDISTANCE,340);
      ObjectSetString(0,t_perc,OBJPROP_TEXT,total_return_string+"%");
      ObjectSetInteger(0,t_perc,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,t_perc,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,t_perc,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,t_perc,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);       
      //lot size
      ObjectCreate(0,obj_lots_return,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,obj_lots_return,OBJPROP_XDISTANCE,380);
      ObjectSetInteger(0,obj_lots_return,OBJPROP_YDISTANCE,390);
      ObjectSetString(0,obj_lots_return,OBJPROP_TEXT,lots_String);
      ObjectSetInteger(0,obj_lots_return,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,obj_lots_return,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_lots_return,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,obj_lots_return,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);       
      //win rate     
      ObjectCreate(0,obj_win_rate,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,obj_win_rate,OBJPROP_XDISTANCE,390);
      ObjectSetInteger(0,obj_win_rate,OBJPROP_YDISTANCE,460);
      ObjectSetString(0,obj_win_rate,OBJPROP_TEXT,"win rate: "+win_rate_string+"%");
      ObjectSetInteger(0,obj_win_rate,OBJPROP_FONTSIZE,8);
      ObjectSetString(0,obj_win_rate,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_win_rate,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,obj_win_rate,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      //wins/losses    
      ObjectCreate(0,obj_win_loss,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,obj_win_loss,OBJPROP_XDISTANCE,50);
      ObjectSetInteger(0,obj_win_loss,OBJPROP_YDISTANCE,460);
      ObjectSetString(0,obj_win_loss,OBJPROP_TEXT,win_loss_string);
      ObjectSetInteger(0,obj_win_loss,OBJPROP_FONTSIZE,8);
      ObjectSetString(0,obj_win_loss,OBJPROP_FONT,"Terminal");
      ObjectSetInteger(0,obj_win_loss,OBJPROP_COLOR,clrLime);
                    
        
      if(in_recovery==true){
         //ObjectDelete(0,obj_win_rate);
         //ObjectDelete(0,obj_win_loss);
         //move win stats lower
         ObjectSetInteger(0,obj_win_loss,OBJPROP_YDISTANCE,530);
         ObjectSetInteger(0,obj_win_rate,OBJPROP_YDISTANCE,530);
         //extend background object lower
         ObjectSetInteger(0,background_Edge,OBJPROP_YSIZE,522);
         ObjectSetInteger(0,background,OBJPROP_YSIZE,520);
         //in recovery rectangle
         ObjectCreate(0,obj_inrec,OBJ_RECTANGLE_LABEL,0,0,0);
         ObjectSetInteger(0,obj_inrec,OBJPROP_XDISTANCE,65);
         ObjectSetInteger(0,obj_inrec,OBJPROP_YDISTANCE,450);
         ObjectSetInteger(0,obj_inrec,OBJPROP_XSIZE,300);
         ObjectSetInteger(0,obj_inrec,OBJPROP_YSIZE,50);
         ObjectSetInteger(0,obj_inrec,OBJPROP_BGCOLOR,C'0,51,0');
         ObjectSetInteger(0,obj_inrec,OBJPROP_COLOR,clrDarkGreen);
         ObjectSetInteger(0,obj_inrec,OBJPROP_BORDER_TYPE,BORDER_FLAT);       
         //in recovery mode text
         ObjectCreate(0,obj_inrec_string,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,obj_inrec_string,OBJPROP_XDISTANCE,132);
         ObjectSetInteger(0,obj_inrec_string,OBJPROP_YDISTANCE,465);
         ObjectSetString(0,obj_inrec_string,OBJPROP_TEXT,"IN RECOVERY MODE");
         ObjectSetInteger(0,obj_inrec_string,OBJPROP_FONTSIZE,InpFontSize);
         ObjectSetString(0,obj_inrec_string,OBJPROP_FONT,"Terminal");
         ObjectSetInteger(0,obj_inrec_string,OBJPROP_COLOR,clrRed);          
         //in recovery lot size container
         ObjectCreate(0,obj_inrec_lots,OBJ_RECTANGLE_LABEL,0,0,0);
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_XDISTANCE,330);
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_YDISTANCE,382);
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_XSIZE,60);
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_YSIZE,40);
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_BGCOLOR,C'0,51,0');
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_COLOR,clrDarkGreen);
         ObjectSetInteger(0,obj_inrec_lots,OBJPROP_BORDER_TYPE,BORDER_FLAT);         
         //recovery mode lot size text
         ObjectCreate(0,obj_lots_return_rec,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,obj_lots_return_rec,OBJPROP_XDISTANCE,380);
         ObjectSetInteger(0,obj_lots_return_rec,OBJPROP_YDISTANCE,390);
         ObjectSetString(0,obj_lots_return_rec,OBJPROP_TEXT,lots_String);
         ObjectSetInteger(0,obj_lots_return_rec,OBJPROP_FONTSIZE,InpFontSize);
         ObjectSetString(0,obj_lots_return_rec,OBJPROP_FONT,"Terminal");            
         ObjectSetInteger(0,obj_lots_return_rec,OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,obj_lots_return_rec,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
         //recovery divider
         ObjectCreate(0,obj_rec_div,OBJ_RECTANGLE_LABEL,0,0,0);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_XDISTANCE,45);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_YDISTANCE,510);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_XSIZE,350);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_YSIZE,1);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_BGCOLOR,clrNONE);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_COLOR,clrDarkSlateGray);
         ObjectSetInteger(0,obj_rec_div,OBJPROP_BORDER_TYPE,BORDER_FLAT);                    
         
         ChartBullColorSet(C'50,0,0',0);
         ChartBearColorSet(C'50,0,0',0);              
      }
      
      if(in_recovery==false){
         ObjectDelete(0,obj_inrec);
         ObjectDelete(0,obj_inrec_string);
         ObjectDelete(0,obj_inrec_lots);
         ObjectDelete(0,obj_lots_return_rec);
         ObjectDelete(0,obj_rec_div);
         //reset backgound height
         ObjectSetInteger(0,background_Edge,OBJPROP_YSIZE,462);
         ObjectSetInteger(0,background,OBJPROP_YSIZE,460);          
         ChartBullColorSet(clrBlack,0);
         ChartBearColorSet(clrBlack,0);      
      }
       
   }
   
   
 
 
 

//=== DETECT NEW BAR ==============================================================================================//   
   int bars = iBars(_Symbol,PERIOD_D1);
   if(barsTotal != bars){
      barsTotal = bars;
      today_buys=0;
      today_sells=0;
      daily_return_perc=0;
   }
   
   int w_bars = iBars(_Symbol,PERIOD_W1);
   if(w_barsTotal != w_bars){
      w_barsTotal = w_bars;
      weekly_return_perc=0;
      weekly_start_balance = accountInfo.Balance();
   }

   int m_bars = iBars(_Symbol,PERIOD_MN1);
   if(m_barsTotal != m_bars){
      m_barsTotal = m_bars;
      monthly_return_perc=0;
      month_start_balance = accountInfo.Balance();
   }




   if(ordBuy==0 && posBuy==0){buyTS_level=0;}
   if(ordSell==0 && posSell==0){sellTS_level=0;}
   if(recTrades==InpRecoveryTimes){recTrades=0; tradeLoss=0; in_recovery=false;}     

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
   //datetime orderThreshold = rangeEnd+300; 
   
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
      if(InpAutoLot==false){
         lotSize = InpLotSize;
         if(lotSize>max_start_vol){lotSize=max_start_vol;}
      }
      
      if(InpAutoLot==true){
         autoLot_multi = accountInfo.Balance()/InpLotsPer;
         lotSize = NormalizeDouble(InpLotSize*autoLot_multi,2);
         if(lotSize>max_start_vol){lotSize=max_start_vol;}
      }
      original_lotSize=lotSize;
   }
   
   if(InpUsePercentage==true){
      lotSize = calcLots(InpRiskPerc,sl_points);
      if(lotSize>max_start_vol){lotSize=max_start_vol;}
      original_lotSize=lotSize;      
   }
   
   //Recovery Lot Size
   if(tradeLoss==1 && recTrades==0){
      lotSize = NormalizeDouble(lotSize*InpRecoveryMulti,2);
      if(lotSize>symbol_maxLots){lotSize=symbol_maxLots;}   
   }
   
   if(recTrades>0 && InpRecoveryTimes > 1){
      if(recTrades < InpRecoveryTimes){
         lotSize = NormalizeDouble(original_lotSize*InpRecoveryMulti,2);
         if(lotSize>symbol_maxLots){lotSize=symbol_maxLots;}   
      }
   }     
   
   //Comment("LotSize: ",lotSize);     
   

//=== Setting Pending Orders ==========================================================================================================//

   if(posBuy==0 && posSell==0){

      //BUYS
      if(ordBuy==0){ //ordBuy<InpMaxPositions
         if(!haveTradedToday() && TimeCurrent() > rangeEnd){ //&& TimeCurrent()<orderThreshold
            //sl 2500 points
            buySL = range_top - sl_points;
            buyTP = range_top + tp_points;
            trade.BuyStop(lotSize,range_top,_Symbol,buySL,buyTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
            buyTS_level = NormalizeDouble(range_top + ts_startPoints,_Digits);
         }
      }    
      
      if(ordSell==0){  //ordSell<InpMaxPositions
         if(!haveTradedToday() && TimeCurrent() > rangeEnd){ //&& TimeCurrent()<orderThreshold
            sellSL = range_Bottom + sl_points;
            sellTP = range_Bottom - tp_points;
            trade.SellStop(lotSize,range_Bottom,_Symbol,sellSL,sellTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
            sellTS_level = NormalizeDouble(range_Bottom - ts_startPoints,_Digits);
         }
      }        
   }
   
   if(InpNewsMode==true){
      //Buy stops
      double buyStop_buffer = range_top-(30*_Point);
      if(ordBuy>0 && TimeCurrent()>stopTime && TimeCurrent()<resumeTime && currentTick.ask >= buyStop_buffer){
         deletePendingBuyStop();
         range_top = range_top+(30*_Point);
         buySL = range_top - sl_points;
         buyTP = range_top + tp_points;
         trade.BuyStop(lotSize,range_top,_Symbol,buySL,buyTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
         buyTS_level = NormalizeDouble(range_top + ts_startPoints,_Digits);         
           
      }
      double sellStop_buffer = range_Bottom+(30*_Point);
      if(ordSell>0 && TimeCurrent()>stopTime && TimeCurrent()<resumeTime && currentTick.bid >= sellStop_buffer){
         deletePendingSellStop();
         range_Bottom = range_Bottom-(30*_Point);
         sellSL = range_Bottom + sl_points;
         sellTP = range_Bottom - tp_points;
         trade.SellStop(lotSize,range_Bottom,_Symbol,sellSL,sellTP,ORDER_TIME_SPECIFIED,pendingClose,NULL);
         sellTS_level = NormalizeDouble(range_Bottom - ts_startPoints,_Digits);      
           
      }      
   }
 

  
//=== TRAILING STOP ==================================================================================================================//  

   // BUYS
   double Ask;
   Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK,Ask);
   
   if(InpNewsMode==false){
      if(posBuy>0){
         checkTrailingSLBuy(Ask);                                      
      }  
      if(currentTick.ask>buyTS_level){
         buyTS_level=currentTick.ask+InpTrailingStep*_Point;
      }
   }
   if((InpNewsMode==true && TimeCurrent()<stopTime) || (InpNewsMode==true && TimeCurrent()>resumeTime)){
      if(posBuy>0){
         checkTrailingSLBuy(Ask);                                      
      }  
      if(currentTick.ask>buyTS_level){
         buyTS_level=currentTick.ask+InpTrailingStep*_Point;
      }
   }
   // SELLS
   double Bid;
   Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID,Bid);
 
   if(InpNewsMode==false){  
      if(posSell>0){
         checkTrailingSLSell(Bid);  
      } 
      if(currentTick.bid<sellTS_level){
         sellTS_level=currentTick.bid-InpTrailingStep*_Point;
      }
   }
   if((InpNewsMode==true && TimeCurrent()<stopTime) || (InpNewsMode==true && TimeCurrent()>resumeTime)){ 
      if(posSell>0){
         checkTrailingSLSell(Bid);  
      } 
      if(currentTick.bid<sellTS_level){
         sellTS_level=currentTick.bid-InpTrailingStep*_Point;
      }
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

void deletePendingBuyStop(){
   int totalOrders = OrdersTotal();
   for(int i=totalOrders-1; i>=0; i--){
      ulong ticket = OrderGetTicket(i);
      long type; 
      if(!OrderGetInteger(ORDER_TYPE,type)){Print("Failed to get order type.");}
      long magic;
      if(!OrderGetInteger(ORDER_MAGIC,magic)){Print("Failed to get order magic number");}
      //delete buy orders
      if(today_sells>0 && type==ORDER_TYPE_BUY_STOP && magic==InpMagicNumber){
         trade.OrderDelete(ticket);
      }
   }
}

void deletePendingSellStop(){
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


//=== COSE PARTIALS FUNCTION =========================================================================//

//void closePartials(){
//
//   int total = PositionsTotal();
//   for(int i=total-1; i>=0; i--){
//      string symbol = PositionGetSymbol(i);
//      long type = PositionGetInteger(POSITION_TYPE);
//      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);      
//      ulong ticket = PositionGetTicket(i);
//      if(!PositionSelectByTicket(ticket)){
//         Print("Failed to select position.");
//      }
//      long magic;
//      if(!PositionGetInteger(POSITION_MAGIC,magic)){
//         Print("Failed to get position magic number.");
//      }
//      double volume;
//      if(!PositionGetDouble(POSITION_VOLUME,volume)){
//         Print("Failed to get position volume.");
//      }
//      double partialClose = volume*(InpPartialsPerc/100);
//
//      if(type==POSITION_TYPE_BUY){partials_trigger = openPrice-partials_points;}
//      if(type==POSITION_TYPE_SELL){partials_trigger = openPrice+partials_points;}
//            
//      if(symbol==_Symbol && magic==InpMagicNumber){
//         
//         if(type==POSITION_TYPE_BUY && currentTick.bid<partials_trigger){
//            trade.PositionClosePartial(ticket,0.10,0);
//         }
//         
//         if(type==POSITION_TYPE_SELL && currentTick.bid>partials_trigger){
//            trade.PositionClosePartial(ticket,0.10,0);
//         }      
//      }     
//   }      
//      
//} 

//bool closePartials(){
//
//   int total = PositionsTotal();
//   for(int i=total-1; i>=0; i--){
//      string symbol = PositionGetSymbol(i);
//      long type = PositionGetInteger(POSITION_TYPE);
//      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);      
//      ulong ticket = PositionGetTicket(i);
//      if(!PositionSelectByTicket(ticket)){
//         Print("Failed to select position.");
//      }
//      long magic;
//      if(!PositionGetInteger(POSITION_MAGIC,magic)){
//         Print("Failed to get position magic number.");
//      }
//      double volume;
//      if(!PositionGetDouble(POSITION_VOLUME,volume)){
//         Print("Failed to get position volume.");
//      }
//      double partialClose = volume*(InpPartialsPerc/100);
//
//      if(type==POSITION_TYPE_BUY){partials_trigger = openPrice-partials_points;}
//      if(type==POSITION_TYPE_SELL){partials_trigger = openPrice+250*_Point;}
//            
//      if(symbol==_Symbol && magic==InpMagicNumber){
//         
//         if(type==POSITION_TYPE_BUY && currentTick.bid<partials_trigger){
//            trade.PositionClosePartial(ticket,0.10,0);
//            return true;
//         }
//         
//         if(type==POSITION_TYPE_SELL && currentTick.bid>partials_trigger){
//            trade.PositionClosePartial(ticket,0.10,-1);
//            return true;
//         }      
//      }     
//   }      
//   return false;      
//}   




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
               in_recovery=true;
            }
         }    
         if(deal_entry==DEAL_ENTRY_OUT && deal_type==DEAL_TYPE_SELL){
            if(deal_price < sl_buffer_buy){
               tradeLoss=1;
               in_recovery=true;
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
      if(deal_entry==DEAL_ENTRY_OUT && deal_magic==InpMagicNumber){
         trade_profit = deal_profit;
         trade_closePrice = deal_price;
         trade_closeTime = deal_time;
         trade_closed = 1;
         obj_name_count++;
         obj_name = IntegerToString(obj_name_count,0);
         trade_profit_string = DoubleToString(trade_profit,2);
      }
      
      if(deal_entry==DEAL_ENTRY_OUT && deal_magic==InpMagicNumber){
         daily_return_perc = NormalizeDouble(deal_profit/balance_onePerc,2);
         weekly_return_perc += NormalizeDouble(deal_profit/weekly_start_balance*100,2);
         monthly_return_perc += NormalizeDouble(deal_profit/month_start_balance*100,2);
         total_return_perc += NormalizeDouble(deal_profit/start_balance*100,2);         
         ea_profit += deal_profit;
         total_trades_count += 1;
         
         if(deal_profit>0){total_win_count += 1;}
         if(deal_profit<0){total_loss_count += 1;}
      }  
   }   
}