//+------------------------------------------------------------------+
//|                                                         fdr2.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int sellticket[100];
int buyticket[100];
int Bidx = 0, Sidx = 0;



extern double TrailingPoints = 115;
extern bool Buy=true, Sell = true;
extern bool BuyTrailingStop = false;
extern bool SellTrailingStop = false;
extern double StopLoss = 300;
extern double MinProfit = 20;
extern int MaxOrders = 10;
extern int percentagerisk = 20;
extern int CanGap = 30;
extern int Canbody = 30;
extern double  LotSize  =  0.01;//((AccountBalance()/100)*percentagerisk/100/(MarketInfo(Symbol(),MODE_TICKVALUE))/100); //lot size calculation



double AskLast = 0;
double BidLast = 0;
 
bool SellOpened = true, BuyOpened = true;


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
void start()
  {
//---
double obgHigh = iBands(Symbol(),_Period,20,2,0,PRICE_MEDIAN,MODE_UPPER,1);
double obglow = iBands(Symbol(),_Period,20,2,0,PRICE_MEDIAN,MODE_LOWER,1);
double obglmid = iBands(Symbol(),_Period,20,2,0,PRICE_MEDIAN,MODE_MAIN,1);

Label();



     if(Close[2] > obgHigh
      && Close[1] < Open[2]
       && Open[1] > Close[1]
        && Open[2] < Close[2] 
        && Close[1] > obglmid 
        && Close[1] < obgHigh
         )
      {
         if(SellOpened == true && Sell == true)
         
            if(Sell()== true)
            {
               SellOpened = false;
            }
         
       }else
            SellOpened = true;
 
      if(Low[0] < obglow)
      {
         CloseSell();
      }
     

      if(Close[2] < obglow 
      && Close[1] > Open[2]
       && Open[1] < Close[1]
        && Open[2] > Close[2]
         && Close[1] < obglmid
         && Close[1] > obglow)
      {           
               if( BuyOpened == true && Buy == true)
                  if(Buy() == true)
                  {
                    BuyOpened = false;
                  }                    
             
               
        }
          else
                   BuyOpened = true;
         
         
      
      if(High[0] > obgHigh)
      {
             CloseBuy();
      }
      
    
 }
 
 

 bool Sell()
 {
 
          if(OrdersTotal() < MaxOrders)
               { 
               if(CandleChk("SELL",Points(CanGap),Points(Canbody))== true)
             
                  sellticket[Sidx] = OrderSend(Symbol(),OP_SELL,LotSize,Bid,2,StopLossSET("SELL"),TakeProfitSET("SELL"),"My order",16384,0,clrGreen);
      
                     if(sellticket[Sidx] > 0)
                     {
                        Sidx++;
                         Alert("Ordem BUY Aberta Com Sucesso");
                        return true;
                     }
                    else
                    if(sellticket[Sidx] < 0)
                     printf("Error opening SELL order : ",sellticket[Sidx]," - ",GetLastError());
                }
                else
                Alert("Demasiadas Ordens");
             
          
          return false;
         
 }
 
 
 bool Buy()
 {
          
            if( OrdersTotal() < MaxOrders)
            {
               if(CandleChk("BUY",Points(CanGap),Points(Canbody))==true)
                  buyticket[Bidx] = OrderSend(Symbol(),OP_BUY,LotSize,Ask,2,StopLossSET("BUY"),TakeProfitSET("BUY"),"My order",001,0,clrGreen);                          
                  
                   if(buyticket[Bidx] > 0)
                     {
                        Bidx++;
                        Alert("Ordem BUY Aberta Com Sucesso");
                        return true;
                     }
                      else
                      if(buyticket[Bidx] < 0)
                    printf("Error opening BUY order : ",buyticket[Bidx]," - ",GetLastError());
               
            }
            return false;
 }
 

void CloseBuy()
{
   for(int i = 0; i < Bidx; i++)
   {
         if(OrderSelect(buyticket[i],SELECT_BY_TICKET)== true)
         {
            if(OrderCloseTime() == 0 && OrderSymbol() == Symbol())
            {
            
               if(BuyTrailingStop == true)
               Area51(buyticket[i],"BUY");
               else
               if(OrderClose(buyticket[i], OrderLots(), OrderClosePrice() , 2)== true)
               {
               }
            }
         }
         else
         Alert("Erro ao Selectionar ",buyticket[i]);
    } 
}



void CloseSell()
{
   for(int i = 0; i < Sidx; i++)
   {
             if( OrdersTotal() < 10)
            {
               if(OrderSelect(sellticket[i],SELECT_BY_TICKET)== true)
               {
                if( OrderCloseTime() == 0 && OrderSymbol() == Symbol())
                  {
                  if(SellTrailingStop == true)
                   Area51(sellticket[i],"SELL");
                   else
                   if(OrderClose(sellticket[i], OrderLots(), OrderClosePrice(), 2)== true)
                  {
                     Alert("Ordem: ", sellticket[i]," Fechada. Profit: £",Profit(OrderTicket(),"SELL")); 
                  }
                  }  
               }
               else
                  Alert("Erro ao Selectionar ",sellticket[i]);
            }     
    }
}



double Profit(int orderticket, string BuyOrSell)
{
   double open, current,res = 0;
   
  if( OrderSelect(orderticket,SELECT_BY_TICKET)==true)
  {
      open = OrderOpenPrice();
      current = OrderClosePrice();
      
      if(BuyOrSell == "Buy")
      {
         res = current-open;
      }
      if(BuyOrSell == "Sell")
      {
         res=open-current;
      }
      
  }
  else
   return -1;
  
  return res*10000;
}



bool CandleChk(string BuyOrSell, double minGap,double candleBody)
{
   double Candle_2 = 0;
   double Candle_1= 0;
   double Gap = 0;
      
      
         //Verificar se a candle vai pra é up ou down
         //BUY
         if( BuyOrSell == "BUY") 
         {
                      Candle_1 = Close[1] - Open[1]; //Body candle 1
                      Candle_2 = Open[2] - Close[2]; // Body candle 2 
                      Gap = Close[1]-Open[2];
                      
                     if(Gap >= minGap && Candle_2 >= candleBody)
                     {  
                        //Alert("GAP ",Gap ,"CanGap ",minGap);
                       return true;
                       }

         }
         else
         //SELL
         if( BuyOrSell == "SELL")
         {
                   Candle_1 = Open[1] - Close[1];
                   Candle_2 = Close[2] - Open[2];
                   Gap = Open[2]-Close[1];
                   
                  // Alert("Candle ",Candle_2 ," minCandle  ",candleBody);
                   if(Gap >= minGap)
                     if(Candle_2 >= candleBody)
                         return true;
         }

      
   return false;
}




double Points(double pp)
{
double res=0;
if(Point == 0.00001)
    {
    res = pp/100000;
      
       return res;
       
    } else
    if(Point == 0.001)
     {
      res = pp/10000;
      return res;
     } 
    else 
    if(Point == 0.01)
    { 
       return pp/10000;
       }
       return -1;
 }
 
 
 
 
double TakeProfitSET(string BuyOrSell)
{
   double takeP= 0;
   double  stopl=0;
   if(BuyOrSell == "SELL")
      {
         stopl = StopLossSET("SELL");
        
        takeP = Ask-stopl;
      takeP = takeP+Ask+Points(20);
        
      }
      
      else
      if(BuyOrSell == "BUY")
      {
         stopl = StopLossSET("BUY");
        
        takeP = Bid-stopl;
        takeP = takeP+Bid+Points(20);
      }
      
     
      return 0.0;
}




double StopLossSET(string BuyOrSell)
{
   double stopL = 0;
      if(BuyOrSell == "SELL")
      {
            stopL = Bid+Points(StopLoss);   
           // Alert("STOP: ",stopL);
      }
      else
      if(BuyOrSell == "BUY")
      {
            stopL = Ask-Points(StopLoss);        

      }
     
      return stopL;
}



void Label()
{
    ObjectCreate("Spread",OBJ_LABEL,0,0,0);
   ObjectSetText("Spread","Spread: "+MarketInfo(Symbol(),MODE_SPREAD),10,"ARIAL",Blue);
   ObjectSet("Spread",OBJPROP_CORNER,4);
   ObjectSet("Spread",OBJPROP_XDISTANCE,30);
   ObjectSet("Spread",OBJPROP_YDISTANCE,40);
   
   ObjectCreate("AOrders",OBJ_LABEL,0,0,0);
   ObjectSetText("AOrders","Active Orders: "+OrdersTotal(),10,"ARIAL",Blue);
   ObjectSet("AOrders",OBJPROP_CORNER,4);
   ObjectSet("AOrders",OBJPROP_XDISTANCE,30);
   ObjectSet("AOrders",OBJPROP_YDISTANCE,60);
}



bool Area51(int orderticket, string BuyOrSell)
{

   double  newSL= 0;
   
   

   if( OrderSelect(orderticket,SELECT_BY_TICKET)==true)
  {
     
      
      if(BuyOrSell == "SELL")
      {
          if(SellTrailingStop == true)
          {
              newSL = Ask+Points(TrailingPoints);
                  Alert("Trailing :", Points(TrailingPoints));
               if(newSL > Ask-Points(TrailingPoints) && newSL < OrderStopLoss())
               if(OrderModify(orderticket,OrderClosePrice(),newSL,OrderTakeProfit(),OrderExpiration(),clrAliceBlue)==true)
               {
                  return true;   
               }
               else
               {
               Alert("Erro ao modificar ordem: ", orderticket);
               Alert("SL: ", newSL);
               }
            }
      }
       if(BuyOrSell == "BUY")
      {
      if(BuyTrailingStop == true)
      {
         if(Bid+Points(TrailingPoints) != OrderStopLoss())
            newSL = Bid-Points(TrailingPoints);
            
            if(Bid+Points(TrailingPoints) > newSL && newSL > OrderStopLoss())
            if(OrderModify(orderticket,OrderClosePrice(),newSL,OrderTakeProfit(),OrderExpiration(),clrAliceBlue)==true)
               {
                  return true;
               }
               else
               Alert("Erro ao modificar ordem: ", orderticket);
            }
      
      }
    
      
   }
   return false;
}
//Alert(SymbolName(1,true));

//+------------------------------------------------------------------+
