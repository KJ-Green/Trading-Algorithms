//+------------------------------------------------------------------+
//|                                              EMA Slope Trend.mq5 |
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
#include <Trade\PositionInfo.mqh>
CPositionInfo positionInfo;
#include <Trade\AccountInfo.mqh>
CAccountInfo accountInfo;

enum range_mode
  {
   ENUM_BREAK,    //Breakout
   ENUM_BOUNCE   //Bounce
  };
//+------------------------------------------------------------------+
//| Input Parameters                                                                 
//+------------------------------------------------------------------+
input int      InpMagicNumber       =  8393011;          //Magic Number
input ENUM_MA_METHOD  InpMAtype     =  MODE_EMA;         //Moving Average Type
input int      InpMaPeriod          =  14;               //MA Period
input ENUM_TIMEFRAMES InpMATF       =  PERIOD_CURRENT;   //MA Timeframe
input int      InpLookBack          =  20;               //Bar Look Back
input range_mode InpRangeMode       =  ENUM_BREAK;       //Range Mode

input string   gap1                 =  "----";           //----
input double   InpLotSize           =  0.1;              //Lot Size
input bool     InpAutoLot           =  false;            //Use Auto Lot
input int      InpAutoLotPer        =  1000;             //(Auto Lot) Lot Size Per: $
input int      InpStopLoss          =  20;               //Stop Loss (pips) - not used with grid
input int      InpTakeProfit        =  10;               //Take Profit (pips) 0=OFF
input int      InpTrailingStart     =  10;               //Trailing Stop Start (pips) 0=OFF
input int      InpTrailingStep      =  2;                //Trailing Stop Step From Price (pips)

input string   gap2                 =  "----";           //----
input bool     InpUseGrid           = true;              //Use Grid
input int      InpGridStep          = 10;                //Grid Step (pips)
input int      InpGridSkip          = 0;                 //Skip x Steps in Grid
input double   InpGridExp           = 1;                 //Grid Step Exponent
input int      InpMaxPos            = 20;                //Max Positions (in one direction)
input double   InpLotMultiplier     = 1.0;               //Lot Multiplier
input int      InpMaxLot            = 10;                //Max Lot Size

//+------------------------------------------------------------------+
//|  Global Variables                                                                
//+------------------------------------------------------------------+
MqlTick  currentTick;

int      rsi_handle, ma_handle;
double   sl_points, tStart_points, tStep_points, gStep_points, tp_points;
double   SL, TP, SL_size, lotSize;
double   buyTS_level, sellTS_level, buyTS, buyTS_TP, sellTS, sellTS_TP, rangeB_TS_level, rangeS_TS_level, rangeB_TS, rangeS_TS;
double   slope_start, slope_end, slope_thresh, slope_buyThresh, slope_sellThresh, slope_angle;
double   rsiBuffer[], maBuffer[];
bool     bearish, bullish, ranging,use_tp;
datetime slope_time_start, time_now;
double   buy_count, sell_count, range_buy, range_sell, bull_buy, bear_sell;
double   nextBuyPrice, nextSellPrice, closeBuyPositions, closeSellPositions;
int      entryBuyCnt, entrySellCnt;

int         last_position_type   =  -1;
double      last_open_price      =  0.0;
double      last_volume          =  0.0;
double      last_volume_buy      =  0.0;
double      last_volume_sell     =  0.0;
double      last_open_price_buy  =  0.0;
double      last_open_price_sell =  0.0;

static double        totalBuyPrice, totalSellPrice;
static double        totalBuyLots, totalSellLots;
static double        buyPrice, sellPrice;
static double        breakEvenLineBuy, breakEvenLineSell;
double               tpBuyLine, tpSellLine;


//Object strings
string obj_slope = "obj_slope";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   trade.SetExpertMagicNumber(InpMagicNumber);
   
   rsi_handle = iRSI(_Symbol,PERIOD_CURRENT,InpMaPeriod,PRICE_CLOSE);
   
   ma_handle = iMA(_Symbol,InpMATF,InpMaPeriod,0,InpMAtype,PRICE_CLOSE);
   
   ArraySetAsSeries(rsiBuffer,true);
   
   ArraySetAsSeries(maBuffer,true);


   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(rsi_handle != INVALID_HANDLE){IndicatorRelease(rsi_handle);}
   if(ma_handle != INVALID_HANDLE){IndicatorRelease(ma_handle);}
   
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   if(!SymbolInfoTick(_Symbol,currentTick)){Alert("Failed to get current tick.");}
   
//---

   CopyBuffer(rsi_handle,0,0,3,rsiBuffer);
   CopyBuffer(ma_handle,0,0,InpLookBack,maBuffer);
   
   double bid = currentTick.bid;
   double ask = currentTick.ask;
   
   sl_points      =  InpStopLoss*10*_Point;
   tp_points      =  InpTakeProfit*10*_Point;
   tStart_points  =  InpTrailingStart*10*_Point;
   tStep_points   =  InpTrailingStep*10*_Point;
   gStep_points   =  InpGridStep*10*_Point;
   
   int cntBuy, cntSell;
   CountOpenPositions(cntBuy,cntSell); 
   
   if(cntBuy==0){bull_buy=0; range_buy=0; entryBuyCnt=0;}
   if(cntSell==0){bear_sell=0; range_sell=0; entrySellCnt=0;}



//=== LOT SIZE ====================================================================//

   if(InpAutoLot == false){
      lotSize = InpLotSize;
   }
   if(InpAutoLot == true){
      lotSize = NormalizeDouble(accountInfo.Balance() / InpAutoLotPer * InpLotSize,2);
   }
     
  
 
 
   
//---
   
   time_now = TimeCurrent();
   slope_time_start = time_now - PeriodSeconds(InpMATF) * InpLookBack;

   int buffer_start = InpLookBack - 1;
   slope_start = NormalizeDouble(maBuffer[buffer_start],_Digits);
   slope_end = NormalizeDouble(maBuffer[1],_Digits);   
   slope_angle = slope_end - slope_start;
   
   slope_thresh = 100*_Point;
   slope_buyThresh = slope_thresh;
   slope_sellThresh = -(slope_thresh);
   
   if(slope_angle<slope_sellThresh){bearish=true;bullish=false;ranging=false;}
   if(slope_angle>slope_buyThresh){bullish=true;bearish=false;ranging=false;}
   if(slope_angle>slope_sellThresh&&slope_angle<slope_buyThresh){ranging=true;bearish=false;bullish=false;}
   
   ObjectCreate(0,obj_slope,OBJ_TREND,0,slope_time_start,slope_start,time_now,slope_end);
   ObjectSetInteger(0,obj_slope,OBJPROP_COLOR,clrGold);
   ObjectSetInteger(0,obj_slope,OBJPROP_WIDTH,3);
   
   if(bearish==true){
      ObjectSetInteger(0,obj_slope,OBJPROP_COLOR,clrCrimson);
   }
   if(ranging==true){
      ObjectSetInteger(0,obj_slope,OBJPROP_COLOR,clrGold);
   }
   if(bullish==true){
      ObjectSetInteger(0,obj_slope,OBJPROP_COLOR,clrLimeGreen);
   }
   
   //Comment("slope angle: ",slope_angle,"\n\nbearish: ",bearish,"\nbullish: ",bullish,"\nranging: ",ranging);
   
   //== bullish buys =============================================================//
   if(bullish==true){
      if(bull_buy==0 && rsiBuffer[0]<30){
         if(InpTrailingStart==0){TP=ask + tp_points; use_tp=true;}
         if(InpTrailingStart>0 && tStart_points>tp_points){TP=ask + tp_points; use_tp=true;}
         if(InpTrailingStart>0 && tStart_points<tp_points){TP=0; use_tp=false;}
         if(InpUseGrid==false){SL=NormalizeDouble(ask-sl_points,_Digits);}
         if(InpStopLoss==0){SL=0;}
         trade.Buy(lotSize,_Symbol,ask,SL,TP,NULL);
         buyTS_level = ask + tStart_points;
         bull_buy=1;
         entryBuyCnt=1;
      }
   }
   
   //== bearish sells ============================================================//
   if(bearish==true){
      if(bear_sell==0 && rsiBuffer[0]>70){
         if(InpTrailingStart==0){TP=bid - tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points>tp_points){TP=bid - tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points<tp_points){TP=0;use_tp=false;}          
         if(InpUseGrid==false){SL=NormalizeDouble(bid+sl_points,_Digits);}
         if(InpStopLoss==0){SL=0;}      
         trade.Sell(lotSize,_Symbol,bid,SL,TP,NULL);
         sellTS_level = bid - tStart_points;
         bear_sell=1;
         entrySellCnt=1;
      }
   }
   
   //== ranging buys and sells ===================================================//
   if(ranging==true){
      
      //top of range bounce sells
      if(InpRangeMode==ENUM_BOUNCE && range_sell==0 && rsiBuffer[0]>70){
         if(InpTrailingStart==0){TP=bid - tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points>tp_points){TP=bid - tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points<tp_points){TP=0;use_tp=false;}         
         SL = NormalizeDouble(bid+sl_points,_Digits);
         if(InpStopLoss==0){SL=0;}
         trade.Sell(lotSize,_Symbol,bid,SL,TP,NULL);
         rangeS_TS_level = bid - (tStart_points/2);
         range_sell=1;
         entrySellCnt=1;
      }
      //range breakout buy
      if(InpRangeMode==ENUM_BREAK && range_buy==0 && rsiBuffer[0]>70){
         if(InpTrailingStart==0){TP=ask + tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points>tp_points){TP=ask + tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points<tp_points){TP=0;use_tp=false;}      
         SL = NormalizeDouble(ask-sl_points,_Digits);
         if(InpStopLoss==0){SL=0;}
         trade.Buy(lotSize,_Symbol,ask,SL,TP,NULL);
         rangeB_TS_level = ask + (tStart_points/2);
         range_buy=1;
         entryBuyCnt=1;
      }
      
      //bottom of range bounce buys            
      if(InpRangeMode==ENUM_BOUNCE && range_buy==0 && rsiBuffer[0]<30){
         if(InpTrailingStart==0){TP=ask + tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points>tp_points){TP=ask + tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points<tp_points){TP=0;use_tp=false;}      
         SL = NormalizeDouble(ask-sl_points,_Digits);
         if(InpStopLoss==0){SL=0;}
         trade.Buy(lotSize,_Symbol,ask,SL,TP,NULL);
         rangeB_TS_level = ask + (tStart_points/2);
         range_buy=1;
         entryBuyCnt=1;
      }
      
      //range breakout sells 
      if(InpRangeMode==ENUM_BREAK && range_sell==0 && rsiBuffer[0]<30){
         if(InpTrailingStart==0){TP=bid - tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points>tp_points){TP=bid - tp_points;use_tp=true;}
         if(InpTrailingStart>0 && tStart_points<tp_points){TP=0;use_tp=false;}      
         SL = NormalizeDouble(bid+sl_points,_Digits);
         if(InpStopLoss==0){SL=0;}
         trade.Sell(lotSize,_Symbol,bid,SL,TP,NULL);
         rangeS_TS_level = bid - (tStart_points/2);
         range_sell=1;
         entrySellCnt=1;
      }                  
   }
   
   
//=== CHECK TRAILING STOP =============================================//

//   if(cntBuy>0){
//      checkTrailingSLBuy(ask);                                      
//   }  
//   if(ask>=buyTS_level){
//      buyTS_level=ask+tStep_points;
//   }   
//      
//      
//   if(cntSell>0){
//      checkTrailingSLSell(bid); 
//   }      
//   if(bid<=sellTS_level){
//      sellTS_level=bid-tStep_points;
//   }



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
               nextBuyPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-gStep_points,_Digits); 
            }
            if(InpGridSkip > 0){
               nextBuyPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-gStep_points*InpGridSkip,_Digits);
            }     
         }  
         if(type==POSITION_TYPE_SELL && cntSell==1){
            if(InpGridSkip == 0){             
               nextSellPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+gStep_points,_Digits); 
            }
            if(InpGridSkip > 0){
               nextSellPrice = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+gStep_points*InpGridSkip,_Digits);
            }                 
         }           
      }
   }   


//===MARTINGALE POSITIONS========================================================================================================//

   double m_lots  = 0.0;
   
   //buys
   if(ask <= nextBuyPrice){
      if(cntBuy < InpMaxPos && cntBuy > 0){
         m_lots = NormalizeDouble((last_volume_buy*InpLotMultiplier),2);
         if(m_lots > InpMaxLot){m_lots = InpMaxLot;}
         trade.Buy(m_lots,_Symbol,ask,0,0,NULL);
         nextBuyPrice = NormalizeDouble((ask - gStep_points),_Digits);
      }
   }
   
   //sells
   if(bid >= nextSellPrice){
      if(cntSell < InpMaxPos && cntSell > 0){
         m_lots = NormalizeDouble((last_volume_sell*InpLotMultiplier),2);
         if(m_lots > InpMaxLot){m_lots = InpMaxLot;}
         trade.Sell(m_lots,_Symbol,bid,0,0,NULL);
         nextSellPrice = NormalizeDouble((bid + gStep_points),_Digits);
      }
   }



//===CLOSE POSITIONS===================================================================================================================//

   if(use_tp==false){tpBuyLine = breakEvenLineBuy + tStart_points;}
   if(use_tp==true){tpBuyLine = breakEvenLineBuy + tp_points;}
   if(use_tp==false){tpSellLine = breakEvenLineSell - tStart_points;}
   if(use_tp==true){tpSellLine = breakEvenLineSell - tp_points;}

   if(currentTick.bid >= tpBuyLine && cntBuy > 0){                      //CHANGE THIS TO BID PRICE IF POSITIONS ARE CLOSING FOR A LOSS**
      ClosePositions(POSITION_TYPE_BUY);
      entryBuyCnt=0; 
      //if(InpHedge==false){entryBuyCnt=0; entrySellCnt=0; range_count=0;}
   }    
   if(currentTick.ask <= tpSellLine && cntSell > 0){                    //CHANGE THIS TO ASK PRICE IF POSITIONS ARE CLOSING FOR A LOSS**
      ClosePositions(POSITION_TYPE_SELL);
      entrySellCnt=0; 
      //if(InpHedge==false){entrySellCnt=0; entrySellCnt=0; range_count=0;}
   }
   
   //if(InpProfitClose > 0){
   //   double balance_prof = accountInfo.Balance()+InpProfitClose;
   //   if(accountInfo.Equity() >= balance_prof){
   //      ClosePositions(POSITION_TYPE_BUY);
   //      ClosePositions(POSITION_TYPE_SELL);
   //      entryBuyCnt=0;
   //      entrySellCnt=0;
   //      range_count=0;
   //   }
   //}



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


   
}


//+------------------------------------------------------------------+
//| Custom Functions                                                                 
//+------------------------------------------------------------------+


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


//=== TRAILING STOP FUNCTION =============================================================================//

void  checkTrailingSLBuy(double ask){

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
         buyTS = NormalizeDouble(buyTS_level - tStep_points,_Digits);
         if(buyTS > currentTick.bid){
            buyTS = NormalizeDouble(currentTick.bid - tStep_points,_Digits);
         }
         //buyTS_TP = openPrice + tp_points;
         rangeB_TS = NormalizeDouble(rangeB_TS_level - tStep_points,_Digits);
         if(rangeB_TS > currentTick.bid){
            rangeB_TS = NormalizeDouble(currentTick.bid - tStep_points,_Digits);
         }

         if(bull_buy>0){
            if(magic==InpMagicNumber && type==POSITION_TYPE_BUY && currentTick.ask>=buyTS_level){
               trade.PositionModify(positionTicket,buyTS,0); 
            }
         }    
         if(range_buy>0){
            if(magic==InpMagicNumber && type==POSITION_TYPE_BUY && currentTick.ask>=rangeB_TS_level){
               trade.PositionModify(positionTicket,rangeB_TS,0); 
            }
         } 
                  
      }         
   }                     
}


void  checkTrailingSLSell(double bid){
 
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
         sellTS = NormalizeDouble(sellTS_level + tStep_points,_Digits);
         if(sellTS < currentTick.ask){
            sellTS = NormalizeDouble(currentTick.ask + tStep_points,_Digits);
         }
         //sellTS_TP = openPrice - tp_points;
         rangeS_TS = NormalizeDouble(rangeS_TS_level + tStep_points,_Digits);
         if(rangeS_TS < currentTick.ask){
            rangeS_TS = NormalizeDouble(currentTick.ask + tStep_points,_Digits);
         }  

         if(bear_sell>0){
            if(magic==InpMagicNumber && type==POSITION_TYPE_SELL && currentTick.bid<=sellTS_level){
               trade.PositionModify(positionTicket,sellTS,0);
            }
         }
         if(range_sell>0){
            if(magic==InpMagicNumber && type==POSITION_TYPE_SELL && currentTick.bid<=rangeS_TS_level){
               trade.PositionModify(positionTicket,rangeS_TS,0);
            }         
         }    

  
  
      }     
   }
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