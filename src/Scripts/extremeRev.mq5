//+------------------------------------------------------------------+
//|                                              ExtremeReversal.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input int HistoricalBars = 2;
input int LookbackCandles = 2;
input double ExtremeRangeFactor = 1.25;
input double ExtremeBodyFactorMax = 80;
input double ExtremeBodyFactorMin = 50;
input double ReversalBodyFactor = 50;



void OnStart(){
  
  ObjectsDeleteAll(0,-1,-1);
  int bars = MathMin(HistoricalBars,iBars(_Symbol,timeframe)-3);
  Print("Number of bars",bars);
  for(int i=bars;i>=1;i--){
      Print("\nChecking bar ", i, " (", TimeToString(iTime(_Symbol,timeframe,i)), ")");
      MarkCandles(i);
   }
}

//ith candle is the rev = i+1 is the extreme = i+2... are the lookback
void MarkCandles(int revCandleShift){

   double lbAverage = lastXAverage(revCandleShift+2,LookbackCandles);
   Print("For ",revCandleShift,"Average is ",lbAverage);

   // Extreme Candle Check i+1   
   double ehigh = iHigh(_Symbol,timeframe,revCandleShift+1);
   double elow = iLow(_Symbol,timeframe,revCandleShift+1);
   double eclose = iClose(_Symbol,timeframe,revCandleShift+1);
   double eopen = iOpen(_Symbol,timeframe,revCandleShift+1);
   
   double eCandleRange = ehigh-elow;
   Print("range of bar",revCandleShift+1,"is ",eCandleRange);
   double eBodyRange = MathAbs(eclose-eopen);
   double eBodyFactor = (eBodyRange>0)? (eBodyRange/eCandleRange)*100 : 0;
   Print("body Factor of bar ",revCandleShift+1,"is ",eBodyFactor);
   Print(ExtremeBodyFactorMin," ",ExtremeBodyFactorMax," ",lbAverage*ExtremeRangeFactor);
   if (eCandleRange >= lbAverage*ExtremeRangeFactor && eBodyFactor > ExtremeBodyFactorMin && eBodyFactor < ExtremeBodyFactorMax){
         //check for rev candle - i
         double high = iHigh(_Symbol,timeframe,revCandleShift);
         double low = iLow(_Symbol,timeframe,revCandleShift);
         double close = iClose(_Symbol,timeframe,revCandleShift);
         double open = iOpen(_Symbol,timeframe,revCandleShift);
         
         double revCandleRange = high-low;
         double revBodyRange = MathAbs(close-open);
         double revBodyFactor = (revBodyRange>0) ? (revBodyRange/revCandleRange)*100 : 0;
         
         if (revBodyFactor>ReversalBodyFactor){
             string arrowname = "Candle_" + TimeToString(iTime(_Symbol,timeframe,revCandleShift));
             datetime candletime = iTime(_Symbol,timeframe,revCandleShift);
             
            //if extreme candle is bullish and rev is bearish
            if(eclose>eopen && close<open){
               ObjectCreate(0,arrowname,OBJ_ARROW_SELL,0,candletime,iHigh(_Symbol,timeframe,revCandleShift)+50*_Point);
               ObjectSetInteger(0,arrowname,OBJPROP_COLOR,clrRed);
               ObjectSetInteger(0,arrowname,OBJPROP_WIDTH,5);
            }
            
            // if extreme candle is bearish and rev is bullish
            if(eclose<eopen && close>open){
               ObjectCreate(0,arrowname,OBJ_ARROW_BUY,0,candletime,iLow(_Symbol,timeframe,revCandleShift)-50*_Point);
               ObjectSetInteger(0,arrowname,OBJPROP_COLOR,clrGreen);
               ObjectSetInteger(0,arrowname,OBJPROP_WIDTH,5);
            }
         } 
   }
}
  
// Function to calculate average lookback candle range average
double lastXAverage(int startbar,int lookback){
   
   if(lookback <= 0) return 0;
   
   double sum = 0;
   int count = 0;
   for(int i=startbar;i<startbar+lookback;i++){
      
      if(i>=iBars(_Symbol,timeframe)) break;
      
      double high = iHigh(_Symbol,timeframe,i);
      double low = iLow(_Symbol,timeframe,i);
      sum += MathAbs(high-low);
      count++;
   }
   
   return (count>0) ? (sum/count) : 0;

}

