#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>

// Input variables
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input double LongEma = 200;
input double ShortMa = 5;
input double RsiPeriod = 2;
input double BuyLevel = 10;
input double SellLevel = 90;
input bool AccBalanceUse = true;
input double LotSize = 1;
input bool TimeExit = false;
input int TimeExitCandles = 5;
input int MagicNumber = 3434;


datetime LastBarTime;
CTrade trade;

// Global variables for indicators
int rsiHandle;
int maHandle;
int emaHandle;


int OnInit(){
   
   // Creating handles for indicators
   rsiHandle = iRSI(_Symbol,timeframe,RsiPeriod,PRICE_CLOSE);
   maHandle = iMA(_Symbol,timeframe,ShortMa,0,MODE_SMA,PRICE_CLOSE);
   emaHandle = iMA(_Symbol,timeframe,LongEma,0,MODE_EMA,PRICE_CLOSE);
   LastBarTime = iTime(_Symbol,timeframe,0);
   
   trade.SetExpertMagicNumber(MagicNumber);
   
   if(rsiHandle == INVALID_HANDLE || maHandle == INVALID_HANDLE || emaHandle == INVALID_HANDLE){
      Print("Failed to Create indicator Handler");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){
   
   Print("EA removed for the reason ",reason);
   
  }

void OnTick(){
   
   if(isNewBar()){
   
      double rsiBuffer[];
      double maBuffer[];
      double emaBuffer[];
   
      CopyBuffer(rsiHandle,0,1,1,rsiBuffer);
      CopyBuffer(maHandle,MAIN_LINE,1,2,maBuffer);
      CopyBuffer(emaHandle,MAIN_LINE,1,2,emaBuffer);
      
      // Prev candle values
      double close = iClose(_Symbol,timeframe,1);
      double open = iOpen(_Symbol,timeframe,1);
      Print(rsiBuffer[0]);
      //rsiBuffer[0] = MathRound(rsiBuffer[0]);
      
      // Close positions if exist
      PositionsClose(maBuffer[0],close);
      
      // Open positions if conditions meet
      OpenPositions(rsiBuffer[0],emaBuffer[0],close);
      
   }
   
  }

bool isNewBar(){

   datetime currentBarTime = iTime(_Symbol,timeframe,0);
   if(currentBarTime != LastBarTime){
      LastBarTime = currentBarTime;
      return true;
   }
   return false;

}

void PositionsClose(double maValue,double close){
   
   for(int i=0;i<PositionsTotal();i++){
      
      // Now EA knwos we're talking about which position
      ulong posTicket = PositionGetTicket(i);
      
      // Skip if the position is of another timeframe or another EA
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      
      // can get the position values using its ticket
      double posPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
      double posSL = PositionGetDouble(POSITION_SL);
      double posTP = PositionGetDouble(POSITION_PROFIT);
      double posVol = PositionGetDouble(POSITION_VOLUME);
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && close > maValue){
         trade.PositionClose(posTicket);
      }
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && close < maValue){
         trade.PositionClose(posTicket);
      }
   } 
}

void OpenPositions(double rsiVal,double filterVal,double close){
   
   int totalPositions = PositionsTotal();
   
   //Buy
   if(totalPositions == 0 && close > filterVal && rsiVal < BuyLevel){
      //double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      //double lotSize = MathRound(balance * 0.01 / 1000.0 * 100) / 100;
      trade.Buy(LotSize,_Symbol,0.0,0.0,0.0,"Market Buy Order");
   }
   
   if(totalPositions == 0 && close < filterVal && rsiVal > SellLevel){
      //double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      //double lotSize = MathRound(balance * 0.01 / 1000.0 * 100) / 100; // Forces 2 decimal places
      trade.Sell(LotSize,_Symbol,0.0,0.0,0.0,"Market Sell Order");
   }
   
}