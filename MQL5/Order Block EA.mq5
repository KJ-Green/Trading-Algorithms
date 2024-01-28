//+------------------------------------------------------------------+
//|                                               Order Block EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
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
//| Includes & Enumerations                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;
#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;
#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;

enum lotType{
   ENUM_PERC,  //%Risk
   ENUM_FIXED, //Fixed Lot
};
enum orderType{
   ENUM_LIMIT, //Limit Orders
   ENUM_STOP,  //Stop Orders
};

//+------------------------------------------------------------------+
//| Input Varbiables                                                 |
//+------------------------------------------------------------------+
input int         InpMagicNumber       =     44869;      //Magic Number
input orderType   InpOrderType         =     ENUM_LIMIT;  //Order Type
input lotType     InpLotType           =     ENUM_PERC;  //Lot Type 
input double      InpRisk              =     1.0;        //Risk Percent
input double      InpLotSize           =     0.01;       //Fixed Lot Size
input int         InpStopLoss          =     20;         //Stop Loss (pips)
input int         InpTakeProfit        =     20;         //Take Profit (pips)
input int         InpBreakeven         =     15;         //Break Even (pips)
input int         InpOBdist            =     50;         //Order Block Move Minimum Pips
input int         InpOBsize            =     75;         //Order Block Signal Maximum Size
//input ENUM_TIMEFRAMES InpOBTF          =     PERIOD_H1;  //Order Block Timeframe

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
MqlTick        currentTick;
MqlDateTime    today;

double         barOneH1_close, barOneH1_open, barOneH4_close, barOneH4_open, barOneD1_close, barOneD1_open;
double         barTwoH1_close, barTwoH1_open, barTwoH4_close, barTwoH4_open, barTwoD1_close, barTwoD1_open;
double         barThreeH1_close, barThreeH1_open, barThreeH4_close, barThreeH4_open, barThreeD1_close, barThreeD1_open;
double         barFourH1_close, barFourH1_open, barFourH4_close, barFourH4_open, barFourD1_close, barFourD1_open;
double         barFiveH1_close, barFiveH1_open, barFiveH4_close, barFiveH4_open, barFiveD1_close, barFiveD1_open;
double         obH1_high, obH1_low, obH4_high, obH4_low, obD1_high, obD1_low;
double         h1Move_high, h1Move_low, h1Move_distance;
double         h4Move_high, h4Move_low, h4Move_distance;
double         d1Move_high, d1Move_low, d1Move_distance;
double         obH1_entryPrice, obH4_entryPrice, obD1_entryPrice;
double         obSize;
double         SL, TP;
double         obDist_points = InpOBdist*10*_Point;
double         obSize_points = InpOBsize*10*_Point;
int            pointSL = InpStopLoss*10;
int            pointTP = InpTakeProfit*10;
int            pointBE = InpBreakeven*10;
int            barsTotal;

datetime       OB_start, OB_end, order_end;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
      
   if(InpMagicNumber < 0){Alert("Invalid Magic Number, Must be > 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpLotSize < 0){Alert("Invalid Lot Size, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpRisk < 0){Alert("Invalid Risk Percentage, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpStopLoss < 0){Alert("Invalid Stop Loss, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   if(InpTakeProfit < 0){Alert("Invalid Take Profit, Must not be less that 0.");return INIT_PARAMETERS_INCORRECT;}
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   
   ChartBackColorSet(clrBlack,0);
   ChartForeColorSet(clrGray,0);
   ChartGridColorSet(C'36,43,49',0);
   ChartUpColorSet(clrLime,0);
   ChartDownColorSet(clrIndianRed,0);
   ChartBullColorSet(clrLimeGreen,0);
   ChartBearColorSet(clrIndianRed,0);   

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
      Print("Failed to get current tick.");
      return;
   }

//---

   barOneH1_close    = iClose(_Symbol,PERIOD_H1,1);
   barOneH1_open     = iOpen(_Symbol,PERIOD_H1,1);
   barTwoH1_close    = iClose(_Symbol,PERIOD_H1,2);
   barTwoH1_open     = iOpen(_Symbol,PERIOD_H1,2);
   barThreeH1_close  = iClose(_Symbol,PERIOD_H1,3);
   barThreeH1_open   = iOpen(_Symbol,PERIOD_H1,3);
   barFourH1_close   = iClose(_Symbol,PERIOD_H1,4);
   barFourH1_open    = iOpen(_Symbol,PERIOD_H1,4);
   barFiveH1_close   = iClose(_Symbol,PERIOD_H1,5);
   barFiveH1_open    = iOpen(_Symbol,PERIOD_H1,5);
   
   barOneH4_close    = iClose(_Symbol,PERIOD_H4,1);
   barOneH4_open     = iOpen(_Symbol,PERIOD_H4,1);
   barTwoH4_close    = iClose(_Symbol,PERIOD_H4,2);
   barTwoH4_open     = iOpen(_Symbol,PERIOD_H4,2);
   barThreeH4_close  = iClose(_Symbol,PERIOD_H4,3);
   barThreeH4_open   = iOpen(_Symbol,PERIOD_H4,3);
   barFourH4_close   = iClose(_Symbol,PERIOD_H4,4);
   barFourH4_open    = iOpen(_Symbol,PERIOD_H4,4);
   barFiveH4_close   = iClose(_Symbol,PERIOD_H4,5);
   barFiveH4_open    = iOpen(_Symbol,PERIOD_H4,5);
   
   barOneD1_close    = iClose(_Symbol,PERIOD_D1,1);
   barOneD1_open     = iOpen(_Symbol,PERIOD_D1,1);
   barTwoD1_close    = iClose(_Symbol,PERIOD_D1,2);
   barTwoD1_open     = iOpen(_Symbol,PERIOD_D1,2);
   barThreeD1_close  = iClose(_Symbol,PERIOD_D1,3);
   barThreeD1_open   = iOpen(_Symbol,PERIOD_D1,3);
   barFourD1_close   = iClose(_Symbol,PERIOD_D1,4);
   barFourD1_open    = iOpen(_Symbol,PERIOD_D1,4);
   barFiveD1_close   = iClose(_Symbol,PERIOD_D1,5);
   barFiveD1_open    = iOpen(_Symbol,PERIOD_D1,5);
   
   datetime currentTime = iTime(_Symbol,0,0);
   


   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal != bars){
      barsTotal = bars;
      
//----Bearish OB - H1
      if(barFiveH1_close > barFiveH1_open && barFourH1_close < barFourH1_open && barThreeH1_close < barThreeH1_open
         && barTwoH1_close < barTwoH1_open && barOneH1_close < barOneH1_open){
         
         h1Move_high       = barFourH1_open;
         h1Move_low        = barOneH1_close;
         h1Move_distance   = h1Move_high - h1Move_low;
         obSize            = barFiveH1_close - barFiveH1_open;         
         
         if(h1Move_distance >= obDist_points && obSize <= obSize_points){
            obH1_high = barFiveH1_close;
            obH1_low  = barFiveH1_open;
            OB_start  = TimeCurrent() - PeriodSeconds(PERIOD_H1)*5;
            OB_end    = TimeCurrent();
            order_end = TimeCurrent() + PeriodSeconds(PERIOD_D1)*7;            
            SL        = obH1_high + pointSL*_Point;
            TP        = obH1_low - pointTP*_Point;
                      
            ObjectCreate(0,"BearOB_H1",OBJ_RECTANGLE,0,OB_start,obH1_high,OB_end,obH1_low);
            ObjectSetInteger(0,"BearOB_H1",OBJPROP_COLOR,0,clrCrimson);

            if(InpOrderType==ENUM_LIMIT){
               trade.SellLimit(0.20,obH1_high,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
               if(obSize<200*_Point){
                  trade.SellLimit(0.10,obH1_low,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
               }
            }
            if(InpOrderType==ENUM_STOP){
               trade.BuyStop(0.20,obH1_high,_Symbol,TP,SL,ORDER_TIME_SPECIFIED,order_end);
            }    
         }  
      }
      
//----Bullish OB - H1
      if(barFiveH1_close < barFiveH1_open && barFourH1_close > barFourH1_open && barThreeH1_close > barThreeH1_open
         && barTwoH1_close > barTwoH1_open && barOneH1_close > barOneH1_open){
         
         h1Move_high       = barOneH1_close;
         h1Move_low        = barFourH1_open;
         h1Move_distance   = h1Move_high - h1Move_low;
         obSize            = barFiveH1_open - barFiveH1_close;         
      
         if(h1Move_distance >= obDist_points && obSize <= obSize_points){
            obH1_high = barFiveH1_open;
            obH1_low  = barFiveH1_close;
            OB_start  = TimeCurrent() - PeriodSeconds(PERIOD_H1)*5;
            OB_end    = TimeCurrent();
            order_end = TimeCurrent() + PeriodSeconds(PERIOD_D1)*7;                        
            SL        = obH1_low - pointSL*_Point;
            TP        = obH1_high + pointTP*_Point;
            
            ObjectCreate(0,"BullOB_H1",OBJ_RECTANGLE,0,OB_start,obH1_high,OB_end,obH1_low);
            ObjectSetInteger(0,"BullOB_H1",OBJPROP_COLOR,0,clrCrimson);
            // C'149,82,0' 
            
            //if(InpOrderType==ENUM_LIMIT){
            //   trade.BuyLimit(0.20,obH1_low,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
            //   if(obSize < 200*_Point){
            //      trade.BuyLimit(0.10,obH1_high,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
            //   }
            //}
            //if(InpOrderType==ENUM_STOP){
            //   trade.SellStop(0.20,obH1_low,_Symbol,TP,SL,ORDER_TIME_SPECIFIED,order_end);
            //}                  
         }
      }
      
//----Bearish OB - H4
      if(barFiveH4_close > barFiveH4_open && barFourH4_close < barFourH4_open && barThreeH4_close < barThreeH4_open
         && barTwoH4_close < barTwoH4_open && barOneH4_close < barOneH4_open){
         
         h4Move_high       = barFourH4_open;
         h4Move_low        = barOneH4_close;
         h4Move_distance   = h4Move_high - h4Move_low;
         obSize            = barFiveH4_close - barFiveH4_open;         
         
         if(h4Move_distance >= obDist_points && obSize <= obSize_points){
            obH4_high = barFiveH4_close;
            obH4_low  = barFiveH4_open;
            OB_start  = TimeCurrent() - PeriodSeconds(PERIOD_H4)*5;
            OB_end    = TimeCurrent();
            order_end = TimeCurrent() + PeriodSeconds(PERIOD_D1)*15;
            SL        = obH4_high + pointSL*_Point;
            TP        = obH4_low - pointTP*_Point;
            
            ObjectCreate(0,"BearOB_H4",OBJ_RECTANGLE,0,OB_start,obH4_high,OB_end,obH4_low);
            ObjectSetInteger(0,"BearOB_H4",OBJPROP_COLOR,0,clrDarkOrange);
            
            //if(InpOrderType==ENUM_LIMIT){   
            //   trade.SellLimit(0.20,obH4_high,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
            //   if(obSize<500*_Point){
            //      trade.SellLimit(0.10,obH4_low,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
            //   }
            //}
            //if(InpOrderType==ENUM_STOP){
            //   trade.BuyStop(0.20,obH4_high,_Symbol,TP,SL,ORDER_TIME_SPECIFIED,order_end);
            //}    
         }  
      }
      
//----Bullish OB - H4
      if(barFiveH4_close < barFiveH4_open && barFourH4_close > barFourH4_open && barThreeH4_close > barThreeH4_open
         && barTwoH4_close > barTwoH4_open && barOneH4_close > barOneH4_open){
         
         h4Move_high       = barOneH4_close;
         h4Move_low        = barFourH4_open;
         h4Move_distance   = h4Move_high - h4Move_low;
         obSize            = barFiveH4_open - barFiveH4_close;         
      
         if(d1Move_distance >= obDist_points && obSize <= obSize_points){
            obH4_high = barFiveH4_open;
            obH4_low  = barFiveH4_close;
            OB_start  = TimeCurrent() - PeriodSeconds(PERIOD_H4)*5;
            OB_end    = TimeCurrent();
            order_end = TimeCurrent() + PeriodSeconds(PERIOD_D1)*7;
            SL        = obH4_low - pointSL*_Point;
            TP        = obH4_high + pointTP*_Point;
            
            ObjectCreate(0,"BullOB_H4",OBJ_RECTANGLE,0,OB_start,obH4_high,OB_end,obH4_low);
            ObjectSetInteger(0,"BullOB_H4",OBJPROP_COLOR,0,clrDarkOrange);               
         }
      }
      
//----Bearish OB - D1
      if(barFiveD1_close > barFiveD1_open && barFourD1_close < barFourD1_open && barThreeD1_close < barThreeD1_open
         && barTwoD1_close < barTwoD1_open && barOneD1_close < barOneD1_open){
         
         d1Move_high       = barFourD1_open;
         d1Move_low        = barOneD1_close;
         d1Move_distance   = d1Move_high - d1Move_low;
         obSize            = barFiveD1_close - barFiveD1_open;         
         
         if(h4Move_distance >= obDist_points && obSize <= obSize_points){
            obD1_high = barFiveD1_close;
            obD1_low  = barFiveD1_open;
            OB_start  = TimeCurrent() - PeriodSeconds(PERIOD_D1)*5;
            OB_end    = TimeCurrent();
            order_end = TimeCurrent() + PeriodSeconds(PERIOD_D1)*30;
            SL        = obD1_high + pointSL*_Point;
            TP        = obD1_high - pointTP*_Point;

            
            ObjectCreate(0,"BearOB_D1",OBJ_RECTANGLE,0,OB_start,obD1_high,OB_end,obD1_low);
            ObjectSetInteger(0,"BearOB_D1",OBJPROP_COLOR,0,clrGold);
            
            if(InpOrderType==ENUM_LIMIT){        
               trade.SellLimit(InpLotSize,obD1_high,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
            }
            if(InpOrderType==ENUM_STOP){
               trade.BuyStop(0.20,obD1_high,_Symbol,TP,SL,ORDER_TIME_SPECIFIED,order_end);
            }       
         }  
      }
      
//----Bullish OB - D1
      if(barFiveD1_close < barFiveD1_open && barFourD1_close > barFourD1_open && barThreeD1_close > barThreeD1_open
         && barTwoD1_close > barTwoD1_open && barOneD1_close > barOneD1_open){
         
         h4Move_high       = barOneD1_close;
         h4Move_low        = barFourD1_open;
         h4Move_distance   = h4Move_high - h4Move_low;
         obSize            = barFiveD1_open - barFiveD1_close;         
      
         if(h4Move_distance >= obDist_points && obSize <= obSize_points){
            obD1_high = barFiveD1_open;
            obD1_low  = barFiveD1_close;
            OB_start  = TimeCurrent() - PeriodSeconds(PERIOD_D1)*5;
            OB_end    = TimeCurrent();
            order_end = TimeCurrent() + PeriodSeconds(PERIOD_D1)*30;
            SL        = obD1_low - pointSL*_Point;
            TP        = obD1_low + pointTP*_Point;
            
            ObjectCreate(0,"BullOB_D1",OBJ_RECTANGLE,0,OB_start,obD1_high,OB_end,obD1_low);
            ObjectSetInteger(0,"BullOB_D1",OBJPROP_COLOR,0,clrGold);

            if(InpOrderType==ENUM_LIMIT){               
               trade.BuyLimit(InpLotSize,obD1_low,_Symbol,SL,TP,ORDER_TIME_SPECIFIED,order_end);
            }
            if(InpOrderType==ENUM_STOP){
               trade.SellStop(0.20,obD1_low,_Symbol,TP,SL,ORDER_TIME_SPECIFIED,order_end);
            }                                
         }
      }                   
   }
   
   //if(ObjectGetInteger(1,"BearOB_H1",OBJPROP_TIME,2) != TimeCurrent()){
   //   ObjectSetInteger(1,"BearOB_H1",OBJPROP_TIME,1,TimeCurrent());
   //}

   ObjectSetInteger(0,"BearOB_H1",OBJPROP_TIME,1,TimeCurrent());
   ObjectSetInteger(0,"BullOB_H1",OBJPROP_TIME,1,TimeCurrent());
    
   ObjectSetInteger(0,"BearOB_H4",OBJPROP_TIME,1,TimeCurrent());
   ObjectSetInteger(0,"BullOB_H4",OBJPROP_TIME,1,TimeCurrent());
     
   ObjectSetInteger(0,"BearOB_D1",OBJPROP_TIME,1,TimeCurrent());  
   ObjectSetInteger(0,"BullOB_D1",OBJPROP_TIME,1,TimeCurrent());             
   
      
}


//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+