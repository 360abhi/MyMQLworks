
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input int HistoricalBars = 100;
input double MiddleCandleBodyRange = 66;


void OnStart(){
  
  ObjectsDeleteAll(0,-1,-1);
  int bars = MathMin(HistoricalBars,iBars(_Symbol,timeframe)-3);
  for(int i=bars;i>0;i--){
      MarkCandles(i);
  }
   
  }
  
void MarkCandles(int shift){

   // First Candle Details
   double fhigh = iHigh(_Symbol,timeframe,shift+2);
   double flow = iLow(_Symbol,timeframe,shift+2);
   double fclose = iClose(_Symbol,timeframe,shift+2);
   double fopen = iOpen(_Symbol,timeframe,shift+2);
   
   // Second Candle Details
   double shigh = iHigh(_Symbol,timeframe,shift+1);
   double slow = iLow(_Symbol,timeframe,shift+1);
   double sclose = iClose(_Symbol,timeframe,shift+1);
   double sopen = iOpen(_Symbol,timeframe,shift+1);
   double candleRange = shigh - slow;
   double candleBody = MathAbs(sclose-sopen);
   double bodyRange = (candleBody>0) ? (candleBody/candleRange)*100 : 0;
   
   // Third Candle Details
   double high = iHigh(_Symbol,timeframe,shift);
   double low = iLow(_Symbol,timeframe,shift);
   double open = iOpen(_Symbol,timeframe,shift);
   double close = iClose(_Symbol,timeframe,shift);
   
   //Bullish
   if(fclose<fopen && shigh<fhigh &&slow<flow && slow<low && bodyRange<=MiddleCandleBodyRange && close > shigh){
      DrawSymbol(shift,"BULL");
   }
   
   //Bearish
   if(fclose>fopen && slow>flow && shigh>fhigh && shigh>high && bodyRange<=MiddleCandleBodyRange && close<slow){
      DrawSymbol(shift,"BEAR");
   }
}

void DrawSymbol(int shift,string candleType){
   
   string arrowname = "Candle_" + TimeToString(iTime(_Symbol,timeframe,shift));
   datetime candletime = iTime(_Symbol,timeframe,shift);
   
   if(candleType == "BULL"){
      ObjectCreate(0,arrowname,OBJ_ARROW_BUY,0,candletime,iLow(_Symbol,timeframe,shift)-50*_Point);
      ObjectSetInteger(0,arrowname,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,arrowname,OBJPROP_WIDTH,5);
   }
   
   if(candleType == "BEAR"){
      ObjectCreate(0,arrowname,OBJ_ARROW_SELL,0,candletime,iHigh(_Symbol,timeframe,shift)+50* _Point);
      ObjectSetInteger(0,arrowname,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,arrowname,OBJPROP_WIDTH,5);
   }

}
  


