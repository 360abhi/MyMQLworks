///+------------------------------------------------------------------+
//|                                                    AB
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, AB"

#include <trade/trade.mqh>

input ENUM_TIMEFRAMES Timeframe = PERIOD_M1;
input int rsiPeriods = 2;
input int filterMA = 200;
input int exitMa = 5;
input int MagicNumber = 89;
input double lotSize = 0.5;

int handleRsi;
int handlefilterMA;
int handleExitMA;
CTrade trade;
int barsTotal;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   Print("Ea initialized successfully");
   trade.SetExpertMagicNumber(MagicNumber);
   handleRsi = iRSI(_Symbol,Timeframe,rsiPeriods,PRICE_CLOSE);
   handlefilterMA = iMA(_Symbol,Timeframe,filterMA,0,MODE_SMA,PRICE_CLOSE);
   handleExitMA = iMA(_Symbol,Timeframe,exitMa,0,MODE_SMA,PRICE_CLOSE);
   barsTotal = iBars(NULL,Timeframe);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   Print("EA Removed for the reason ", reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int bars = iBars(NULL,Timeframe);
   double buylevel = 30.00;
   double sellLevel = 95.00;
   
//check if new bar has been generated
   if(barsTotal < bars)
     {
     
      barsTotal = bars;
      double rsi[];
      double filter[];
      double exit[];

      CopyBuffer(handleRsi,0,1,1,rsi);
      CopyBuffer(handlefilterMA,MAIN_LINE,1,2,filter);
      CopyBuffer(handleExitMA,MAIN_LINE,1,2,exit);

      double close = iClose(_Symbol,Timeframe,1);
      double open = iOpen(_Symbol,Timeframe,1);
      rsi[0] = MathRound(rsi[0]);
      
      for(int i=0;i<PositionsTotal();i=i+1){
         ulong posTicket = PositionGetTicket(i);
         
         if(PositionGetSymbol(POSITION_SYMBOL) != _Symbol) continue; 
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
         
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         
         double posPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
         double posSl = PositionGetDouble(POSITION_SL);
         double posTp = PositionGetDouble(POSITION_TP);
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && close > exit[0]){
            trade.PositionClose(posTicket);
         }else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && close > exit[0]){
            trade.PositionClose(posTicket);
         }
   }

      //Closing previous positions
      int totalPositions = PositionsTotal();
      //Buy Condition
      if(totalPositions==0 && rsi[0] <= buylevel && close > filter[0])
        {
         trade.Buy(lotSize,_Symbol,0.0,0.0,0.0,"Market Buy Order");
        }
      else
         if(totalPositions==0 && rsi[0] >=sellLevel && close < filter[0])
           {
            trade.Sell(lotSize,_Symbol,0.0,0.0,0.0,"Market Sell Order");
           }
     }

  }




//+------------------------------------------------------------------+