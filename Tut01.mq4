//+------------------------------------------------------------------+
//|                                                        Tut01.mq4 |
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

input int Momentum_period = 14;
input double threshold = 100;

//global variables
int gbuyticket = 0;
int gsellticket = 0;
datetime getbartime;

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
      datetime rightbartime = iTime(_Symbol,_Period,0);
      if(rightbartime != getbartime){
         getbartime = rightbartime;
         OnBar();
      }
   
  }
  
  
 void OnBar(){
   
   double currmom = iMomentum(Symbol(),Period(),Momentum_period,PRICE_CLOSE,1);
   double prevmom = iMomentum(Symbol(),Period(),Momentum_period,PRICE_CLOSE,2);
   //bool isbought = false;
   double momthreshold = threshold;
   
   if(currmom > threshold && prevmom < threshold ){
      Comment("Go long");
      //isbought = true;
      gbuyticket = OrderSend(Symbol(),OP_BUY,0.01,Ask,50,0,0,"aise hi",99);
      if(gsellticket>0){
         OrderClose(gsellticket,0.01,Ask,50);
      }
   }else if( currmom < threshold && prevmom > threshold){
      Comment("Go short");
      gsellticket = OrderSend(Symbol(),OP_SELL,0.01,Bid,50,0,0,"aise",99);
      if(gbuyticket>0){
         OrderClose(gbuyticket,0.01,Bid,50);
      }
   }
 }
 
  
  
//+------------------------------------------------------------------+
