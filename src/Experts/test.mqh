
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>

// Input
input ENUM_TIMEFRAMES HighTimeframe = PERIOD_D1;
input ENUM_TIMEFRAMES MidTimeframe = PERIOD_H4;
input ENUM_TIMEFRAMES EntryTimeframe = PERIOD_M30;
input double RSIAboveLimit1 = 60;
input double RSILowerLimit1 = 40;
input int FilterMAPeriod = 200;
input int MagicNumber = 4767;

CTrade trade;
datetime lastBarTime;

// Indicator handlers
int highRsiHandle;
int midRsiHandle;
int entryRsiHandle;
int maHandle;


int OnInit(){
     
   Print("Above",RSIAboveLimit1);

   lastBarTime = iTime(_Symbol,EntryTimeframe,0);
   highRsiHandle = iRSI(_Symbol,HighTimeframe,14,PRICE_CLOSE);
   midRsiHandle = iRSI(_Symbol,MidTimeframe,14,PRICE_CLOSE);
   entryRsiHandle = iRSI(_Symbol,EntryTimeframe,14,PRICE_CLOSE);
   maHandle = iMA(_Symbol,HighTimeframe,FilterMAPeriod,0,MODE_SMA,PRICE_CLOSE);
   
   trade.SetExpertMagicNumber(MagicNumber);
   
   if(highRsiHandle == INVALID_HANDLE || midRsiHandle == INVALID_HANDLE || entryRsiHandle == INVALID_HANDLE ||
      maHandle == INVALID_HANDLE){
         Print("Indicators handlers Exception");
         return (INIT_FAILED);
      }

   return(INIT_SUCCEEDED);
  }


void OnDeinit(const int reason){
   
   Print("EA removed due to reason: ",reason);
   
  }
  

void OnTick(){

   if(!isNewBar()) return;
   
   double highrsi[1];
   double midrsi[1];
   double entryrsi[1];
   double ma[1];
   
   if(CopyBuffer(highRsiHandle, 0, 0, 1, highrsi) != 1 || 
      CopyBuffer(midRsiHandle,  0, 0, 1, midrsi)  != 1 || 
      CopyBuffer(entryRsiHandle,0, 1, 1, entryrsi)!= 1 ||  // Previous candle (index 1)
      CopyBuffer(maHandle, MAIN_LINE, 0, 1, ma)   != 1) {
      Print("Failed to copy indicator buffers!");
      return;
   }
   // HighTimeframe Candle
   double hhigh = iHigh(_Symbol,HighTimeframe,0);
   double hlow = iLow(_Symbol,HighTimeframe,0);

   // Close existing positions
   ClosePositions(hlow,hhigh,highrsi[0],ma[0],midrsi[0],entryrsi[0]);
   
   // Open Positions
   OpenPositions(hlow,hhigh,highrsi[0],ma[0],midrsi[0],entryrsi[0]);
    
   
  }

bool isNewBar(){

   datetime currentBarTime = iTime(_Symbol,EntryTimeframe,0);
   if(lastBarTime != currentBarTime){
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

void OpenPositions(double hlow,double hhigh,double highrsi,double highma,double midrsi,double entryrsi){

   int totalPositions = PositionsTotal();
   
   //Buy
   if (totalPositions == 0 && hlow>highma && highrsi > RSIAboveLimit1 && midrsi > RSIAboveLimit1 &&
      entryrsi > RSIAboveLimit1){
         trade.Buy(1.0,_Symbol,0.0,0.0,0.0,"Market Buy Order");
      }
      
   // Sell 
   if (totalPositions == 0 && hhigh < highma && highrsi < RSILowerLimit1 && midrsi < RSILowerLimit1 && 
      entryrsi < RSILowerLimit1){
         trade.Sell(1.0,_Symbol,0.0,0.0,0.0,"Market Sell Order");
      }

}

void ClosePositions(double hlow,double hhigh,double highrsi,double highma,double midrsi,double entryrsi){

   for(int i=0;i<PositionsTotal();i++){
      ulong posTicket = PositionGetTicket(i);
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
         if(entryrsi < RSILowerLimit1){
            trade.PositionClose(posTicket);
         }
      }
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
         if(entryrsi > RSIAboveLimit1){
            trade.PositionClose(posTicket);
         }
      }
      
   }


}
