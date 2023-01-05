//+------------------------------------------------------------------+
//|                                             SpreadCalculator.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
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

   double spread = CalculateSpread(Ask,Bid);
   string spread_message = "The current spread is : " ;
   
   Comment(spread_message,spread);
   
  }
//+------------------------------------------------------------------+

double CalculateSpread(double pAsk, double pBid){

   double spread = pAsk - pBid;
   spread = spread/ _Point;
   return spread;

}