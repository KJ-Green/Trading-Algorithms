//+------------------------------------------------------------------+
//|                                                  Wave Trader.mq5 |
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

enum t_direction
  {
   ENUM_REGULAR,  //Regular
   ENUM_REVERSE,  //Reverse
   ENUM_DYNAMIC   //Dynamic
  };
enum newsDetect
  {
   ENUM_AUTO,     //Auto Detect
   ENUM_MANUAL    //Manual Input
  };  

//+------------------------------------------------------------------+
//| Input Variables                                                                  
//+------------------------------------------------------------------+

input int            InpMagicNumber          =     2009867;       //Magic Number (Change If Opening on Multiple Charts)

input group          "TRADE SETTINGS"
input int            InpLookBack             =     70;            //Candle Look Back
input t_direction    InpTradeDirection       =     ENUM_REVERSE;  //Trade Mode  
input double         InpStartLot             =     0.01;          //Starting Lot Size
input double         InpLotMultiplier        =     1.1;           //Lot Size Multiplier
input bool           InpAutoLot              =     false;         //Use Auto Lot
input int            InpAutoLotPer           =     1000;          //(Auto Lot) Starting Lot Per: $
input int            InpGridStep             =     20;            //Grid Step (pips)
input int            InpGridSkip             =     0;             //Skip First x Trades in the Grid
input int            InpTakeProfit           =     50;            //Take Profit (pips)
input double         InpMaxLot               =     5;             //Max Lot Size
input int            InpMaxPoS               =     20;            //Max Positions In One Direction
input bool           InpHedge                =     true;          //Open Hedge Positions
input int            InpDynamicPips          =     100;           //Dynamic Mode Pip Size     

input group          "ACCOUNT PROTECTION SETTINGS"          
input double         InpDDpercent            =     0.0;           //Max Equity Drawdown %   
input int            InpDDbalance            =     0;             //Max Balance Drawdown $ 
input int            InpTrailingStart        =     20;            //Trailing Stop Start (pips)
input int            InpTrailingStep         =     10;            //Trailing Stop Step (pips)
input int            InpProfitClose          =     0;             //Close all Positions once profit reached: $

input group          "TRADE FILTER SETTINGS"
input bool           InpTrendFilter          =     false;         //Use Trend Filter
input ENUM_TIMEFRAMES   InpTrendTF           =     PERIOD_D1;     //Trend Filter Time Frame
input int            InpStartHour            =     0;             //Trading Time Start Hour (24hr)
input int            InpStartMin             =     0;             //Trading Time Start Minutes
input int            InpStopHour             =     0;             //Trading Time Stop Hour (24hr)
input int            InpStopMin              =     0;             //Trading Time Stop Minutes
input bool           InpTradeMon             =     true;          //Trade on Monday
input bool           InpTradeTue             =     true;          //Trade on Tuesday   
input bool           InpTradeWed             =     true;          //Trade on Wednesday
input bool           InpTradeThu             =     true;          //Trade on Thursday
input bool           InpTradeFri             =     true;          //Trade on Friday

input group          "NEWS MODE SETTINGS"
input bool           InpNewsMode             =     false;         //News Mode (stop trading for high impact news events)
input newsDetect     InpNewsDetect           =     ENUM_AUTO;     //Method of News Detection
input int            InpBeforeNews           =     240;           //Stop Trading Minutes Before News
input int            InpAfterNews            =     60;            //Resume Trading Minutes After News
input string         InpNewsNameOne          =     "";            //News Event Name 1
input string         InpNewsNameTwo          =     "";            //News Event Name 2
input string         InpNewsNameThree        =     "";            //News Event Name 3  
//+------------------------------------------------------------------+
//| Global Variables                                                                 
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

int         barsTotal;
double      TP, lotSize;

int         r_highBar, r_lowBar, r_highBar_time, r_lowBar_time;
static double      range_high           =  0.0; 
static double      range_low            =  0.0;
datetime    r_highTime, r_lowTime;

double      last_open_price      =  0.0;
double      last_volume          =  0.0;
int         last_position_type   =  -1;

double      last_volume_buy      =  0.0;
double      last_volume_sell     =  0.0;
double      last_open_price_buy  =  0.0;
double      last_open_price_sell =  0.0;

double      closeBuyPositions, closeSellPositions;
static double        nextBuyPrice;
static double        nextSellPrice;
static double        totalBuyPrice, totalSellPrice;
static double        totalBuyLots, totalSellLots;
static double        buyPrice, sellPrice;
static double        breakEvenLineBuy, breakEvenLineSell;
double      tpBuyLine, tpSellLine;

int         entryBuyCnt, entrySellCnt;
int         range_count;
int         ma_handle;
double      maBuffer[];


int         signal_highBar, signal_lowBar;
double      signal_highPrice, signal_lowPrice, signal_size;

datetime    event_time, news_stopTime, news_resumeTime;
datetime    event_time_mod, news_stopTime_mod, news_resumeTime_mod;
string      event_name, event_name_mod;
string      high_currency, mod_currency;
string      baseCurrency = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
string      secondaryCurrency = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
bool        stopTrade;

datetime    day_startTrade, day_stopTrade;
int         day_startSec, day_stopSec;

int         MON = 1;
int         TUE = 2;
int         WED = 3;
int         THU = 4;
int         FRI = 5;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   if(InpTakeProfit<=0){Alert("Take profit must be greater than 0...");return INIT_PARAMETERS_INCORRECT;}
   if(InpLookBack<=0){Alert("Look back must be greater that 0...");return INIT_PARAMETERS_INCORRECT;}
   if(InpStartLot<=0){Alert("Start lot must be 0.01 or greater...");return INIT_PARAMETERS_INCORRECT;}
   
   ma_handle = iMA(_Symbol,InpTrendTF,200,0,MODE_EMA,PRICE_CLOSE);
   
   ArraySetAsSeries(maBuffer,true);

   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   

   

   return(INIT_SUCCEEDED);
}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(ma_handle != INVALID_HANDLE){IndicatorRelease(ma_handle);}

}
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   if(!SymbolInfoTick(_Symbol,currentTick)){Print("Failed to get current tick.");return;}

//---


int         beforeNews_seconds = InpBeforeNews*60;
int         afterNews_seconds  = InpAfterNews*60;
int         signal_points      =  InpDynamicPips*10; //15000
int         point_TP           =  InpTakeProfit*10;
int         point_Grid         =  InpGridStep*10;
int         point_TStart       =  InpTrailingStart*10;
int         point_TStep        =  InpTrailingStep*10;


//---

   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);
   
   
//===TRADING START AND STOP TIMES=====================================================================================================//

   datetime startTimeDay   = iTime(_Symbol,PERIOD_D1,0);
   datetime endTimeDay     = startTimeDay + PeriodSeconds(PERIOD_D1);         
  
   if(InpStartHour > 0 || InpStartMin > 0 || InpStopHour > 0 || InpStopMin > 0){ 
   
      day_startSec   = (InpStartHour*60*60) + (InpStartMin*60);
      day_stopSec    = (InpStopHour*60*60) + (InpStopMin*60);
      
      day_startTrade = startTimeDay + day_startSec;
      day_stopTrade  = startTimeDay + day_stopSec;
      
      if(InpStartHour==0 && InpStartMin==0){day_startTrade=startTimeDay;}
      if(day_stopSec < day_startSec){day_stopTrade = day_stopTrade+PeriodSeconds(PERIOD_D1);}
      
      if(TimeCurrent() > day_startTrade){ // && TimeCurrent() < day_stopTrade
         stopTrade = false;
      }
      if(TimeCurrent() > day_stopTrade){ //&& TimeCurrent() < day_startTrade
         stopTrade = true;
      }
   }
   if(InpStartHour == 0 && InpStartMin == 0 && InpStopHour == 0 && InpStopMin == 0){    
      day_startTrade = startTimeDay;
      day_stopTrade = startTimeDay + PeriodSeconds(PERIOD_D1);
      stopTrade = false;
   }
    
   //Comment("start time dya: ",startTimeDay,"\nTimecurrent: ",TimeCurrent(),"\nstart trade: ",day_startTrade,"\nstop trade: ",day_stopTrade,"\n\nstop trade T/F: ",stopTrade);
   
   
   
   
   
//===CHECKING FOR NEWS EVENTS=========================================================================================================//   

   if(InpNewsMode==true){

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
         
         if(InpNewsDetect==ENUM_AUTO){
            if((country.currency == baseCurrency || country.currency == secondaryCurrency) ){
               
               if(event.importance == CALENDAR_IMPORTANCE_HIGH){
                  event_name = event.name;
                  high_currency = country.currency;
                  event_time = values[i].time;
                  news_stopTime = event_time - beforeNews_seconds;
                  news_resumeTime = event_time + afterNews_seconds;    
               }    
               if(event.importance == CALENDAR_IMPORTANCE_MODERATE){
                  event_name_mod = event.name;
                  mod_currency = country.currency;
                  event_time_mod = values[i].time;
                  news_stopTime_mod = event_time_mod - beforeNews_seconds;
                  news_resumeTime_mod = event_time_mod + afterNews_seconds;
               }      
            }
            
            if(TimeCurrent() >= news_stopTime && TimeCurrent() < news_resumeTime){
               stopTrade = true;
            }
            if(TimeCurrent() >= news_resumeTime && TimeCurrent() < news_stopTime){
               stopTrade = false;
            }  
         }
         if(InpNewsDetect==ENUM_MANUAL){
            if(event.name==InpNewsNameOne || event.name==InpNewsNameTwo || event.name==InpNewsNameThree){
               event_time = values[i].time;
               news_stopTime = event_time - beforeNews_seconds;
               news_resumeTime = event_time + afterNews_seconds;                
            }
            if(TimeCurrent() > news_stopTime){ // && TimeCurrent() < news_resumeTime
               stopTrade = true;
            }
            if(TimeCurrent() > news_resumeTime){ // && TimeCurrent() < news_stopTime
               stopTrade = false;
            }             
         }           
      }   
   }
   
   //if(InpNewsMode==true){
   //   Comment("---------------NEWS MODE ACTIVE------------------",
   //            "\n\nHIGH IMPACT NEWS:     ",event_name," (",high_currency,")",
   //            "\nNEWS TIME:         ",event_time,
   //            "\nSTOP TRADING AT:   ",news_stopTime,
   //            "\nRESUME TRADING AT: ",news_resumeTime,
   //            "\n",
   //            "\nMODERATE IMPACT NEWS:     ",event_name_mod," (",mod_currency,")",
   //            "\nNEWS TIME:         ",event_time_mod,
   //            "\nSTOP TRADING AT:   ",news_stopTime_mod,
   //            "\nRESUME TRADING AT: ",news_resumeTime_mod);
   //}
   //if(InpNewsMode==false){
   //   Comment("");
   //}





//===SETTING RANGE=================================================================================================================//

   //if(cntBuy==0 && cntSell==0){
   //   range_count=0;
   //}
   
   CopyBuffer(ma_handle,0,0,2,maBuffer);

   if(range_count==0){
      r_highBar = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,InpLookBack,0);
      r_lowBar  = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,InpLookBack,0);
      
      range_high  = iHigh(_Symbol,PERIOD_CURRENT,r_highBar);
      range_low   = iLow(_Symbol,PERIOD_CURRENT,r_lowBar);
      
//      r_highTime  = iTime(_Symbol,PERIOD_CURRENT,r_highBar);
//      r_lowTime   = iTime(_Symbol,PERIOD_CURRENT,r_lowBar);
//      
//      r_highBar_time   = iBarShift(_Symbol,PERIOD_CURRENT,r_highTime,false);
//      r_lowBar_time    = iBarShift(_Symbol,PERIOD_CURRENT,r_lowTime,false);
//      
//      range_high  = iHigh(_Symbol,PERIOD_CURRENT,r_highBar_time);
//      range_low   = iLow(_Symbol,PERIOD_CURRENT,r_lowBar_time);
      
      datetime lookbackStart = TimeCurrent() - PeriodSeconds(PERIOD_CURRENT)*InpLookBack;
   
      ObjectCreate(0,"high",OBJ_HLINE,0,lookbackStart,range_high);
      ObjectCreate(0,"low",OBJ_HLINE,0,lookbackStart,range_low);
      
      range_count = 1;
   }  

   signal_highBar = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,20,0);
   signal_lowBar  = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,20,0);
   signal_highPrice = iHigh(_Symbol,PERIOD_CURRENT,signal_highBar);
   signal_lowPrice = iLow(_Symbol,PERIOD_CURRENT,signal_lowBar);
   signal_size = signal_highPrice - signal_lowPrice;

//---
   
   
   //if(range_count==1){
   //   r_highTime -= PeriodSeconds(PERIOD_CURRENT);
   //   r_lowTime -= PeriodSeconds(PERIOD_CURRENT);
   //}

   if(InpAutoLot == false){
      lotSize = InpStartLot;
   }
   if(InpAutoLot == true){
      lotSize = NormalizeDouble(accountInfo.Balance() / InpAutoLotPer * InpStartLot,2);
   }     






//===TOP OF RANGE===================================================================================================================//
   if(currentTick.bid >= range_high && range_high != 0.0){
   
      //REGULAR MODE---------------------------------------------------------------------------------------+      
      if(InpTradeDirection==ENUM_REGULAR){   
         if(InpHedge==false && entryBuyCnt==0 && entrySellCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }    
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}
            }
            if(InpTrendFilter==true && currentTick.ask >= maBuffer[0]){
               if(stopTrade==false){            
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}
            }                  
         }
         if(InpHedge==true && entryBuyCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){               
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}
            }
            if(InpTrendFilter==true && currentTick.bid >= maBuffer[0]){
               if(stopTrade==false){               
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}
            }                     
         }            
      } 

      
      
      
      //REVERSE MODE---------------------------------------------------------------------------------------+             
      if(InpTradeDirection==ENUM_REVERSE){     
         if(InpHedge==false && entrySellCnt==0 && entryBuyCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;}
            }  
            if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;}
            }               
         }
         if(InpHedge==true && entrySellCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;}  
            }  
            if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;}  
            }                            
         }            
      }  
         







   //DYNAMIC MODE------------------------------------------------------------------------------------------+

      if(InpTradeDirection==ENUM_DYNAMIC){
         //REGULAR
         if(signal_size < signal_points*_Point){              
            if(InpHedge==false && entryBuyCnt==0 && entrySellCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}
               }
               if(InpTrendFilter==true && currentTick.ask >= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}
               }                  
            }
            if(InpHedge==true && entryBuyCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}
               }
               if(InpTrendFilter==true && currentTick.bid >= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}
               }                     
            }            
         } 
   
         
         //REVERSE
         if(signal_size >= signal_points*_Point){
            if(InpHedge==false && entrySellCnt==0 && entryBuyCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;}
               }  
               if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;}
               }               
            }
            if(InpHedge==true && entrySellCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;}  
               }  
               if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;}  
               }                            
            }            
         } 
      }





         
         
               
   }
   
//BOTTOM OF RANGE=================================================================================================================//
   if(currentTick.bid <= range_low){
      
      //REGULAR MODE-------------------------------------------------------------------------------------+     
      if(InpTradeDirection==ENUM_REGULAR){
         if(InpHedge==false && entrySellCnt==0 && entryBuyCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;}  
            } 
            if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;}  
            }                          
         }
         if(InpHedge==true && entrySellCnt==0){
            if(InpTrendFilter==false){ 
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;} 
            } 
            if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){ 
               if(stopTrade==false){
                  trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
               }
               entrySellCnt = 1;
               if(cntSell==0){entrySellCnt=0;} 
            }                          
         }            
      }
        
      //REVERSE MODE--------------------------------------------------------------------------------------+              
      if(InpTradeDirection==ENUM_REVERSE){
         if(InpHedge==false && entryBuyCnt==0 && entrySellCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}  
            } 
            if(InpTrendFilter==true && currentTick.ask >= maBuffer[0]){
               if(stopTrade==false){
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}  
            }                            
         }
         if(InpHedge==true && entryBuyCnt==0){
            if(InpTrendFilter==false){
               if(stopTrade==false){
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}     
            } 
            if(InpTrendFilter==true && currentTick.ask >= maBuffer[0]){
               if(stopTrade==false){
                  trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
               }
               entryBuyCnt = 1;
               if(cntBuy==0){entryBuyCnt=0;}     
            }                     
         }                              
      }




      
      //DYNAMIC MODE--------------------------------------------------------------------------------------+  
      if(InpTradeDirection==ENUM_DYNAMIC){ 
      
         //REGULAR
         if(signal_size < signal_points*_Point){    
            if(InpHedge==false && entrySellCnt==0 && entryBuyCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;}  
               } 
               if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;}  
               }                          
            }
            if(InpHedge==true && entrySellCnt==0){
               if(InpTrendFilter==false){ 
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;} 
               } 
               if(InpTrendFilter==true && currentTick.bid <= maBuffer[0]){ 
                  if(stopTrade==false){
                     trade.Sell(InpStartLot,_Symbol,currentTick.bid,0,0,NULL);
                  }
                  entrySellCnt = 1;
                  if(cntSell==0){entrySellCnt=0;} 
               }                          
            }            
         }
           
         //REVERSE             
         if(signal_size >= signal_points*_Point){         
            if(InpHedge==false && entryBuyCnt==0 && entrySellCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}  
               } 
               if(InpTrendFilter==true && currentTick.ask >= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}  
               }                            
            }
            if(InpHedge==true && entryBuyCnt==0){
               if(InpTrendFilter==false){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}     
               } 
               if(InpTrendFilter==true && currentTick.ask >= maBuffer[0]){
                  if(stopTrade==false){
                     trade.Buy(InpStartLot,_Symbol,currentTick.ask,0,0,NULL);
                  }
                  entryBuyCnt = 1;
                  if(cntBuy==0){entryBuyCnt=0;}     
               }                     
            }                              
         }                 
      }         
   }
  
  
  
  
  
//===GETTING NEXT POSITION PRICE======================================================================================================//

   if(cntBuy==0){
      nextBuyPrice=0;
      closeBuyPositions=0;
   }
   if(cntSell==0){
      nextSellPrice=0;
      closeSellPositions=0;
   }
      
   if(PositionsTotal()>=1){
      int total = PositionsTotal();
      for(int i=total-1; i>=0; i--){
         ulong ticket = PositionGetTicket(i);  
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type."); return;}
         
         if(type==POSITION_TYPE_BUY && cntBuy==1){
            if(InpGridSkip == 0){
               nextBuyPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-point_Grid*_Point,_Digits); 
            }
            if(InpGridSkip > 0){
               nextBuyPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-(point_Grid*InpGridSkip)*_Point,_Digits);
            }     
         }  
         if(type==POSITION_TYPE_SELL && cntSell==1){
            if(InpGridSkip == 0){             
               nextSellPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+point_Grid*_Point,_Digits); 
            }
            if(InpGridSkip > 0){
               nextSellPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+(point_Grid*InpGridSkip)*_Point,_Digits);
            }                 
         }           
      }
   }     
  
           


//===MARTINGALE POSITIONS========================================================================================================//

   double Ask  = NormalizeDouble(currentTick.ask,_Digits);
   double Bid  = NormalizeDouble(currentTick.bid,_Digits);
   double m_lots  = 0.0;
   
   //buys
   if(Ask <= nextBuyPrice){
      if(cntBuy < InpMaxPoS && cntBuy > 0){
         m_lots = NormalizeDouble((last_volume_buy*InpLotMultiplier),2);
         if(m_lots > InpMaxLot){m_lots = InpMaxLot;}
         trade.Buy(m_lots,_Symbol,Ask,0,0,NULL);
         nextBuyPrice = NormalizeDouble((Ask - point_Grid*_Point),_Digits);
      }
   }
   
   //sells
   if(Bid >= nextSellPrice){
      if(cntSell < InpMaxPoS && cntSell > 0){
         m_lots = NormalizeDouble((last_volume_sell*InpLotMultiplier),2);
         if(m_lots > InpMaxLot){m_lots = InpMaxLot;}
         trade.Sell(m_lots,_Symbol,Bid,0,0,NULL);
         nextSellPrice = NormalizeDouble((Bid + point_Grid*_Point),_Digits);
      }
   }






//===CLOSE POSITIONS===================================================================================================================//

   tpBuyLine = breakEvenLineBuy + point_TP*_Point;
   tpSellLine = breakEvenLineSell - point_TP*_Point;

   if(currentTick.ask >= tpBuyLine && cntBuy > 0){
      ClosePositions(POSITION_TYPE_BUY);
      if(InpHedge==true){entryBuyCnt=0; range_count=0;}
      if(InpHedge==false){entryBuyCnt=0; entrySellCnt=0; range_count=0;}
   }    
   if(currentTick.bid <= tpSellLine && cntSell > 0){
      ClosePositions(POSITION_TYPE_SELL);
      if(InpHedge==true){entrySellCnt=0; range_count=0;}
      if(InpHedge==false){entrySellCnt=0; entrySellCnt=0; range_count=0;}
   }
   
   if(InpProfitClose > 0){
      double balance_prof = accountInfo.Balance()+InpProfitClose;
      if(accountInfo.Equity() >= balance_prof){
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         entryBuyCnt=0;
         entrySellCnt=0;
         range_count=0;
      }
   }





//===BREAK EVEN LINE RESET=====================================================================================================================//

   if(cntBuy==0){
      totalBuyLots=0;
      totalBuyPrice=0;
      breakEvenLineBuy=0;
   }
   if(cntSell==0){
      totalSellLots=0;
      totalSellPrice=0;
      breakEvenLineSell=0;
   }





//===BALANCE DRAWDOWN CHECK==================================================================================================================//

   if(InpDDbalance>0){
      if(accountInfo.Equity() <= accountInfo.Balance() - InpDDbalance){
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         range_count=0;
         entryBuyCnt=0;
         entrySellCnt=0;
      }           
   }
   double percDD = NormalizeDouble((accountInfo.Balance()/100*InpDDpercent),2);
   if(InpDDpercent > 0 && accountInfo.Equity() <= accountInfo.Balance() - percDD){
      ClosePositions(POSITION_TYPE_BUY);
      ClosePositions(POSITION_TYPE_SELL);
      range_count=0;
      entryBuyCnt=0;
      entrySellCnt=0;
   }   
 





}//-end-of-onTick-function-//






//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

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

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);         
      }
      else
         return;
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_entry==DEAL_ENTRY_IN && (deal_type==DEAL_TYPE_BUY || DEAL_TYPE_SELL)){
         
            if(deal_type==DEAL_TYPE_BUY){
               last_open_price_buy = deal_price;
               last_volume_buy = deal_volume;
            }
            if(deal_type==DEAL_TYPE_SELL){
               last_open_price_sell = deal_price;
               last_volume_sell = deal_volume;
            }
            
            last_open_price = deal_price;
            last_volume = deal_volume;
            last_position_type = (deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_BUY:POSITION_TYPE_SELL; 
            
         }
         else if(deal_entry==DEAL_ENTRY_OUT){
            last_open_price = 0.0;
            last_volume = 0.0;                              
            last_position_type = -1;            
         }
      }
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_BUY && deal_entry==DEAL_ENTRY_IN){
            totalBuyPrice += (last_volume_buy*last_open_price_buy);
            totalBuyLots += last_volume_buy;
            breakEvenLineBuy = totalBuyPrice/totalBuyLots;
         }
      }
      if(deal_symbol==_Symbol && deal_magic==InpMagicNumber){
         if(deal_type==DEAL_TYPE_SELL && deal_entry==DEAL_ENTRY_IN){
            totalSellPrice += (last_volume_sell*last_open_price_sell);
            totalSellLots += last_volume_sell;
            breakEvenLineSell = totalSellPrice/totalSellLots;
         }
      }
      
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

      //Comment("Today's Profit: ",NormalizeDouble(todays_profit_loss,_Digits));   
      
               
   }   
}




//===CLOSE GRID FUNCTION=======================================================================================================//

void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(positionInfo.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(positionInfo.Symbol()==_Symbol && positionInfo.Magic()==InpMagicNumber)
            if(positionInfo.PositionType()==pos_type) // gets the position type
               trade.PositionClose(positionInfo.Ticket()); // close a position by the specified symbol
   }