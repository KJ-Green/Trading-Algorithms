//+------------------------------------------------------------------+
//|                                                   ATR Trader.mq5 |
//|                              Copyright 2023, Shogun Trading Ltd. |
//|                                     info.shoguntrading@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Shogun Trading Ltd."
#property link      "info.shoguntrading@gmail.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Includes                                                                 
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
enum threshType
  {
   ENUM_INSIDE,   //Inside
   ENUM_OUTSIDE  //Outside
  };

//+------------------------------------------------------------------+
//| Inputs                                                                 
//+------------------------------------------------------------------+

input int         InpMagicNumber       =  33066;      //Magic Number

input string      Inptradesettings     =  "=========================";   //============TRADE SETTINGS============
input bool        InpUseThresh         =  false;      //Use ATR Threshold
input threshType  InpThreshType        =  ENUM_INSIDE;//ATR Threshold Type
input int         InpATRthresh         =  0;          //ATR Threshold (pips)
input bool        InpPrevATR           =  false;      //Use Previous ATR
input lotType     InpLotType           =  ENUM_PERC;  //Lot Type 
input double      InpRisk              =  1.0;        //Risk Percent
input double      InpFixedLot          =  0.01;       //Fixed Lot Size
input int         InpStopLoss          =  20;         //Stop Loss (pips)
input int         InpTakeProfit        =  20;         //Take Profit (pips)
input int         InpBreakeven         =  15;         //Break Even (pips)

input string      InpMartiSettings     =  "=========================";  //============MARTINGALE SETTINGS============
input bool        InpMarti             =  false;      //Use Martingale
input double      InpStartLot          =  0.01;       //Starting Lot Size
input double      InpLotMultiplier     =  1.1;        //Lot Size Multiplier
input int         InpGridStep          =  20;         //Grid Step (pips)
input int         InpGridSkip          =  0;          //Skip First x Trades in the Grid
input double      InpMaxLot            =  5;          //Max Lot Size
input int         InpMaxPoS            =  20;         //Max Positions In One Direction

input string      InpAccProtect        =  "=========================";  //============ACCOUNT PROTECTION============
input int         InpMaxTrades         =  2;          //Max Trades Per Day (in one direction)
input double      InpDDpercent         =  0.0;        //Max Equity Drawdown %   
input int         InpDDbalance         =  0;          //Max Balance Drawdown $ 
input int         InpTrailingStart     =  20;         //Trailing Stop Start (pips)
input int         InpTrailingStep      =  10;         //Trailing Stop Step (pips)
input int         InpProfitClose       =  0;          //Close all Positions once profit reached: $



//+------------------------------------------------------------------+
//|  Global Variables                                                                
//+------------------------------------------------------------------+
MqlTick currentTick;
MqlDateTime today;

int         barsTotal;
int         point_TP             =  InpTakeProfit*10;
int         point_SL             =  InpStopLoss*10;
int         point_Grid           =  InpGridStep*10;
int         point_thresh         =  InpATRthresh*10;

double      d1h,d2h,d3h,d4h,d5h,d6h,d7h,d8h,d9h,d10h,d11h,d12h,d13h,d14h,d15h,d16h,d17h,d18h,d19h,d20h;
double      d1l,d2l,d3l,d4l,d5l,d6l,d7l,d8l,d9l,d10l,d11l,d12l,d13l,d14l,d15l,d16l,d17l,d18l,d19l,d20l;
double      d1s,d2s,d3s,d4s,d5s,d6s,d7s,d8s,d9s,d10s,d11s,d12s,d13s,d14s,d15s,d16s,d17s,d18s,d19s,d20s;
double      ds_total, ds_atr, today_OP, d1_OP, d2_OP;
double      atr0_h,atr1_h,atr2_h,atr0_l,atr1_l,atr2_l;

datetime    d0_start,d0_end,d1_start,d1_end,d2_start,d2_end;
double      SL,TP,lotSize;
int         entryBuyCnt, entrySellCnt; 
int         todaySellCnt = 0; 
int         todayBuyCnt = 0;
int         maxSellCnt = 0;
int         maxBuyCnt = 0;

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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{   

   if(InpTakeProfit<=0){Alert("Take profit must be greater than 0...");return INIT_PARAMETERS_INCORRECT;}
   if(InpStartLot<=0){Alert("Start lot must be 0.01 or greater...");return INIT_PARAMETERS_INCORRECT;}

   trade.SetExpertMagicNumber(InpMagicNumber);

   barsTotal = iBars(_Symbol,PERIOD_D1);
      
   return(INIT_SUCCEEDED);
}



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   
}



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   
   if(!SymbolInfoTick(_Symbol,currentTick)){Print("Failed to get current tick.");return;}
   
//---

   //Detecting a New Day
   int bars = iBars(_Symbol,PERIOD_D1);
   if(barsTotal != bars){
      barsTotal = bars;
      todayBuyCnt=0;
      todaySellCnt=0;
      maxBuyCnt=0;
      maxSellCnt=0;
      
   //---

   //High Prices
      d1h   =  iHigh(_Symbol,PERIOD_D1,1);
      d2h   =  iHigh(_Symbol,PERIOD_D1,2);   
      d3h   =  iHigh(_Symbol,PERIOD_D1,3);
      d4h   =  iHigh(_Symbol,PERIOD_D1,4);
      d5h   =  iHigh(_Symbol,PERIOD_D1,5);
      d6h   =  iHigh(_Symbol,PERIOD_D1,6);
      d7h   =  iHigh(_Symbol,PERIOD_D1,7);
      d8h   =  iHigh(_Symbol,PERIOD_D1,8);
      d9h   =  iHigh(_Symbol,PERIOD_D1,9);
      d10h   =  iHigh(_Symbol,PERIOD_D1,10);
      d11h   =  iHigh(_Symbol,PERIOD_D1,11);
      d12h   =  iHigh(_Symbol,PERIOD_D1,12);
      d13h   =  iHigh(_Symbol,PERIOD_D1,13);
      d14h   =  iHigh(_Symbol,PERIOD_D1,14);
      d15h   =  iHigh(_Symbol,PERIOD_D1,15);
      d16h   =  iHigh(_Symbol,PERIOD_D1,16);
      d17h   =  iHigh(_Symbol,PERIOD_D1,17);
      d18h   =  iHigh(_Symbol,PERIOD_D1,18);   
      d19h   =  iHigh(_Symbol,PERIOD_D1,19);
      d20h   =  iHigh(_Symbol,PERIOD_D1,20);   
      
   //Low Prices
      d1l   =  iLow(_Symbol,PERIOD_D1,1);
      d2l   =  iLow(_Symbol,PERIOD_D1,2);   
      d3l   =  iLow(_Symbol,PERIOD_D1,3);
      d4l   =  iLow(_Symbol,PERIOD_D1,4);
      d5l   =  iLow(_Symbol,PERIOD_D1,5);
      d6l   =  iLow(_Symbol,PERIOD_D1,6);
      d7l   =  iLow(_Symbol,PERIOD_D1,7);
      d8l   =  iLow(_Symbol,PERIOD_D1,8);
      d9l   =  iLow(_Symbol,PERIOD_D1,9);
      d10l   =  iLow(_Symbol,PERIOD_D1,10);
      d11l   =  iLow(_Symbol,PERIOD_D1,11);
      d12l   =  iLow(_Symbol,PERIOD_D1,12);
      d13l   =  iLow(_Symbol,PERIOD_D1,13);
      d14l   =  iLow(_Symbol,PERIOD_D1,14);
      d15l   =  iLow(_Symbol,PERIOD_D1,15);
      d16l   =  iLow(_Symbol,PERIOD_D1,16);
      d17l   =  iLow(_Symbol,PERIOD_D1,17);
      d18l   =  iLow(_Symbol,PERIOD_D1,18);   
      d19l   =  iLow(_Symbol,PERIOD_D1,19);
      d20l   =  iLow(_Symbol,PERIOD_D1,20); 
      
   //Daily Candle Size
      d1s   =  d1h - d1l;
      d2s   =  d2h - d2l;
      d3s   =  d3h - d3l;
      d4s   =  d4h - d4l;
      d5s   =  d5h - d5l;
      d6s   =  d6h - d6l;      
      d7s   =  d7h - d7l;
      d8s   =  d8h - d8l;
      d9s   =  d9h - d9l;
      d10s   =  d10h - d10l;
      d11s   =  d11h - d11l;
      d12s   =  d12h - d12l;
      d13s   =  d13h - d13l;
      d14s   =  d14h - d14l;
      d15s   =  d15h - d15l;
      d16s   =  d16h - d16l;
      d17s   =  d17h - d17l;
      d18s   =  d18h - d18l;               
      d19s   =  d19h - d19l;
      d20s   =  d20h - d20l;
   
   //Daily Size Total
      ds_total = (d1s + d2s + d3s + d4s + d5s + d6s + d7s + d8s + d9s + d10s +
                  d11s + d12s + d13s + d14s + d15s + d16s + d17s + d18s + d19s + d20s);
                  
   //Average Daily Pip Size   
      ds_atr   = ds_total / 20;
      
   //Daily Candles Opening Price                  
      today_OP = iOpen(_Symbol,PERIOD_D1,0);
      d1_OP    = iOpen(_Symbol,PERIOD_D1,1);
      d2_OP    = iOpen(_Symbol,PERIOD_D1,2);
      
   //High and Low Prices of Last 3 ATR's   
      atr0_h   = today_OP + ds_atr;
      atr0_l   = today_OP - ds_atr;
      atr1_h   = d1_OP + ds_atr;
      atr1_l   = d1_OP - ds_atr;
      atr2_h   = d2_OP + ds_atr;
      atr2_l   = d2_OP - ds_atr;
      
   //Start and End Times of Last Three Days
      datetime d0_midnight,d1_midnight,d2_midnight,tmrw_midnight;
      datetime now         = TimeCurrent(today);
      int      year        = today.year;
      int      month       = today.mon;
      int      day         = today.day;
   
      d0_midnight = StringToTime(string(year)+"."+string(month)+"."+string(day)+" 00:00");
      d1_midnight = d0_midnight - PeriodSeconds(PERIOD_D1);     
      d2_midnight = d1_midnight - PeriodSeconds(PERIOD_D1);
      tmrw_midnight = d0_midnight + PeriodSeconds(PERIOD_D1);
      
      if(today.day_of_week==1){
         d1_midnight = d0_midnight - (PeriodSeconds(PERIOD_D1)*3);     
         d2_midnight = d0_midnight - (PeriodSeconds(PERIOD_D1)*4);
      }
      if(today.day_of_week==2){
         d1_midnight = d0_midnight - PeriodSeconds(PERIOD_D1);     
         d2_midnight = d1_midnight - (PeriodSeconds(PERIOD_D1)*3);   
      }
   
   //Plot ATR Lines on Chart
      ObjectCreate(0,"atr0_h",OBJ_TREND,0,d0_midnight,atr0_h,tmrw_midnight,atr0_h);
         ObjectSetInteger(0,"atr0_h",OBJPROP_COLOR,clrRed);
      ObjectCreate(0,"atr0_l",OBJ_TREND,0,d0_midnight,atr0_l,tmrw_midnight,atr0_l);
         ObjectSetInteger(0,"atr0_l",OBJPROP_COLOR,clrGreen);
      ObjectCreate(0,"atr1_h",OBJ_TREND,0,d1_midnight,atr1_h,d0_midnight,atr1_h);
         ObjectSetInteger(0,"atr1_h",OBJPROP_COLOR,clrRed);                   
      ObjectCreate(0,"atr1_l",OBJ_TREND,0,d1_midnight,atr1_l,d0_midnight,atr1_l);
         ObjectSetInteger(0,"atr1_l",OBJPROP_COLOR,clrGreen); 
      ObjectCreate(0,"atr2_h",OBJ_TREND,0,d2_midnight,atr2_h,d1_midnight,atr2_h);
         ObjectSetInteger(0,"atr2_h",OBJPROP_COLOR,clrRed);                   
      ObjectCreate(0,"atr2_l",OBJ_TREND,0,d2_midnight,atr2_l,d1_midnight,atr2_l);
         ObjectSetInteger(0,"atr2_l",OBJPROP_COLOR,clrGreen); 
            
//---      
      
      
           
   }
   //Comment("TodayBuyCnt: ",todayBuyCnt,"\nTodaySellCnt: ",todaySellCnt,"\nmaxBuyCnt: ",maxBuyCnt,"\nmaxSellCnt: ",maxSellCnt);    

//---

   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell);

//---














//---

      
//Opening Positions---------------------------------------------------+
   
   //TOP OF ATR
   if(InpUseThresh==true){
      if(InpThreshType==ENUM_INSIDE){
         atr0_h = atr0_h - point_thresh*_Point;
         atr1_h = atr1_h - point_thresh*_Point;
      }
      if(InpThreshType==ENUM_OUTSIDE){
         atr0_h = atr0_h + point_thresh*_Point;
         atr1_h = atr1_h + point_thresh*_Point;
      }
   }         


   if(InpPrevATR==false){ 
      if(currentTick.bid >= atr0_h && todaySellCnt==0 && maxSellCnt<InpMaxTrades){
         if(InpMarti==false){
            SL = currentTick.bid + point_SL*_Point; 
            TP = currentTick.bid - point_TP*_Point;
            double   slDistance = point_SL*_Point;
            if(InpLotType==ENUM_PERC){lotSize = calcLots(InpRisk,slDistance);}
            else{lotSize = InpFixedLot;}
         }
         if(InpMarti==true){
            SL = 0; 
            TP = 0;
            lotSize = InpStartLot;
         }
         trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
         entrySellCnt=1;  
      }      
   }
   if(InpPrevATR==true){ 
      if((currentTick.bid >= atr0_h || currentTick.bid >= atr1_h) && todaySellCnt==0 && maxSellCnt<InpMaxTrades){
         if(InpMarti==false){
            SL = currentTick.bid + point_SL*_Point; 
            TP = currentTick.bid - point_TP*_Point;
            double   slDistance = point_SL*_Point;
            if(InpLotType==ENUM_PERC){lotSize = calcLots(InpRisk,slDistance);}
            else{lotSize = InpFixedLot;}
         }
         if(InpMarti==true){
            SL = 0; 
            TP = 0;
            lotSize = InpStartLot;
         }
         trade.Sell(lotSize,_Symbol,currentTick.bid,SL,TP,NULL);
         entrySellCnt=1;
      }      
   }           
      


   //BOTTOM OF ATR-------------------------------------+
   if(InpUseThresh==true){
      if(InpThreshType==ENUM_INSIDE){
         atr0_l = atr0_l + point_thresh*_Point;
         atr1_l = atr1_l + point_thresh*_Point;
      }
      if(InpThreshType==ENUM_OUTSIDE){
         atr0_l = atr0_l - point_thresh*_Point;
         atr1_l = atr1_l - point_thresh*_Point;
      }
   }  


   if(InpPrevATR==false){ 
      if(currentTick.ask <= atr0_l && todayBuyCnt==0 && maxBuyCnt<InpMaxTrades){
         if(InpMarti==false){
            SL = currentTick.ask - point_SL*_Point; 
            TP = currentTick.ask + point_TP*_Point;
            double   slDistance = point_SL*_Point;
            if(InpLotType==ENUM_PERC){lotSize = calcLots(InpRisk,slDistance);}
            else{lotSize = InpFixedLot;}
         }
         if(InpMarti==true){
            SL = 0; 
            TP = 0;
            lotSize = InpStartLot;
         }
         trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);
         //entryBuyCnt=1;
      }      
   }
   if(InpPrevATR==true){ 
      if((currentTick.ask <= atr0_l || currentTick.ask <= atr1_l) && todayBuyCnt==0 && maxBuyCnt<InpMaxTrades){
         if(InpMarti==false){
            SL = currentTick.ask - point_SL*_Point; 
            TP = currentTick.ask + point_TP*_Point;
            double   slDistance = point_SL*_Point;
            if(InpLotType==ENUM_PERC){lotSize = calcLots(InpRisk,slDistance);}
            else{lotSize = InpFixedLot;}
         }
         if(InpMarti==true){
            SL = 0; 
            TP = 0;
            lotSize = InpStartLot;
         }
         trade.Buy(lotSize,_Symbol,currentTick.ask,SL,TP,NULL);
         //entryBuyCnt=1;
      }      
   }       
     
            
 //---

//-Getting-Next-Position-Price---------------------------------------------------------------+     
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


//-Martingale Positions---------------------------------------------------------+
   double Ask  = NormalizeDouble(currentTick.ask,_Digits);
   double Bid  = NormalizeDouble(currentTick.bid,_Digits);
   double m_lots  = 0.0;
 
   if(InpMarti==true){   
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
   }
      
 
//-CLOSE POSITIONS----------------------------------------------------------------+
   tpBuyLine = breakEvenLineBuy + point_TP*_Point;
   tpSellLine = breakEvenLineSell - point_TP*_Point;

   if(InpMarti==true){
      if(currentTick.ask >= tpBuyLine && cntBuy > 0){
         ClosePositions(POSITION_TYPE_BUY);
         todayBuyCnt=0;
         //maxBuyCnt=0;
      }    
      if(currentTick.bid <= tpSellLine && cntSell > 0){
         ClosePositions(POSITION_TYPE_SELL);
         todaySellCnt=0;
         //maxSellCnt=0;
      }
      
      if(InpProfitClose > 0){
         double balance_prof = accountInfo.Balance()+InpProfitClose;
         if(accountInfo.Equity() >= balance_prof){
            ClosePositions(POSITION_TYPE_BUY);
            ClosePositions(POSITION_TYPE_SELL);
            todayBuyCnt=0;
            todaySellCnt=0;
            //maxBuyCnt=0;
            //maxSellCnt=0;
         }
      }     
   }
 
 
   
//-Balance-drawdown-check----------------------------------------------------------------+
   if(InpDDbalance>0){
      if(accountInfo.Equity() <= accountInfo.Balance() - InpDDbalance){
         ClosePositions(POSITION_TYPE_BUY);
         ClosePositions(POSITION_TYPE_SELL);
         todayBuyCnt=0;
         todaySellCnt=0;
      }           
   }
   double percDD = NormalizeDouble((accountInfo.Balance()/100*InpDDpercent),2);
   if(InpDDpercent > 0 && accountInfo.Equity() <= accountInfo.Balance() - percDD){
      ClosePositions(POSITION_TYPE_BUY);
      ClosePositions(POSITION_TYPE_SELL);
      todayBuyCnt=0;
      todaySellCnt=0;
   }   
   


//-Break-Even-Line-Reset---------------------------------------------------------+

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
 
 
//-- 

   //Buy Breakeven Line
   if(cntBuy>1){
      ObjectCreate(0,"BE_BUY",OBJ_HLINE,0,TimeCurrent(),breakEvenLineBuy);
      ObjectSetInteger(0,"BE_BUY",OBJPROP_COLOR,clrAqua);
      ObjectSetInteger(0,"BE_BUY",OBJPROP_STYLE,STYLE_DASH);
      if(ObjectGetDouble(0,"BE_BUY",OBJPROP_PRICE,1) != breakEvenLineBuy){
         ObjectSetDouble(0,"BE_BUY",OBJPROP_PRICE,breakEvenLineBuy);
      }
   }         
   //Buy TP Line
   ObjectCreate(0,"TP_BUY",OBJ_HLINE,0,TimeCurrent(),tpBuyLine);
   ObjectSetInteger(0,"TP_BUY",OBJPROP_COLOR,clrLime);
   ObjectSetInteger(0,"TP_BUY",OBJPROP_STYLE,STYLE_DASH);
   if(ObjectGetDouble(0,"TP_BUY",OBJPROP_PRICE,1) != tpBuyLine){
      ObjectSetDouble(0,"TP_BUY",OBJPROP_PRICE,tpBuyLine);
   }
   if(cntBuy<2){
      ObjectDelete(0,"BE_BUY");
      ObjectDelete(0,"TP_BUY");
   }
    
   //Sell Breakeven Line
   if(cntSell>1){
      ObjectCreate(0,"BE_SELL",OBJ_HLINE,0,TimeCurrent(),breakEvenLineSell);
      ObjectSetInteger(0,"BE_SELL",OBJPROP_COLOR,clrAqua);
      ObjectSetInteger(0,"BE_SELL",OBJPROP_STYLE,STYLE_DASH);
      if(ObjectGetDouble(0,"BE_SELL",OBJPROP_PRICE,1) != breakEvenLineSell){
         ObjectSetDouble(0,"BE_SELL",OBJPROP_PRICE,breakEvenLineSell);
      }
   }    
   //Sell TP Line
   ObjectCreate(0,"TP_SELL",OBJ_HLINE,0,TimeCurrent(),tpSellLine);
   ObjectSetInteger(0,"TP_SELL",OBJPROP_COLOR,clrLime);
   ObjectSetInteger(0,"TP_SELL",OBJPROP_STYLE,STYLE_DASH);
   if(ObjectGetDouble(0,"TP_SELL",OBJPROP_PRICE,1) != tpSellLine){
      ObjectSetDouble(0,"TP_SELL",OBJPROP_PRICE,tpSellLine);
   }   
   if(cntSell<2){
      ObjectDelete(0,"BE_SELL");
      ObjectDelete(0,"TP_SELL");
   }
    

                                       
}



//+------------------------------------------------------------------+
//|    Custom Functions                                                              
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


//---Count-Open-Positions-------------------------------------------------------------------+
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

//-TradeTransaction-function-----------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result){

//---get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
//---if transaction is result of addition of the transaction in history
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
       
      datetime midnight;
      datetime now         = TimeCurrent(today);
      int      year        = today.year;
      int      month       = today.mon;
      int      day         = today.day;

      midnight = StringToTime(string(year)+"."+string(month)+"."+string(day)+" 00:00");
      HistorySelect(midnight,now);
              
      if(deal_entry==DEAL_ENTRY_IN && deal_time > midnight){
         if(deal_type==DEAL_TYPE_SELL){todaySellCnt=1; maxSellCnt+=1;}
         if(deal_type==DEAL_TYPE_BUY){todayBuyCnt=1; maxBuyCnt+=1;}
      }
      if(deal_entry==DEAL_ENTRY_OUT && deal_time > midnight){
         if(deal_type==DEAL_TYPE_BUY){todaySellCnt=0;}
         if(deal_type==DEAL_TYPE_SELL){todayBuyCnt=0;}
      }
      

      
               
   }   
}

//-close-grid-positions-function------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(positionInfo.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(positionInfo.Symbol()==_Symbol && positionInfo.Magic()==InpMagicNumber)
            if(positionInfo.PositionType()==pos_type) // gets the position type
               trade.PositionClose(positionInfo.Ticket()); // close a position by the specified symbol
   }