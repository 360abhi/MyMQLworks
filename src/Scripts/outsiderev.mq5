/*
Engulfing bar could be 5-25% bigger than the avg lookback
if volatility low, higher bar preferred, if volatility high low% bar is okay
*/


#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

// Global Variables
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input int LookBackCandles = 10;
input double EngulfingFactor = 1.1;
input int HistoricalBars = 100;
input double EngulfingbodyPerc = 50;


void OnStart(){

   ObjectsDeleteAll(0,-1,-1);
   int bars = MathMin(HistoricalBars,iBars(_Symbol,timeframe)-2);
   for(int i=bars;i>0;i--){
      MarkCandles(i);
   }
   
  }
  
void MarkCandles(int shift){
   
   // Getting prev bars high low
   double phigh = iHigh(_Symbol,timeframe,shift+1);
   double plow = iLow(_Symbol,timeframe,shift+1);
   
   // Getting current OutsideBar values
   double high = iHigh(_Symbol,timeframe,shift);
   double low = iLow(_Symbol,timeframe,shift);
   double open = iOpen(_Symbol,timeframe,shift);
   double close = iClose(_Symbol,timeframe,shift);
   
   //Bullish outsideBar Check
   if(low<plow && close>phigh && close>open){
   
      // Check RangeFactor of the Engulfing candle   
      double candleRange,bodyRange;
      double average = lastXAverage(shift+1,LookBackCandles);
      BodyRange(high,low,close,open,candleRange,bodyRange);
      
      if(bodyRange>=EngulfingbodyPerc && candleRange>=EngulfingFactor*average){
         DrawSymbol(shift,"BULL");
      }
      
   }
   
   // Bearish outsideBar Check
   if(high>phigh && close<plow && close<open){
   
      double candleRange,bodyRange;
      double average = lastXAverage(shift+1,LookBackCandles);
      BodyRange(high,low,close,open,candleRange,bodyRange);
      
      if(bodyRange>=EngulfingbodyPerc && candleRange>=EngulfingFactor*average){
         DrawSymbol(shift,"BEAR");
      }
      
   }
}

void BodyRange(double high,double low,double close,double open,double &candleRange,double &bodyRange){
   

   candleRange = high - low;
   double candleBody = MathAbs(close-open);
   bodyRange = (candleBody > 0) ? (candleBody/candleRange)*100 : 0;
}

void DrawSymbol(int shift,string candleType){
   
   string arrowname = "Candle_" + TimeToString(iTime(_Symbol,timeframe,shift));
   datetime candletime = iTime(_Symbol,timeframe,shift);
   
   if (candleType == "BULL"){
      ObjectCreate(0,arrowname,OBJ_ARROW_BUY,0,candletime,iLow(_Symbol,timeframe,shift)-50*_Point);
      ObjectSetInteger(0,arrowname,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,arrowname,OBJPROP_WIDTH,5);
   }
   if (candleType == "BEAR"){
      ObjectCreate(0,arrowname,OBJ_ARROW_SELL,0,candletime,iHigh(_Symbol,timeframe,shift)+50*_Point);
      ObjectSetInteger(0,arrowname,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,arrowname,OBJPROP_WIDTH,5);
   }
      
   
}

// Function takes in the start candle and the lookback
double lastXAverage(int start,int lookback){
   
   if(lookback<=0) return 0;
   double sum = 0;
   int count = 0;
   for(int i=start;i<start+lookback;i++){
   
      if(i>=iBars(_Symbol,timeframe)) break;
   
      double high = iHigh(_Symbol,timeframe,i);
      double low = iLow(_Symbol,timeframe,i);
      sum += high-low;
      count++;   
   }
   return (count>0) ? (sum/count) : 0;
}
