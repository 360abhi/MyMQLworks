
input double volume = 0.45;
input int magicnumber = 2020;
input string comment = __FILE__;

input int inputbandsperiod = 20;
input double deviation = 1.75;
input ENUM_APPLIED_PRICE inpappliedprice = PRICE_CLOSE;


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
      
     double upper1 = iMA(Symbol(),Period(),5,0,MODE_EMA,PRICE_CLOSE,1);
     if(low1>upper1){
       double size1 = (high1+(3*Point()))-low1;
       OpenOrder(ORDER_TYPE_SELL_STOP,low1,size1);
     }
     if(high1<upper1){
      double size2 = (high1 - low1 + (3*Point()));
      OpenOrder(ORDER_TYPE_BUY_STOP,high1,size2);
     }
   
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

int OpenOrder ( ENUM_ORDER_TYPE ordertype, double entryprice,double size){

   ///impp
   datetime expiration = iTime(Symbol(),Period(),0)+PeriodSeconds()-1;
   double tpprice=0.0;
   double slprice = 0.0;
   entryprice = NormalizeDouble(entryprice,Digits());
   if(ordertype == ORDER_TYPE_SELL_STOP){
       tpprice = entryprice -4.5*(size);
       slprice = entryprice + size;
   //double price = 0.0;
   }
   if(ordertype == ORDER_TYPE_BUY_STOP){
       tpprice = entryprice + 4.5*(size);
       slprice = entryprice - size;
   }
   //how far check
   //double stoplevel = Point()*SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
  
   /*  if (ordertype%2 == ORDER_TYPE_SELL){  // buy or buystop
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
   */
   return(OrderSend(Symbol(),ordertype,volume,entryprice,0,slprice,tpprice,comment,magicnumber,expiration));
    
}