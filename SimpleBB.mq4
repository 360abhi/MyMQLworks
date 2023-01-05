//+------------------------------------------------------------------+
//|                                                     SimpleBB.mq4 |
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

input int inputbandsperiod = 20;
input double deviation = 2.0;
input ENUM_APPLIED_PRICE inpappliedprice = PRICE_CLOSE;

input double tpdeviations = 1.0;
input double sldeviations = 1.0;

input double volume = 0.01;
input int magicnumber = 2020;
input string comment = __FILE__;

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
//---
   if( !isNewBar()) return;
   
   double close1 = iClose(Symbol(),Period(),1);
   double high1 = iHigh(Symbol(),Period(),1);
   double low1 = iLow(Symbol(),Period(),1);
   
   double upper1 = iBands(Symbol(),Period(),inputbandsperiod,deviation,0
                           ,inpappliedprice,MODE_UPPER,1);
  
   double lower1 = iBands(Symbol(),Period(),inputbandsperiod,deviation,0
                           ,inpappliedprice,MODE_LOWER,1);
   
   double close2 = iClose(Symbol(),Period(),2);
   double upper2 = iBands(Symbol(),Period(),inputbandsperiod,deviation,0
                           ,inpappliedprice,MODE_UPPER,2);
   double lower2 = iBands(Symbol(),Period(),inputbandsperiod,deviation,0
                           ,inpappliedprice,MODE_LOWER,1);
                           
   
   if(close2>upper2 && close1<upper1){
      OpenOrder(ORDER_TYPE_SELL_STOP,low1,(upper1-lower1));
   }
   
   if(close2<lower2 && close1>lower1){
      OpenOrder(ORDER_TYPE_BUY_STOP,high1,(upper1-lower1));
   }
   return;
  }
//+------------------------------------------------------------------+

bool isNewBar(){
   
   datetime current = iTime(Symbol(),Period(),0);
   static datetime prev = current;
   
   if(prev < current){
      prev = current;
      return(true);
   
   }
   return(false);
}

int OpenOrder ( ENUM_ORDER_TYPE ordertype, double entryprice,double channelwidth){

   double ndeviation = channelwidth/(2*deviation);
   double tp = deviation * tpdeviations;
   double sl = deviation * sldeviations;
   ///impp
   datetime expiration = iTime(Symbol(),Period(),0)+PeriodSeconds()-1;
   
   entryprice = NormalizeDouble(entryprice,Digits());
   double tpprice = 0.0;
   double slprice = 0.0;
   double price = 0.0;
   
   //how far check
   double stoplevel = Point()*SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
   
   if (ordertype%2 == ORDER_TYPE_BUY){  // buy or buystop
      price = Ask;
      if(price >=(entryprice-stoplevel)) {
         entryprice = price;
         ordertype = ORDER_TYPE_BUY;
      }
      tpprice = entryprice+tp;
      slprice = entryprice-sl;
   }else{
      if (ordertype%2 == ORDER_TYPE_SELL){  // buy or buystop
         price = Bid;
         if(price <=(entryprice+stoplevel)) {
            entryprice = price;
            ordertype = ORDER_TYPE_SELL;
         }
         tpprice = entryprice-tp;
         slprice = entryprice+tp;
      }else{
      return(0);
   }
   }
   return(OrderSend(Symbol(),ordertype,volume,entryprice,0,slprice,tpprice,comment,magicnumber,expiration));
    
}