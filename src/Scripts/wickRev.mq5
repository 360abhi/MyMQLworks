
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

// Global Variables
input double BodyFactor = 28;
input double CloseFactor = 15;
input ENUM_TIMEFRAMES timeframes = PERIOD_CURRENT;
input int HistoricalBars = 100;


void OnStart(){
   ObjectsDeleteAll(0,-1,-1);
   MarkCandles(HistoricalBars);
   
  }
  
// Takes in number of historical candles to mark
void MarkCandles(int num){

   for(int i=num;i>0;i--){
      double closeFactor,bodyFactor;
      string candleType;
      GetCandleInfo(i,closeFactor,bodyFactor,candleType);
      
      // Checking criteria
      if(closeFactor < CloseFactor && bodyFactor < BodyFactor){
         string arrowName = "Candle_" + IntegerToString(i);
         datetime candleTime = iTime(_Symbol,timeframes,i);
         
         if(candleType == "BULL"){
            ObjectCreate(0,arrowName,OBJ_ARROW_BUY,0,candleTime,iLow(_Symbol,timeframes,i)-50*_Point);
            ObjectSetInteger(0,arrowName,OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0,arrowName,OBJPROP_WIDTH,5);
         }else{
            ObjectCreate(0,arrowName,OBJ_ARROW_SELL,0,candleTime,iHigh(_Symbol,timeframes,i)+50*_Point);
            ObjectSetInteger(0,arrowName,OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0,arrowName,OBJPROP_WIDTH,5);
         }
         
      }
      
   }

}

// fills in value variable of bodyfactor,closefactor and candleType
void GetCandleInfo(int shift,double &closeFactor,double &bodyFactor,string &candleType){
   
   double high = iHigh(_Symbol,timeframes,shift);
   double low = iLow(_Symbol,timeframes,shift);
   double close = iClose(_Symbol,timeframes,shift);
   double open = iOpen(_Symbol,timeframes,shift);
   
   double candleRange = MathAbs(high-low);
   double bodyRange = MathAbs(open-close);
   bodyFactor = (candleRange>0)?(bodyRange/candleRange)*100 : 0;
   
   // For bullish candle
   if(close>open){
      double upperwick = high - MathMax(close,open);
      closeFactor = (upperwick/candleRange)*100;
      candleType = "BULL";
   // For bearish Candle
   }else{
      double lowerwick = MathMin(close,open) - low;
      closeFactor = (lowerwick/candleRange)*100;
      
      candleType = "BEAR";
   }

}

