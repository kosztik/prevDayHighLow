//+------------------------------------------------------------------+
//|                        PrevDayHighLow.mq4                        |
//|   Az előző napok maximumát és minimumát húzza ki                 |
//+------------------------------------------------------------------+
#property indicator_chart_window

//--- input parameters
input color   HighColor = clrLime;         // Mai high vonal színe
input color   LowColor  = clrRed;          // Mai low vonal színe
input color   HistoryHighColor = clrGray;  // Korábbi high vonalak színe
input color   HistoryLowColor = clrGray;   // Korábbi low vonalak színe
input int     LineStyle = STYLE_DOT;       // Vonalak stílusa
input int     LineWidth = 2;               // Vonalak vastagsága
input int     HistoryDays = 30;            // Hány napra visszamenőleg rajzoljon

//--- global variables
double prevHigh = 0;
double prevLow  = 0;
datetime prevDay = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
    //--- Get the current day
    datetime today = iTime(NULL, PERIOD_D1, 0);

    //--- Only update if new day or first run
    if (prevDay != today)
    {
        int i;
        //--- Delete all previous lines
        for (i = 0; i <= HistoryDays; i++)
        {
            ObjectDelete("PrevDayHigh_" + IntegerToString(i));
            ObjectDelete("PrevDayLow_" + IntegerToString(i));
        }
        
        //--- Draw lines for today and historical days
        for (i = 0; i <= HistoryDays; i++)
        {
            //--- Get high and low for this day
            double dayHigh = iHigh(NULL, PERIOD_D1, i+1);
            double dayLow = iLow(NULL, PERIOD_D1, i+1);
            
            //--- Calculate day start and end
            datetime dayStart = iTime(NULL, PERIOD_D1, i);
            datetime dayEnd = dayStart + 24 * 60 * 60;
            
            //--- Set colors based on whether it's the most recent day or historical
            color highLineColor = (i == 0) ? HighColor : HistoryHighColor;
            color lowLineColor = (i == 0) ? LowColor : HistoryLowColor;
            
            //--- High line
            string highLineName = "PrevDayHigh_" + IntegerToString(i);
            ObjectCreate(highLineName, OBJ_TREND, 0, dayStart, dayHigh, dayEnd, dayHigh);
            ObjectSet(highLineName, OBJPROP_COLOR, highLineColor);
            ObjectSet(highLineName, OBJPROP_STYLE, LineStyle);
            ObjectSet(highLineName, OBJPROP_WIDTH, LineWidth);
            ObjectSet(highLineName, OBJPROP_RAY, false); // Sugár kikapcsolása
            
            //--- Low line
            string lowLineName = "PrevDayLow_" + IntegerToString(i);
            ObjectCreate(lowLineName, OBJ_TREND, 0, dayStart, dayLow, dayEnd, dayLow);
            ObjectSet(lowLineName, OBJPROP_COLOR, lowLineColor);
            ObjectSet(lowLineName, OBJPROP_STYLE, LineStyle);
            ObjectSet(lowLineName, OBJPROP_WIDTH, LineWidth);
            ObjectSet(lowLineName, OBJPROP_RAY, false); // Sugár kikapcsolása
        }
        
        prevDay = today;
    }
    
    return(0);
}
//+------------------------------------------------------------------+
