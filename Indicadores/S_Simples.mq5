//+------------------------------------------------------------------+
//|                                                   S1_Simples.mq5 |
//|          Indicador que plota o retorno normalizado e a sua média |
//|                   Mostra níveis % do desvio padrão da amostragem |
//+------------------------------------------------------------------+
#property copyright   "Simples.app.br"
#property link        ""
#property description "Simples"

#include <Math\Stat\Math.mqh>
#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_label1  "Simples"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_label2  "Média Simples"
#property indicator_level1  0
#property indicator_level2  0.02
#property indicator_level3  0.03
#property indicator_level4  0.04
#property indicator_level5  0.05
input group        ">>>>> Parâmetros Simples <<<<<";
input int     parperiodo  = 8;       // Simples - Periodo
input double  parlim      = 2;       // Simples - Desvio Padrão
input int     parmedia    = 4;       // Simples - Média
//--- indicator buffer
double bAA[];
double bVA[];
double bMM[];
double bTE[];
double _acu = 0;
//+------------------------------------------------------------------+
//|                      |
//+------------------------------------------------------------------+
void OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetString(INDICATOR_SHORTNAME,"Simples");
   SetIndexBuffer(0, bAA,INDICATOR_DATA);
   SetIndexBuffer(1, bMM,INDICATOR_DATA);
   SetIndexBuffer(2, bTE,INDICATOR_DATA);
   SetIndexBuffer(3, bVA,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(bAA,true);
   ArraySetAsSeries(bVA,true);
   ArraySetAsSeries(bMM,true);
   ArraySetAsSeries(bTE,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Deleta setas
   ObjectsDeleteAll(0, "seta", 0, OBJ_ARROW_BUY);
   ObjectsDeleteAll(0, "seta", 0, OBJ_ARROW_SELL);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   double _med;
   double _m[];
   double stddev;
   _acu = bVA[1];
   int inicio;
   inicio=MathMin(rates_total-prev_calculated, rates_total-2);
   for(int i=inicio; i >= 0; i--)
     {
      double _ret = ((close[i] / open[i]) - 1) * 100 ;
      _acu = _acu + _ret;
      bVA[i] = _acu;
      ArrayCopy(_m, bVA, 0, i, parperiodo);
      _med  = MathMean(_m);
      ArrayFree(_m);
      bAA[i] = bVA[i] - _med;
      ArrayCopy(_m, bAA, 0, i, parmedia);
      _med  = MathMean(_m);
      ArrayFree(_m);
      bMM[i] = _med;
      ArrayCopy(_m, bAA, 0, i, 300);
      stddev  = MathStandardDeviation(_m) ;
      double limite  = stddev * parlim ;
      double lateral = stddev * 0.65  ;
      ArrayFree(_m);
      IndicatorSetDouble(INDICATOR_MAXIMUM,(limite*2.5));
      IndicatorSetDouble(INDICATOR_MINIMUM,(limite*(-2.5)));
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0);
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, limite);
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, limite * (-1));
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 3,lateral);
      IndicatorSetDouble(INDICATOR_LEVELVALUE, 4,lateral * (-1));
     }
   ChartRedraw();
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
