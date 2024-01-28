//+------------------------------------------------------------------+
//|                                                Levels Trader.mq5 |
//|                              Copyright 2023, Shogun Trading Ltd. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Shogun Trading Ltd."
#property link      "info.shoguntrading@gmail.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Includes and Enumerations
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
enum profTarget
  {
   ENUM_REWARD,   //R:R
   ENUM_FIXED,    //Fixed
  };

//+------------------------------------------------------------------+
//| Input Parameters
//+------------------------------------------------------------------+

input int         InpMagicNumber       =  000222;      //Magic Number
input int         InpLookBack          =  5;          //Candle Look Back
input int         InpMinMove           =  50;         //Minimum Move Size (pips)
input int         InpEntryThresh       =  20;         //Entry Signal Threshold (pips)
input int         InpStopThresh        =  50;         //Stop Detect Threshold (pips)
input orderType   InpOrderType         =  ENUM_LIMIT;  //Order Type
input lotType     InpLotType           =  ENUM_PERC;  //Lot Type 
input profTarget  InpProfitTarget      =  ENUM_REWARD;//Profit Target
input bool        InpSLDetect          =  true;       //Detect Levels for Stop Loss (Regular SL input when none detected)     
input double      InpRisk              =  1.0;        //Risk Percent
input double      InpLotSize           =  0.01;       //Fixed Lot Size
input int         InpStopLoss          =  20;         //Stop Loss (pips)
input int         InpTakeProfit        =  20;         //Take Profit (pips)
input double      InpRiskReward        =  2;          //Risk to Reward - 1:
input int         InpBreakeven         =  15;         //Break Even (pips)



//+------------------------------------------------------------------+
//| Global Variables
//+------------------------------------------------------------------+
MqlTick        currentTick;
MqlDateTime    today;

int            moveStart_bar;
int            moveScnd_bar;
double         initialH1_close, initialH1_open, initialH4_close, initialH4_open, initialD1_close, initialD1_open;
double         moveHigh_H1, moveLow_H1, moveHigh_H4, moveLow_H4, moveHigh_D1, moveLow_D1;
double         startBar_open_h1, startBar_close_h1, startBar_open_h4, startBar_close_h4, startBar_open_d1, startBar_close_d1;
double         scndBar_open_h1, scndBar_close_h1, scndBar_open_h4, scndBar_close_h4, scndBar_open_d1, scndBar_close_d1;
double         barOne_high, barOne_low; 
double         moveSize_h1, moveSize_h4, moveSize_d1;
int            minMove_Points_h1, minMove_Points_h4, minMove_Points_d1; 

double         h1_sellLvl_1, h1_sellLvl_2, h1_sellLvl_3, h1_sellLvl_4, h1_sellLvl_5;
double         h4_sellLvl_1, h4_sellLvl_2, h4_sellLvl_3, h4_sellLvl_4, h4_sellLvl_5;
double         d1_sellLvl_1, d1_sellLvl_2, d1_sellLvl_3, d1_sellLvl_4, d1_sellLvl_5;

double         h1_buyLvl_1, h1_buyLvl_2, h1_buyLvl_3, h1_buyLvl_4, h1_buyLvl_5;
double         h4_buyLvl_1, h4_buyLvl_2, h4_buyLvl_3, h4_buyLvl_4, h4_buyLvl_5;
double         d1_buyLvl_1, d1_buyLvl_2, d1_buyLvl_3, d1_buyLvl_4, d1_buyLvl_5;

int            total_S_lvl_h1 = 0; 
int            total_B_lvl_h1 = 0;
int            total_S_lvl_h4 = 0; 
int            total_B_lvl_h4 = 0;
int            total_S_lvl_d1 = 0; 
int            total_B_lvl_d1 = 0;

datetime       startTime_h1Sell, startTime_h1Buy, startTime_h4Sell, startTime_h4Buy, startTime_d1Sell, startTime_d1Buy;
datetime       nextSellCheck_h1, nextBuyCheck_h1, nextSellCheck_h4, nextBuyCheck_h4, nextSellCheck_d1, nextBuyCheck_d1;

double         yDay_high, yDay_low, yDay_close;
double         pivotPoint, r1, r2, r3, r4, s1, s2, s3, s4;
double         pp_top, pp_btm, r1_top,r1_btm,r2_top,r2_btm,r3_top,r3_btm,s1_top,s1_btm,s2_top,s2_btm,s3_top,s3_btm;

int            atr_handle;
double         atrBuffer[];
double         atr_top, atr_bottom, open_price;
int            barsTotal;

double         bePoints, slPoints, tpPoints, slSize, tpSize, SL, TP, lotSize;
double         entry_threshold, stop_threshold;
double         level_stop;

int            h1_b1_sgnl,h1_b2_sgnl,h1_b3_sgnl,h1_b4_sgnl,h1_b5_sgnl,h1_s1_sgnl,h1_s2_sgnl,h1_s3_sgnl,h1_s4_sgnl,h1_s5_sgnl;
int            h4_b1_sgnl,h4_b2_sgnl,h4_b3_sgnl,h4_b4_sgnl,h4_b5_sgnl,h4_s1_sgnl,h4_s2_sgnl,h4_s3_sgnl,h4_s4_sgnl,h4_s5_sgnl;
int            d1_b1_sgnl,d1_b2_sgnl,d1_b3_sgnl,d1_b4_sgnl,d1_b5_sgnl,d1_s1_sgnl,d1_s2_sgnl,d1_s3_sgnl,d1_s4_sgnl,d1_s5_sgnl;

int            h1_b1_cnt,h1_b2_cnt,h1_b3_cnt,h1_b4_cnt,h1_b5_cnt,h1_s1_cnt,h1_s2_cnt,h1_s3_cnt,h1_s4_cnt,h1_s5_cnt;
int            h4_b1_cnt,h4_b2_cnt,h4_b3_cnt,h4_b4_cnt,h4_b5_cnt,h4_s1_cnt,h4_s2_cnt,h4_s3_cnt,h4_s4_cnt,h4_s5_cnt;
int            d1_b1_cnt,d1_b2_cnt,d1_b3_cnt,d1_b4_cnt,d1_b5_cnt,d1_s1_cnt,d1_s2_cnt,d1_s3_cnt,d1_s4_cnt,d1_s5_cnt;

long           h1_b1_tkt,h1_b2_tkt,h1_b3_tkt,h1_b4_tkt,h1_b5_tkt,h1_s1_tkt,h1_s2_tkt,h1_s3_tkt,h1_s4_tkt,h1_s5_tkt;
long           h4_b1_tkt,h4_b2_tkt,h4_b3_tkt,h4_b4_tkt,h4_b5_tkt,h4_s1_tkt,h4_s2_tkt,h4_s3_tkt,h4_s4_tkt,h4_s5_tkt;
long           d1_b1_tkt,d1_b2_tkt,d1_b3_tkt,d1_b4_tkt,d1_b5_tkt,d1_s1_tkt,d1_s2_tkt,d1_s3_tkt,d1_s4_tkt,d1_s5_tkt;

double         h1_b1_tp,h1_b2_tp,h1_b3_tp,h1_b4_tp,h1_b5_tp,h1_s1_tp,h1_s2_tp,h1_s3_tp,h1_s4_tp,h1_s5_tp;
double         h4_b1_tp,h4_b2_tp,h4_b3_tp,h4_b4_tp,h4_b5_tp,h4_s1_tp,h4_s2_tp,h4_s3_tp,h4_s4_tp,h4_s5_tp;
double         d1_b1_tp,d1_b2_tp,d1_b3_tp,d1_b4_tp,d1_b5_tp,d1_s1_tp,d1_s2_tp,d1_s3_tp,d1_s4_tp,d1_s5_tp;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{  
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   atr_handle = iATR(_Symbol,PERIOD_D1,20);
   
   ArraySetAsSeries(atrBuffer,true);

   barsTotal = iBars(_Symbol,PERIOD_D1);

   return(INIT_SUCCEEDED);
}




//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(atr_handle != INVALID_HANDLE){IndicatorRelease(atr_handle);}

}



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!SymbolInfoTick(_Symbol,currentTick)){Alert("Failed to get current tick.");}

   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);   
   
   
//---

   bePoints    = InpBreakeven*10*_Point;
   slPoints    = InpStopLoss*10*_Point;
   tpPoints    = InpTakeProfit*10*_Point;
   entry_threshold = InpEntryThresh*10*_Point;
   stop_threshold = InpStopThresh*10*_Point;
   
   
   open_price  = iOpen(_Symbol,PERIOD_D1,0);
   yDay_high   = iHigh(_Symbol,PERIOD_D1,1);
   yDay_low    = iLow(_Symbol,PERIOD_D1,1);
   yDay_close  = iClose(_Symbol,PERIOD_D1,1);
   pivotPoint  = (yDay_close + yDay_high + yDay_low) / 3;
   r1          = pivotPoint * 2 - yDay_low;
   r2          = pivotPoint + (yDay_high - yDay_low);
   r3          = yDay_high + (2 * (pivotPoint - yDay_low)); 
   s1          = pivotPoint * 2 - yDay_high;
   s2          = pivotPoint - (yDay_high - yDay_low);
   s3          = yDay_low - (2 * (yDay_high - pivotPoint));
   datetime dayStart = iTime(_Symbol,PERIOD_D1,0);
   datetime dayEnd = dayStart + PeriodSeconds(PERIOD_D1);
   
   ////PP
   //pivotpoints("pp",clrWhite,dayStart,pivotPoint,dayEnd);
   ////s1
   //pivotpoints("s1",clrThistle,dayStart,s1,dayEnd);
   //   //s2
   //pivotpoints("s2",clrThistle,dayStart,s2,dayEnd);
   //   //s3
   //pivotpoints("s3",clrThistle,dayStart,s3,dayEnd);
   //   //r1
   //pivotpoints("r1",clrSeaGreen,dayStart,r1,dayEnd);
   //      //r2
   //pivotpoints("r2",clrSeaGreen,dayStart,r2,dayEnd);
   //      //r1
   //pivotpoints("r3",clrSeaGreen,dayStart,r3,dayEnd);
   
   
   int bars = iBars(_Symbol,PERIOD_D1);
   if(barsTotal != bars){
      barsTotal = bars;
      open_price = iOpen(_Symbol,PERIOD_D1,0);
   }
   
   CopyBuffer(atr_handle,0,0,2,atrBuffer);
   
   atr_top = open_price + atrBuffer[1];
   atr_bottom = open_price - atrBuffer[1];
   
   //atrChart("top",clrCornflowerBlue,dayStart,atr_top,dayEnd);
   //atrChart("btm",clrHotPink,dayStart,atr_bottom,dayEnd);

//---


   minMove_Points_h1 = InpMinMove*10;
   minMove_Points_h4 = MathRound(minMove_Points_h1 * 1.5);
   minMove_Points_d1 = minMove_Points_h1 * 2;
   
   moveStart_bar     = InpLookBack - 1;
   moveScnd_bar      = InpLookBack - 2;
   
   initialH1_open    = iOpen(_Symbol,PERIOD_H1,InpLookBack);
   initialH1_close   = iClose(_Symbol,PERIOD_H1,InpLookBack);
   initialH4_open    = iOpen(_Symbol,PERIOD_H4,InpLookBack);
   initialH4_close   = iClose(_Symbol,PERIOD_H4,InpLookBack);
   initialD1_open    = iOpen(_Symbol,PERIOD_D1,InpLookBack);
   initialD1_close   = iClose(_Symbol,PERIOD_D1,InpLookBack);
   
   moveHigh_H1       = iHigh(_Symbol,PERIOD_H1,iHighest(_Symbol,PERIOD_H1,MODE_HIGH,moveStart_bar,0));
   moveLow_H1        = iLow(_Symbol,PERIOD_H1,iLowest(_Symbol,PERIOD_H1,MODE_LOW,moveStart_bar,0));
   moveHigh_H4       = iHigh(_Symbol,PERIOD_H4,iHighest(_Symbol,PERIOD_H4,MODE_HIGH,moveStart_bar,0));
   moveLow_H4        = iLow(_Symbol,PERIOD_H4,iLowest(_Symbol,PERIOD_H4,MODE_LOW,moveStart_bar,0));
   moveHigh_D1       = iHigh(_Symbol,PERIOD_D1,iHighest(_Symbol,PERIOD_D1,MODE_HIGH,moveStart_bar,0));
   moveLow_D1        = iLow(_Symbol,PERIOD_D1,iLowest(_Symbol,PERIOD_D1,MODE_LOW,moveStart_bar,0));
   
   startBar_close_h1    = iClose(_Symbol,PERIOD_H1,moveStart_bar);
   startBar_open_h1     = iOpen(_Symbol,PERIOD_H1,moveStart_bar);
   startBar_close_h4    = iClose(_Symbol,PERIOD_H4,moveStart_bar);
   startBar_open_h4     = iOpen(_Symbol,PERIOD_H4,moveStart_bar);
   startBar_close_d1    = iClose(_Symbol,PERIOD_D1,moveStart_bar);
   startBar_open_d1     = iOpen(_Symbol,PERIOD_D1,moveStart_bar);
   
   scndBar_close_h1     = iClose(_Symbol,PERIOD_H1,moveScnd_bar);
   scndBar_open_h1      = iOpen(_Symbol,PERIOD_H1,moveScnd_bar);
   scndBar_close_h4     = iClose(_Symbol,PERIOD_H4,moveScnd_bar);
   scndBar_open_h4      = iOpen(_Symbol,PERIOD_H4,moveScnd_bar);
   scndBar_close_d1     = iClose(_Symbol,PERIOD_D1,moveScnd_bar);
   scndBar_open_d1      = iOpen(_Symbol,PERIOD_D1,moveScnd_bar);
   
   // sell --- if(scndBar_close_h1 < scndBar_open_h1) 
   
   moveSize_h1       = moveHigh_H1 - moveLow_H1;
   moveSize_h4       = moveHigh_H4 - moveLow_H4;
   moveSize_d1       = moveHigh_D1 - moveLow_D1;

//---





//=== H1 SELL =================================================================================================================================================================//

   if(initialH1_open < initialH1_close && moveSize_h1 > minMove_Points_h1*_Point && currentTick.bid < initialH1_close && startBar_close_h1 < startBar_open_h1){
      if(total_S_lvl_h1 == 0 && TimeCurrent() > nextSellCheck_h1){
         h1_sellLvl_1 = initialH1_close;
         startTime_h1Sell = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_slvl_1",OBJ_TREND,0,startTime_h1Sell,h1_sellLvl_1,TimeCurrent(),h1_sellLvl_1);
         total_S_lvl_h1 = 1;
         nextSellCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;
      }
      if(total_S_lvl_h1 == 1 && TimeCurrent() > nextSellCheck_h1){
         h1_sellLvl_2 = initialH1_close;
         startTime_h1Sell = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_slvl_2",OBJ_TREND,0,startTime_h1Sell,h1_sellLvl_2,TimeCurrent(),h1_sellLvl_2);
         total_S_lvl_h1 = 2;
         nextSellCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      }
      if(total_S_lvl_h1 == 2 && TimeCurrent() > nextSellCheck_h1){
         h1_sellLvl_3 = initialH1_close;
         startTime_h1Sell = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_slvl_3",OBJ_TREND,0,startTime_h1Sell,h1_sellLvl_3,TimeCurrent(),h1_sellLvl_3);
         total_S_lvl_h1 = 3;
         nextSellCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      }
      if(total_S_lvl_h1 == 3 && TimeCurrent() > nextSellCheck_h1){
         h1_sellLvl_4 = initialH1_close;
         startTime_h1Sell = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_slvl_4",OBJ_TREND,0,startTime_h1Sell,h1_sellLvl_4,TimeCurrent(),h1_sellLvl_4);
         total_S_lvl_h1 = 4;
         nextSellCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      } 
      if(total_S_lvl_h1 == 4 && TimeCurrent() > nextSellCheck_h1){
         h1_sellLvl_5 = initialH1_close;
         startTime_h1Sell = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_slvl_5",OBJ_TREND,0,startTime_h1Sell,h1_sellLvl_5,TimeCurrent(),h1_sellLvl_5);
         total_S_lvl_h1 = 5;
         nextSellCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      }                                    
   }
 
//---
   
   if(total_S_lvl_h1 == 1){
      if(currentTick.bid > h1_sellLvl_1){ObjectDelete(0,"h1_slvl_1"); total_S_lvl_h1=0; h1_sellLvl_1=0; h1_s1_sgnl=0;}
   }
   if(total_S_lvl_h1 == 2){     
      if(currentTick.bid > h1_sellLvl_2){ObjectDelete(0,"h1_slvl_2"); total_S_lvl_h1=1; h1_sellLvl_2=0; h1_s2_sgnl=0;}
   }
   if(total_S_lvl_h1 == 3){      
      if(currentTick.bid > h1_sellLvl_3){ObjectDelete(0,"h1_slvl_3"); total_S_lvl_h1=2; h1_sellLvl_3=0; h1_s3_sgnl=0;}
   } 
   if(total_S_lvl_h1 == 4){      
      if(currentTick.bid > h1_sellLvl_4){ObjectDelete(0,"h1_slvl_4"); total_S_lvl_h1=3; h1_sellLvl_4=0; h1_s4_sgnl=0;}
   }
   if(total_S_lvl_h1 == 5){      
      if(currentTick.bid > h1_sellLvl_5){ObjectDelete(0,"h1_slvl_5"); total_S_lvl_h1=4; h1_sellLvl_5=0; h1_s5_sgnl=0;}
   } 
 
//---
    
   ObjectSetInteger(0,"h1_slvl_1",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_slvl_2",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_slvl_3",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_slvl_4",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_slvl_5",OBJPROP_TIME,1,TimeCurrent());    






//=== H1 BUY ==================================================================================================================================================================//

   if(initialH1_open > initialH1_close && moveSize_h1 > minMove_Points_h1*_Point && currentTick.bid > initialH1_close && startBar_close_h1 > startBar_open_h1){
      if(total_B_lvl_h1 == 0 && TimeCurrent() > nextBuyCheck_h1){
         h1_buyLvl_1 = initialH1_close;
         startTime_h1Buy = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_blvl_1",OBJ_TREND,0,startTime_h1Buy,h1_buyLvl_1,TimeCurrent(),h1_buyLvl_1);
         ObjectSetInteger(0,"h1_blvl_1",OBJPROP_COLOR,clrLime);
         total_B_lvl_h1 = 1;
         nextBuyCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;
      }
      if(total_B_lvl_h1 == 1 && TimeCurrent() > nextBuyCheck_h1){
         h1_buyLvl_2 = initialH1_close;
         startTime_h1Buy = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_blvl_2",OBJ_TREND,0,startTime_h1Buy,h1_buyLvl_2,TimeCurrent(),h1_buyLvl_2);
         ObjectSetInteger(0,"h1_blvl_2",OBJPROP_COLOR,clrLime);
         total_B_lvl_h1 = 2;
         nextBuyCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      }
      if(total_B_lvl_h1 == 2 && TimeCurrent() > nextBuyCheck_h1){
         h1_buyLvl_3 = initialH1_close;
         startTime_h1Buy = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_blvl_3",OBJ_TREND,0,startTime_h1Buy,h1_buyLvl_3,TimeCurrent(),h1_buyLvl_3);
         ObjectSetInteger(0,"h1_blvl_3",OBJPROP_COLOR,clrLime);
         total_B_lvl_h1 = 3;
         nextBuyCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      }
      if(total_B_lvl_h1 == 3 && TimeCurrent() > nextBuyCheck_h1){
         h1_buyLvl_4 = initialH1_close;
         startTime_h1Buy = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_blvl_4",OBJ_TREND,0,startTime_h1Buy,h1_buyLvl_4,TimeCurrent(),h1_buyLvl_4);
         ObjectSetInteger(0,"h1_blvl_4",OBJPROP_COLOR,clrLime);
         total_B_lvl_h1 = 4;
         nextBuyCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      } 
      if(total_B_lvl_h1 == 4 && TimeCurrent() > nextBuyCheck_h1){
         h1_buyLvl_5 = initialH1_close;
         startTime_h1Buy = TimeCurrent() - PeriodSeconds(PERIOD_H1)*InpLookBack;
         ObjectCreate(0,"h1_blvl_4",OBJ_TREND,0,startTime_h1Buy,h1_buyLvl_5,TimeCurrent(),h1_buyLvl_5);
         ObjectSetInteger(0,"h1_blvl_5",OBJPROP_COLOR,clrLime);
         total_B_lvl_h1 = 5;
         nextBuyCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H1)*5;         
      }                                    
   }

 
//---
   
   if(total_B_lvl_h1 == 1){
      if(currentTick.bid < h1_buyLvl_1){ObjectDelete(0,"h1_blvl_1"); total_B_lvl_h1=0; h1_buyLvl_1=0; h1_b1_sgnl=0;}
   }
   if(total_B_lvl_h1 == 2){     
      if(currentTick.bid < h1_buyLvl_2){ObjectDelete(0,"h1_blvl_2"); total_B_lvl_h1=1; h1_buyLvl_2=0; h1_b2_sgnl=0;}
   }
   if(total_B_lvl_h1 == 3){      
      if(currentTick.bid < h1_buyLvl_3){ObjectDelete(0,"h1_blvl_3"); total_B_lvl_h1=2; h1_buyLvl_3=0; h1_b3_sgnl=0;}
   } 
   if(total_B_lvl_h1 == 4){      
      if(currentTick.bid < h1_buyLvl_4){ObjectDelete(0,"h1_blvl_4"); total_B_lvl_h1=3; h1_buyLvl_4=0; h1_b4_sgnl=0;}
   }
   if(total_B_lvl_h1 == 5){      
      if(currentTick.bid < h1_buyLvl_5){ObjectDelete(0,"h1_blvl_5"); total_B_lvl_h1=4; h1_buyLvl_5=0; h1_b5_sgnl=0;}
   } 
 
//---
    
   ObjectSetInteger(0,"h1_blvl_1",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_blvl_2",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_blvl_3",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_blvl_4",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h1_blvl_5",OBJPROP_TIME,1,TimeCurrent());    
 
 
 
 
 
 
 
 //=== H4 SELL =================================================================================================================================================================//

   if(initialH4_open < initialH4_close && moveSize_h4 > minMove_Points_h1*_Point && currentTick.bid < initialH4_close && startBar_close_h4 < startBar_open_h4){
      if(total_S_lvl_h4 == 0 && TimeCurrent() > nextSellCheck_h4){
         h4_sellLvl_1 = initialH4_close;
         startTime_h4Sell = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_slvl_1",OBJ_TREND,0,startTime_h4Sell,h4_sellLvl_1,TimeCurrent(),h4_sellLvl_1);
         ObjectSetInteger(0,"h4_slvl_1",OBJPROP_COLOR,clrYellow);         
         total_S_lvl_h4 = 1;
         nextSellCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;
      }
      if(total_S_lvl_h4 == 1 && TimeCurrent() > nextSellCheck_h4){
         h4_sellLvl_2 = initialH4_close;
         startTime_h4Sell = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_slvl_2",OBJ_TREND,0,startTime_h4Sell,h4_sellLvl_2,TimeCurrent(),h4_sellLvl_2);
         ObjectSetInteger(0,"h4_slvl_2",OBJPROP_COLOR,clrYellow); 
         total_S_lvl_h4 = 2;
         nextSellCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      }
      if(total_S_lvl_h4 == 2 && TimeCurrent() > nextSellCheck_h4){
         h4_sellLvl_3 = initialH4_close;
         startTime_h4Sell = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_slvl_3",OBJ_TREND,0,startTime_h4Sell,h4_sellLvl_3,TimeCurrent(),h4_sellLvl_3);
         ObjectSetInteger(0,"h4_slvl_3",OBJPROP_COLOR,clrYellow); 
         total_S_lvl_h4 = 3;
         nextSellCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      }
      if(total_S_lvl_h4 == 3 && TimeCurrent() > nextSellCheck_h4){
         h1_sellLvl_4 = initialH4_close;
         startTime_h4Sell = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_slvl_4",OBJ_TREND,0,startTime_h4Sell,h4_sellLvl_4,TimeCurrent(),h4_sellLvl_4);
         ObjectSetInteger(0,"h4_slvl_4",OBJPROP_COLOR,clrYellow); 
         total_S_lvl_h4 = 4;
         nextSellCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      } 
      if(total_S_lvl_h4 == 4 && TimeCurrent() > nextSellCheck_h4){
         h4_sellLvl_5 = initialH4_close;
         startTime_h4Sell = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_slvl_5",OBJ_TREND,0,startTime_h4Sell,h4_sellLvl_5,TimeCurrent(),h4_sellLvl_5);
         ObjectSetInteger(0,"h4_slvl_5",OBJPROP_COLOR,clrYellow); 
         total_S_lvl_h4 = 5;
         nextSellCheck_h1 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      }                                    
   }

//---
   
   if(total_S_lvl_h4 == 1){
      if(currentTick.bid > h4_sellLvl_1){ObjectDelete(0,"h4_slvl_1"); total_S_lvl_h4=0; h4_sellLvl_1=0; h4_s1_sgnl=0;}
   }
   if(total_S_lvl_h4 == 2){     
      if(currentTick.bid > h4_sellLvl_2){ObjectDelete(0,"h4_slvl_2"); total_S_lvl_h4=1; h4_sellLvl_2=0;}
   }
   if(total_S_lvl_h4 == 3){      
      if(currentTick.bid > h4_sellLvl_3){ObjectDelete(0,"h4_slvl_3"); total_S_lvl_h4=2; h4_sellLvl_3=0;}
   } 
   if(total_S_lvl_h4 == 4){      
      if(currentTick.bid > h4_sellLvl_4){ObjectDelete(0,"h4_slvl_4"); total_S_lvl_h4=3; h4_sellLvl_4=0;}
   }
   if(total_S_lvl_h4 == 5){      
      if(currentTick.bid > h4_sellLvl_5){ObjectDelete(0,"h4_slvl_5"); total_S_lvl_h4=4; h4_sellLvl_5=0;}
   } 
 
//---
    
   ObjectSetInteger(0,"h4_slvl_1",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_slvl_2",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_slvl_3",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_slvl_4",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_slvl_5",OBJPROP_TIME,1,TimeCurrent());   
 

   //Comment("h4_selllv_1: ",h4_sellLvl_1,"\nh4_sellLvl_2: ",h4_sellLvl_2,"\ntotal s h4: ",total_S_lvl_h4,"\nnext sell check h4: ",nextSellCheck_h4,"\nstart time h4: ",startTime_h4Sell);
 
 


//=== H4 BUY ==================================================================================================================================================================//

   if(initialH4_open > initialH4_close && moveSize_h4 > minMove_Points_h4*_Point && currentTick.bid > initialH4_close && startBar_close_h4 > startBar_open_h4){
      if(total_B_lvl_h4 == 0 && TimeCurrent() > nextBuyCheck_h4){
         h4_buyLvl_1 = initialH4_close;
         startTime_h4Buy = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_blvl_1",OBJ_TREND,0,startTime_h4Buy,h4_buyLvl_1,TimeCurrent(),h4_buyLvl_1);
         ObjectSetInteger(0,"h4_blvl_1",OBJPROP_COLOR,clrGold);
         total_B_lvl_h4 = 1;
         nextBuyCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;
      }
      if(total_B_lvl_h4 == 1 && TimeCurrent() > nextBuyCheck_h4){
         h4_buyLvl_2 = initialH4_close;
         startTime_h4Buy = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_blvl_2",OBJ_TREND,0,startTime_h4Buy,h4_buyLvl_2,TimeCurrent(),h4_buyLvl_2);
         ObjectSetInteger(0,"h4_blvl_2",OBJPROP_COLOR,clrGold);
         total_B_lvl_h4 = 2;
         nextBuyCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      }
      if(total_B_lvl_h4 == 2 && TimeCurrent() > nextBuyCheck_h4){
         h4_buyLvl_3 = initialH4_close;
         startTime_h4Buy = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_blvl_3",OBJ_TREND,0,startTime_h4Buy,h4_buyLvl_3,TimeCurrent(),h4_buyLvl_3);
         ObjectSetInteger(0,"h4_blvl_3",OBJPROP_COLOR,clrGold);
         total_B_lvl_h4 = 3;
         nextBuyCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      }
      if(total_B_lvl_h4 == 3 && TimeCurrent() > nextBuyCheck_h4){
         h4_buyLvl_4 = initialH4_close;
         startTime_h4Buy = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_blvl_4",OBJ_TREND,0,startTime_h4Buy,h4_buyLvl_4,TimeCurrent(),h4_buyLvl_4);
         ObjectSetInteger(0,"h4_blvl_4",OBJPROP_COLOR,clrGold);
         total_B_lvl_h4 = 4;
         nextBuyCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      } 
      if(total_B_lvl_h4 == 4 && TimeCurrent() > nextBuyCheck_h4){
         h4_buyLvl_5 = initialH4_close;
         startTime_h4Buy = TimeCurrent() - PeriodSeconds(PERIOD_H4)*InpLookBack;
         ObjectCreate(0,"h4_blvl_4",OBJ_TREND,0,startTime_h4Buy,h4_buyLvl_5,TimeCurrent(),h4_buyLvl_5);
         ObjectSetInteger(0,"h4_blvl_5",OBJPROP_COLOR,clrGold);
         total_B_lvl_h4 = 5;
         nextBuyCheck_h4 = TimeCurrent() + PeriodSeconds(PERIOD_H4)*5;         
      }                                    
   }

 
//---
   
   if(total_B_lvl_h4 == 1){
      if(currentTick.bid < h4_buyLvl_1){ObjectDelete(0,"h4_blvl_1"); total_B_lvl_h4=0; h4_buyLvl_1=0;}
   }
   if(total_B_lvl_h4 == 2){     
      if(currentTick.bid < h4_buyLvl_2){ObjectDelete(0,"h4_blvl_2"); total_B_lvl_h4=1; h4_buyLvl_2=0;}
   }
   if(total_B_lvl_h4 == 3){      
      if(currentTick.bid < h4_buyLvl_3){ObjectDelete(0,"h4_blvl_3"); total_B_lvl_h4=2; h4_buyLvl_3=0;}
   } 
   if(total_B_lvl_h4 == 4){      
      if(currentTick.bid < h4_buyLvl_4){ObjectDelete(0,"h4_blvl_4"); total_B_lvl_h4=3; h4_buyLvl_4=0;}
   }
   if(total_B_lvl_h4 == 5){      
      if(currentTick.bid < h4_buyLvl_5){ObjectDelete(0,"h4_blvl_5"); total_B_lvl_h4=4; h4_buyLvl_5=0;} 
   }
   ObjectSetInteger(0,"h4_blvl_1",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_blvl_2",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_blvl_3",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_blvl_4",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"h4_blvl_5",OBJPROP_TIME,1,TimeCurrent());  
 




//=== D1 SELL =================================================================================================================================================================//

   if(initialD1_open < initialD1_close && moveSize_d1 > minMove_Points_d1*_Point && currentTick.bid < initialD1_close && startBar_close_d1 < startBar_open_d1){
      if(total_S_lvl_d1 == 0 && TimeCurrent() > nextSellCheck_d1){
         d1_sellLvl_1 = initialD1_close;
         startTime_d1Sell = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_slvl_1",OBJ_TREND,0,startTime_d1Sell,d1_sellLvl_1,TimeCurrent(),d1_sellLvl_1);
         ObjectSetInteger(0,"d1_slvl_1",OBJPROP_COLOR,clrBlue);
         total_S_lvl_d1 = 1;
         nextSellCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;
      }
      if(total_S_lvl_d1 == 1 && TimeCurrent() > nextSellCheck_d1){
         d1_sellLvl_2 = initialD1_close;
         startTime_d1Sell = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"s1_slvl_2",OBJ_TREND,0,startTime_d1Sell,d1_sellLvl_2,TimeCurrent(),d1_sellLvl_2);
         ObjectSetInteger(0,"d1_slvl_2",OBJPROP_COLOR,clrBlue);
         total_S_lvl_d1 = 2;
         nextSellCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      }
      if(total_S_lvl_d1 == 2 && TimeCurrent() > nextSellCheck_d1){
         d1_sellLvl_3 = initialD1_close;
         startTime_d1Sell = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_slvl_3",OBJ_TREND,0,startTime_d1Sell,d1_sellLvl_3,TimeCurrent(),d1_sellLvl_3);
         ObjectSetInteger(0,"d1_slvl_3",OBJPROP_COLOR,clrBlue);
         total_S_lvl_d1 = 3;
         nextSellCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      }
      if(total_S_lvl_d1 == 3 && TimeCurrent() > nextSellCheck_d1){
         d1_sellLvl_4 = initialD1_close;
         startTime_d1Sell = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_slvl_4",OBJ_TREND,0,startTime_d1Sell,d1_sellLvl_4,TimeCurrent(),d1_sellLvl_4);
         ObjectSetInteger(0,"d1_slvl_4",OBJPROP_COLOR,clrBlue);
         total_S_lvl_d1 = 4;
         nextSellCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      } 
      if(total_S_lvl_d1 == 4 && TimeCurrent() > nextSellCheck_d1){
         d1_sellLvl_5 = initialD1_close;
         startTime_d1Sell = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_slvl_5",OBJ_TREND,0,startTime_d1Sell,d1_sellLvl_5,TimeCurrent(),d1_sellLvl_5);
         ObjectSetInteger(0,"d1_slvl_5",OBJPROP_COLOR,clrBlue); 
         total_S_lvl_d1 = 5;
         nextSellCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      }                                    
   }
 
//---
   
   if(total_S_lvl_d1 == 1){
      if(currentTick.bid > d1_sellLvl_1){ObjectDelete(0,"d1_slvl_1"); total_S_lvl_d1=0; d1_sellLvl_1=0;}
   }
   if(total_S_lvl_d1 == 2){     
      if(currentTick.bid > d1_sellLvl_2){ObjectDelete(0,"d1_slvl_2"); total_S_lvl_d1=1; d1_sellLvl_2=0;}
   }
   if(total_S_lvl_d1 == 3){      
      if(currentTick.bid > d1_sellLvl_3){ObjectDelete(0,"d1_slvl_3"); total_S_lvl_d1=2; d1_sellLvl_3=0;}
   } 
   if(total_S_lvl_d1 == 4){      
      if(currentTick.bid > d1_sellLvl_4){ObjectDelete(0,"d1_slvl_4"); total_S_lvl_d1=3; d1_sellLvl_4=0;}
   }
   if(total_S_lvl_d1 == 5){      
      if(currentTick.bid > d1_sellLvl_5){ObjectDelete(0,"d1_slvl_5"); total_S_lvl_d1=4; d1_sellLvl_5=0;}
   } 
 
//---
    
   ObjectSetInteger(0,"d1_slvl_1",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_slvl_2",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_slvl_3",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_slvl_4",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_slvl_5",OBJPROP_TIME,1,TimeCurrent());    
   





//=== D1 BUY ==================================================================================================================================================================//

   if(initialD1_open > initialD1_close && moveSize_d1 > minMove_Points_d1*_Point && currentTick.bid > initialD1_close && startBar_close_d1 > startBar_open_d1){
      if(total_B_lvl_d1 == 0 && TimeCurrent() > nextBuyCheck_d1){
         d1_buyLvl_1 = initialD1_close;
         startTime_d1Buy = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_blvl_1",OBJ_TREND,0,startTime_d1Buy,d1_buyLvl_1,TimeCurrent(),d1_buyLvl_1);
         ObjectSetInteger(0,"d1_blvl_1",OBJPROP_COLOR,clrAqua);
         total_B_lvl_d1 = 1;
         nextBuyCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;
      }
      if(total_B_lvl_d1 == 1 && TimeCurrent() > nextBuyCheck_d1){
         d1_buyLvl_2 = initialD1_close;
         startTime_h1Buy = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_blvl_2",OBJ_TREND,0,startTime_d1Buy,d1_buyLvl_2,TimeCurrent(),d1_buyLvl_2);
         ObjectSetInteger(0,"d1_blvl_2",OBJPROP_COLOR,clrAqua);
         total_B_lvl_d1 = 2;
         nextBuyCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      }
      if(total_B_lvl_d1 == 2 && TimeCurrent() > nextBuyCheck_d1){
         d1_buyLvl_3 = initialD1_close;
         startTime_d1Buy = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_blvl_3",OBJ_TREND,0,startTime_d1Buy,d1_buyLvl_3,TimeCurrent(),d1_buyLvl_3);
         ObjectSetInteger(0,"d1_blvl_3",OBJPROP_COLOR,clrAqua);
         total_B_lvl_d1 = 3;
         nextBuyCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      }
      if(total_B_lvl_d1 == 3 && TimeCurrent() > nextBuyCheck_d1){
         d1_buyLvl_4 = initialD1_close;
         startTime_d1Buy = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_blvl_4",OBJ_TREND,0,startTime_d1Buy,d1_buyLvl_4,TimeCurrent(),d1_buyLvl_4);
         ObjectSetInteger(0,"d1_blvl_4",OBJPROP_COLOR,clrAqua);
         total_B_lvl_d1 = 4;
         nextBuyCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      } 
      if(total_B_lvl_d1 == 4 && TimeCurrent() > nextBuyCheck_h1){
         h1_buyLvl_5 = initialD1_close;
         startTime_d1Buy = TimeCurrent() - PeriodSeconds(PERIOD_D1)*InpLookBack;
         ObjectCreate(0,"d1_blvl_4",OBJ_TREND,0,startTime_d1Buy,d1_buyLvl_5,TimeCurrent(),d1_buyLvl_5);
         ObjectSetInteger(0,"d1_blvl_5",OBJPROP_COLOR,clrAqua);
         total_B_lvl_d1 = 5;
         nextBuyCheck_d1 = TimeCurrent() + PeriodSeconds(PERIOD_D1)*5;         
      }                                    
   }

 
//---
   
   if(total_B_lvl_d1 == 1){
      if(currentTick.bid < d1_buyLvl_1){ObjectDelete(0,"d1_blvl_1"); total_B_lvl_d1=0; d1_buyLvl_1=0;}
   }
   if(total_B_lvl_d1 == 2){     
      if(currentTick.bid < d1_buyLvl_2){ObjectDelete(0,"d1_blvl_2"); total_B_lvl_d1=1; d1_buyLvl_2=0;}
   }
   if(total_B_lvl_d1 == 3){      
      if(currentTick.bid < d1_buyLvl_3){ObjectDelete(0,"d1_blvl_3"); total_B_lvl_d1=2; d1_buyLvl_3=0;}
   } 
   if(total_B_lvl_d1 == 4){      
      if(currentTick.bid < d1_buyLvl_4){ObjectDelete(0,"d1_blvl_4"); total_B_lvl_d1=3; d1_buyLvl_4=0;}
   }
   if(total_B_lvl_d1 == 5){      
      if(currentTick.bid < d1_buyLvl_5){ObjectDelete(0,"d1_blvl_5"); total_B_lvl_d1=4; d1_buyLvl_5=0;}
   }    
   
   ObjectSetInteger(0,"d1_blvl_1",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_blvl_2",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_blvl_3",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_blvl_4",OBJPROP_TIME,1,TimeCurrent());   
   ObjectSetInteger(0,"d1_blvl_5",OBJPROP_TIME,1,TimeCurrent());     
   
//---


   //pivot threshold zones
   pp_top   = pivotPoint + entry_threshold;
   pp_btm   = pivotPoint - entry_threshold;
   r1_top   = r1 + entry_threshold;
   r1_btm   = r1 - entry_threshold;
   s1_top   = s1 + entry_threshold;
   s1_btm   = s1 - entry_threshold;
   r2_top   = r2 + entry_threshold;
   r2_btm   = r2 - entry_threshold;
   s2_top   = s2 + entry_threshold;
   s2_btm   = s2 - entry_threshold;
   r3_top   = r3 + entry_threshold;
   r3_btm   = r3 - entry_threshold;
   s3_top   = s3 + entry_threshold;
   s3_btm   = s3 - entry_threshold;  
   
   //level proximity threshold, max position
      


//=== H1 BUY ENTRY SIGNAL ==================================================================================================================//

//--- h1 buy level 1
   if((total_B_lvl_h1 == 1 && h1_buyLvl_1 > r1_btm && h1_buyLvl_1 < r1_top) || 
      (total_B_lvl_h1 == 1 && h1_buyLvl_1 > r2_btm && h1_buyLvl_1 < r2_top) ||
      (total_B_lvl_h1 == 1 && h1_buyLvl_1 > r3_btm && h1_buyLvl_1 < r3_top)
      ){h1_b1_sgnl=1;}
   if(h1_b1_sgnl==1){    
      SL = h1_buyLvl_1 - slPoints;
      if(InpLotType == ENUM_PERC){lotSize = calcLots(InpRisk,slPoints);}
      else{lotSize = InpLotSize;}
      if(InpProfitTarget == ENUM_REWARD){tpSize = slPoints*InpRiskReward; TP = h1_buyLvl_1 + tpSize;}
      else{TP = h1_buyLvl_1 + tpPoints;}
      if(currentTick.bid <= h1_buyLvl_1 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h1_b1");h1_b1_cnt=1;h1_b1_tp=TP;h1_b1_sgnl=0;}   
   }
   if(currentTick.bid >= h1_b1_tp){h1_b1_cnt=0;h1_b1_tp=0;}
//--- h1 buy level 2
   if((total_B_lvl_h1 == 2 && h1_buyLvl_2 > r1_btm && h1_buyLvl_1 < r1_top) || 
      (total_B_lvl_h1 == 2 && h1_buyLvl_2 > r2_btm && h1_buyLvl_1 < r2_top) ||
      (total_B_lvl_h1 == 2 && h1_buyLvl_2 > r3_btm && h1_buyLvl_1 < r3_top)
      ){h1_b2_sgnl = 1;}   
   if(h1_b2_sgnl == 1){
//      if(stopLevelCheck(h1_buyLvl_2,h1_buyLvl_1) > 0){slPoints = stopLevelCheck(h1_buyLvl_2,h1_buyLvl_1) + 100*_Point; SL = h1_buyLvl_2 - slPoints;}
//      else{SL = h1_buyLvl_2 - slPoints;}
//      
//      if(InpLotType == ENUM_PERC){lotSize = calcLots(InpRisk,slPoints);}
//      else{lotSize = InpLotSize;}
//      
//      if(InpProfitTarget == ENUM_REWARD){tpSize = slPoints*InpRiskReward; TP = h1_buyLvl_2 + tpSize;}
//      else{TP = h1_buyLvl_2 + tpPoints;}
      tradeParameters(h1_buyLvl_2,h1_buyLvl_1);

      if(currentTick.bid <= h1_buyLvl_2 && cntBuy==0){
         trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h1_b2");
         h1_b2_cnt=1;
         h1_b2_tp=TP;
      }    
   }
   if(currentTick.bid >= h1_b2_tp){h1_b2_cnt=0;h1_b2_tp=0;}

//--- h1 buy level 3
   if((total_B_lvl_h1 == 3 && h1_buyLvl_3 > r1_btm && h1_buyLvl_1 < r1_top) || 
      (total_B_lvl_h1 == 3 && h1_buyLvl_3 > r2_btm && h1_buyLvl_1 < r2_top) ||
      (total_B_lvl_h1 == 3 && h1_buyLvl_3 > r3_btm && h1_buyLvl_1 < r3_top)
      ){h1_b3_sgnl = 1;}
   if(h1_b3_sgnl == 1){
      tradeParameters(h1_buyLvl_3,h1_buyLvl_2); 
      if(currentTick.bid <= h1_buyLvl_3 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h1_b3");h1_b3_cnt=1;h1_b3_tp=TP;}   
   }
//--- h1 buy level 4
   if((total_B_lvl_h1 == 4 && h1_buyLvl_4 > r1_btm && h1_buyLvl_1 < r1_top) || 
      (total_B_lvl_h1 == 4 && h1_buyLvl_4 > r2_btm && h1_buyLvl_1 < r2_top) ||
      (total_B_lvl_h1 == 4 && h1_buyLvl_4 > r3_btm && h1_buyLvl_1 < r3_top)
      ){h1_b4_sgnl = 1;}
   if(h1_b4_sgnl == 1){
      tradeParameters(h1_buyLvl_4,h1_buyLvl_3); 
      if(currentTick.bid <= h1_buyLvl_4 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h1_b4");h1_b4_cnt=1;h1_b4_tp=TP;}   
   }
//--- h1 buy level 5
   if((total_B_lvl_h1 == 5 && h1_buyLvl_5 > r1_btm && h1_buyLvl_1 < r1_top) || 
      (total_B_lvl_h1 == 5 && h1_buyLvl_5 > r2_btm && h1_buyLvl_1 < r2_top) ||
      (total_B_lvl_h1 == 5 && h1_buyLvl_5 > r3_btm && h1_buyLvl_1 < r3_top)
      ){h1_b5_sgnl = 1;}
   if(h1_b5_sgnl == 1){
      tradeParameters(h1_buyLvl_5,h1_buyLvl_4); 
      if(currentTick.bid <= h1_buyLvl_5 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h1_b5");h1_b5_cnt=1;h1_b5_tp=TP;}   
   } 
   



   
//=== H1 SELL ENTRY SIGNAL ================================================================================================================//

//--- h1 sell level 1
   if((total_S_lvl_h1 == 1 && h1_sellLvl_1 > r1_btm && h1_sellLvl_1 < r1_top) || 
      (total_S_lvl_h1 == 1 && h1_sellLvl_1 > r2_btm && h1_sellLvl_1 < r2_top) ||
      (total_S_lvl_h1 == 1 && h1_sellLvl_1 > r3_btm && h1_sellLvl_1 < r3_top)
      ){h1_s1_sgnl=1;}
   if(h1_s1_sgnl==1){    
      SL = h1_sellLvl_1 + slPoints;
      if(InpLotType == ENUM_PERC){lotSize = calcLots(InpRisk,slPoints);}
      else{lotSize = InpLotSize;}
      if(InpProfitTarget == ENUM_REWARD){tpSize = slPoints*InpRiskReward; TP = h1_sellLvl_1 - tpSize;}
      else{TP = h1_sellLvl_1 - tpPoints;}
      if(currentTick.bid >= h1_sellLvl_1 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h1_s1");h1_s1_cnt=1;h1_s1_tp=TP;h1_s1_sgnl=0;}   
   }
   if(currentTick.bid >= h1_s1_tp){h1_s1_cnt=0;h1_s1_tp=0;}
//--- h1 sell level 2
   if((total_S_lvl_h1 == 2 && h1_sellLvl_2 > r1_btm && h1_sellLvl_1 < r1_top) || 
      (total_S_lvl_h1 == 2 && h1_sellLvl_2 > r2_btm && h1_sellLvl_1 < r2_top) ||
      (total_S_lvl_h1 == 2 && h1_sellLvl_2 > r3_btm && h1_sellLvl_1 < r3_top)
      ){h1_s2_sgnl = 1;}   
   if(h1_s2_sgnl == 1){
      tradeParameters(h1_sellLvl_2,h1_sellLvl_1);

      if(currentTick.bid <= h1_sellLvl_2 && cntSell==0){
         trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h1_s2");
         h1_s2_cnt=1;
         h1_s2_tp=TP;
      }    
   }
   if(currentTick.bid >= h1_s2_tp){h1_s2_cnt=0;h1_s2_tp=0;}

//--- h1 sell level 3
   if((total_S_lvl_h1 == 3 && h1_sellLvl_3 > r1_btm && h1_sellLvl_1 < r1_top) || 
      (total_S_lvl_h1 == 3 && h1_sellLvl_3 > r2_btm && h1_sellLvl_1 < r2_top) ||
      (total_S_lvl_h1 == 3 && h1_sellLvl_3 > r3_btm && h1_sellLvl_1 < r3_top)
      ){h1_s3_sgnl = 1;}
   if(h1_s3_sgnl == 1){
      tradeParameters(h1_sellLvl_3,h1_sellLvl_2); 
      if(currentTick.bid <= h1_sellLvl_3 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h1_s3");h1_s3_cnt=1;h1_s3_tp=TP;}   
   }
//--- h1 sell level 4
   if((total_S_lvl_h1 == 4 && h1_sellLvl_4 > r1_btm && h1_sellLvl_1 < r1_top) || 
      (total_S_lvl_h1 == 4 && h1_sellLvl_4 > r2_btm && h1_sellLvl_1 < r2_top) ||
      (total_S_lvl_h1 == 4 && h1_sellLvl_4 > r3_btm && h1_sellLvl_1 < r3_top)
      ){h1_s4_sgnl = 1;}
   if(h1_s4_sgnl == 1){
      tradeParameters(h1_sellLvl_4,h1_sellLvl_3); 
      if(currentTick.bid <= h1_sellLvl_4 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h1_s4");h1_s4_cnt=1;h1_s4_tp=TP;}   
   }
//--- h1 sell level 5
   if((total_S_lvl_h1 == 5 && h1_sellLvl_5 > r1_btm && h1_sellLvl_1 < r1_top) || 
      (total_S_lvl_h1 == 5 && h1_sellLvl_5 > r2_btm && h1_sellLvl_1 < r2_top) ||
      (total_S_lvl_h1 == 5 && h1_sellLvl_5 > r3_btm && h1_sellLvl_1 < r3_top)
      ){h1_s5_sgnl = 1;}
   if(h1_s5_sgnl == 1){
      tradeParameters(h1_sellLvl_5,h1_sellLvl_4); 
      if(currentTick.bid <= h1_sellLvl_5 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h1_s5");h1_s5_cnt=1;h1_s5_tp=TP;}   
   }   
   
   
   
   
//=== H4 BUY ENTRY SIGNAL ==================================================================================================================//

//--- h4 buy level 1
   if((total_B_lvl_h4 == 1 && h4_buyLvl_1 > r1_btm && h4_buyLvl_1 < r1_top) || 
      (total_B_lvl_h4 == 1 && h4_buyLvl_1 > r2_btm && h4_buyLvl_1 < r2_top) ||
      (total_B_lvl_h4 == 1 && h4_buyLvl_1 > r3_btm && h4_buyLvl_1 < r3_top)
      ){h4_b1_sgnl=1;}
   if(h4_b1_sgnl==1){    
      SL = h4_buyLvl_1 - slPoints;
      if(InpLotType == ENUM_PERC){lotSize = calcLots(InpRisk,slPoints);}
      else{lotSize = InpLotSize;}
      if(InpProfitTarget == ENUM_REWARD){tpSize = slPoints*InpRiskReward; TP = h4_buyLvl_1 + tpSize;}
      else{TP = h4_buyLvl_1 + tpPoints;}
      if(currentTick.bid <= h4_buyLvl_1 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h4_b1");h4_b1_cnt=1;h4_b1_tp=TP;h4_b1_sgnl=0;}   
   }
   if(currentTick.bid >= h4_b1_tp){h4_b1_cnt=0;h4_b1_tp=0;}
//--- h4 buy level 2
   if((total_B_lvl_h4 == 2 && h4_buyLvl_2 > r1_btm && h4_buyLvl_1 < r1_top) || 
      (total_B_lvl_h4 == 2 && h4_buyLvl_2 > r2_btm && h4_buyLvl_1 < r2_top) ||
      (total_B_lvl_h4 == 2 && h4_buyLvl_2 > r3_btm && h4_buyLvl_1 < r3_top)
      ){h4_b2_sgnl = 1;}   
   if(h4_b2_sgnl == 1){
      tradeParameters(h4_buyLvl_2,h4_buyLvl_1);
      if(currentTick.bid <= h4_buyLvl_2 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h4_b2");h4_b2_cnt=1;h4_b2_tp=TP;}    
   }
   if(currentTick.bid >= h4_b2_tp){h4_b2_cnt=0;h4_b2_tp=0;}

//--- h4 buy level 3
   if((total_B_lvl_h4 == 3 && h4_buyLvl_3 > r1_btm && h4_buyLvl_1 < r1_top) || 
      (total_B_lvl_h4 == 3 && h4_buyLvl_3 > r2_btm && h4_buyLvl_1 < r2_top) ||
      (total_B_lvl_h4 == 3 && h4_buyLvl_3 > r3_btm && h4_buyLvl_1 < r3_top)
      ){h4_b3_sgnl = 1;}
   if(h4_b3_sgnl == 1){
      tradeParameters(h4_buyLvl_3,h4_buyLvl_2); 
      if(currentTick.bid <= h4_buyLvl_3 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h4_b3");h4_b3_cnt=1;h4_b3_tp=TP;}   
   }
//--- h4 buy level 4
   if((total_B_lvl_h4 == 4 && h4_buyLvl_4 > r1_btm && h4_buyLvl_1 < r1_top) || 
      (total_B_lvl_h4 == 4 && h4_buyLvl_4 > r2_btm && h4_buyLvl_1 < r2_top) ||
      (total_B_lvl_h4 == 4 && h4_buyLvl_4 > r3_btm && h4_buyLvl_1 < r3_top)
      ){h4_b4_sgnl = 1;}
   if(h4_b4_sgnl == 1){
      tradeParameters(h4_buyLvl_4,h4_buyLvl_3); 
      if(currentTick.bid <= h4_buyLvl_4 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h4_b4");h4_b4_cnt=1;h4_b4_tp=TP;}   
   }
//--- h4 buy level 5
   if((total_B_lvl_h4 == 5 && h4_buyLvl_5 > r1_btm && h4_buyLvl_1 < r1_top) || 
      (total_B_lvl_h4 == 5 && h4_buyLvl_5 > r2_btm && h4_buyLvl_1 < r2_top) ||
      (total_B_lvl_h4 == 5 && h4_buyLvl_5 > r3_btm && h4_buyLvl_1 < r3_top)
      ){h4_b5_sgnl = 1;}
   if(h4_b5_sgnl == 1){
      tradeParameters(h4_buyLvl_5,h4_buyLvl_4); 
      if(currentTick.bid <= h4_buyLvl_5 && cntBuy==0){trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,"h4_b5");h4_b5_cnt=1;h4_b5_tp=TP;}   
   }    
   



//=== H1 SELL ENTRY SIGNAL ================================================================================================================//

//--- h4 sell level 1
   if((total_S_lvl_h4 == 1 && h4_sellLvl_1 > r1_btm && h4_sellLvl_1 < r1_top) || 
      (total_S_lvl_h4 == 1 && h4_sellLvl_1 > r2_btm && h4_sellLvl_1 < r2_top) ||
      (total_S_lvl_h4 == 1 && h4_sellLvl_1 > r3_btm && h4_sellLvl_1 < r3_top)
      ){h4_s1_sgnl=1;}
   if(h4_s1_sgnl==1){    
      SL = h4_sellLvl_1 + slPoints;
      if(InpLotType == ENUM_PERC){lotSize = calcLots(InpRisk,slPoints);}
      else{lotSize = InpLotSize;}
      if(InpProfitTarget == ENUM_REWARD){tpSize = slPoints*InpRiskReward; TP = h4_sellLvl_1 - tpSize;}
      else{TP = h4_sellLvl_1 - tpPoints;}
      if(currentTick.bid >= h4_sellLvl_1 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h4_s1");h4_s1_cnt=1;h4_s1_tp=TP;h4_s1_sgnl=0;}   
   }
   if(currentTick.bid < h4_s1_tp){h4_s1_cnt=0;h4_s1_tp=0;}

//--- h4 sell level 2
   if((total_S_lvl_h4 == 2 && h4_sellLvl_2 > r1_btm && h4_sellLvl_1 < r1_top) || 
      (total_S_lvl_h4 == 2 && h4_sellLvl_2 > r2_btm && h4_sellLvl_1 < r2_top) ||
      (total_S_lvl_h4 == 2 && h4_sellLvl_2 > r3_btm && h4_sellLvl_1 < r3_top)
      ){h4_s2_sgnl = 1;}   
   if(h4_s2_sgnl == 1){
      tradeParameters(h4_sellLvl_2,h4_sellLvl_1);

      if(currentTick.bid <= h4_sellLvl_2 && cntSell==0){
         trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h4_s2");
         h4_s2_cnt=1;
         h4_s2_tp=TP;
      }    
   }
   if(currentTick.bid >= h4_s2_tp){h4_s2_cnt=0;h4_s2_tp=0;}

//--- h4 sell level 3
   if((total_S_lvl_h4 == 3 && h4_sellLvl_3 > r1_btm && h4_sellLvl_1 < r1_top) || 
      (total_S_lvl_h4 == 3 && h4_sellLvl_3 > r2_btm && h4_sellLvl_1 < r2_top) ||
      (total_S_lvl_h4 == 3 && h4_sellLvl_3 > r3_btm && h4_sellLvl_1 < r3_top)
      ){h4_s3_sgnl = 1;}
   if(h4_s3_sgnl == 1){
      tradeParameters(h4_sellLvl_3,h4_sellLvl_2); 
      if(currentTick.bid <= h4_sellLvl_3 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h4_s3");h4_s3_cnt=1;h4_s3_tp=TP;}   
   }
//--- h4 sell level 4
   if((total_S_lvl_h4 == 4 && h4_sellLvl_4 > r1_btm && h4_sellLvl_1 < r1_top) || 
      (total_S_lvl_h4 == 4 && h4_sellLvl_4 > r2_btm && h4_sellLvl_1 < r2_top) ||
      (total_S_lvl_h4 == 4 && h4_sellLvl_4 > r3_btm && h4_sellLvl_1 < r3_top)
      ){h4_s4_sgnl = 1;}
   if(h4_s4_sgnl == 1){
      tradeParameters(h4_sellLvl_4,h4_sellLvl_3); 
      if(currentTick.bid <= h4_sellLvl_4 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h4_s4");h4_s4_cnt=1;h4_s4_tp=TP;}   
   }
//--- h4 sell level 5
   if((total_S_lvl_h4 == 5 && h4_sellLvl_5 > r1_btm && h4_sellLvl_1 < r1_top) || 
      (total_S_lvl_h4 == 5 && h4_sellLvl_5 > r2_btm && h4_sellLvl_1 < r2_top) ||
      (total_S_lvl_h4 == 5 && h4_sellLvl_5 > r3_btm && h4_sellLvl_1 < r3_top)
      ){h4_s5_sgnl = 1;}
   if(h4_s5_sgnl == 1){
      tradeParameters(h4_sellLvl_5,h4_sellLvl_4); 
      if(currentTick.bid <= h4_sellLvl_5 && cntSell==0){trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,"h4_s5");h4_s5_cnt=1;h4_s5_tp=TP;}   
   }  
   



//=== BREAK EVEN CHECK ==========================================================================================================================//

   //Get ask and bid price
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);


   //---Moving-SL-to-Breakeven----------   
   checkBreakEvenStopBuy(ask);
   checkBreakEvenStopSell(bid);     
   
           
}




//+------------------------------------------------------------------+
//|   custom functions
//+------------------------------------------------------------------+

void pivotpoints(string objName, color clr, datetime startTime, double price, datetime endTime){
   ObjectCreate(0,objName,OBJ_TREND,0,startTime,price,endTime,price);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
}

void atrChart(string objName, color clr, datetime startTime, double price, datetime endTime){
   ObjectCreate(0,objName,OBJ_TREND,0,startTime,price,endTime,price);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
}



double stopLevelCheck(double level1, double level2){
   double levelDistance = 0;
   if(level1 - level2 > 0){levelDistance = level1 - level2;}
   if(level2 - level1 > 0){levelDistance = level2 - level1;}
   //double distThresh = 600*_Point;
   //if(levelDistance <= distThresh){   
   if(levelDistance <= stop_threshold){
      return levelDistance;   
   }
   return 0; 
}



void tradeParameters(double level1, double level2){
   if(InpSLDetect==true && stopLevelCheck(level1,level2) > 0){slPoints = stopLevelCheck(level1,level2) + 100*_Point; SL = level1 - slPoints;}
   else{SL = level1 - slPoints;}
   
   if(InpLotType == ENUM_PERC){lotSize = calcLots(InpRisk,slPoints);}
   else{lotSize = InpLotSize;}
   
   if(InpProfitTarget == ENUM_REWARD){tpSize = slPoints*InpRiskReward; TP = level1 + tpSize;}
   else{TP = level1 + tpPoints;}
}



//===COUNT OPEN POSITIONS==================================================================================================//
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



//=== Calulate Lot Size for Percentage based risk ===============================================================//
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



//==TRADE TRANSACTION FUNCTION====================================================================================================//

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

      //if(h1_b1_cnt==1 && deal_entry==DEAL_ENTRY_IN && deal_type==DEAL_TYPE_BUY && deal_magic==InpMagicNumber){h1_b1_tkt=deal_ticket;h1_b1_tp=deal_tp;}
      //if(h1_b2_cnt==1 && deal_entry==DEAL_ENTRY_IN && deal_type==DEAL_TYPE_BUY && deal_magic==InpMagicNumber){h1_b2_tkt=deal_ticket;h1_b2_tp=deal_tp;}
      
      static double   todays_profit_loss;   
      datetime midnight;
      datetime now         = TimeCurrent(today);
      int      year        = today.year;
      int      month       = today.mon;
      int      day         = today.day;

      midnight = StringToTime(string(year)+"."+string(month)+"."+string(day)+" 00:00");
      HistorySelect(midnight,now);
      
      if(now == midnight+PeriodSeconds(PERIOD_D1)){
         todays_profit_loss = 0.0;
      }         
      if(deal_entry==DEAL_ENTRY_OUT && deal_time > midnight){
         todays_profit_loss += (deal_profit - deal_commission);
      } 
      
               
   }   
}



//---Breakeven-BUY-function---------------------------+

void checkBreakEvenStopBuy(double ask){
   for(int i=PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      double currentSL = PositionGetDouble(POSITION_SL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      slSize = openPrice - currentSL;
      tpSize = slSize * InpRiskReward;
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL > openPrice - slPoints){
         return;
      }
      
      else if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         //double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double BEbuyTP = openPrice + tpSize;
         if(ask > (openPrice + bePoints)){
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
      slSize = currentSL - openPrice;
      tpSize = slSize * InpRiskReward;      
      if(InpBreakeven <= 0){
         return;
      }
      
      else if(currentSL < openPrice + slPoints){
         return;
      }
      
      else if(_Symbol==symbol){
         ulong positionTicket = PositionGetInteger(POSITION_TICKET);
         //double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double BEsellTP = openPrice - tpSize;
         if(bid < (openPrice - bePoints)){
            trade.PositionModify(positionTicket,openPrice,BEsellTP);   
         }
      }
   }
}