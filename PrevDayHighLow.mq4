//+------------------------------------------------------------------+
//|                        PrevDayHighLow.mq4                        |
//|   Az előző nap maximumát és minimumát húzza ki a mai napra       |
//+------------------------------------------------------------------+
#property indicator_chart_window

//--- input parameters
input color   HighColor = clrLime;
input color   LowColor  = clrRed;
input int     LineStyle = STYLE_DOT;
input int     LineWidth = 2;

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

    //--- Only update if new day
    if (prevDay != today)
    {
        //--- Get previous day's high and low
        prevHigh = iHigh(NULL, PERIOD_D1, 1);
        prevLow  = iLow(NULL, PERIOD_D1, 1);
        prevDay  = today;

        //--- Delete old lines
        ObjectDelete("PrevDayHigh");
        ObjectDelete("PrevDayLow");

        //--- Draw new lines for today
        datetime dayStart = iTime(NULL, PERIOD_D1, 0);
        datetime dayEnd   = dayStart + 24 * 60 * 60;

        //--- High line
        ObjectCreate("PrevDayHigh", OBJ_TREND, 0, dayStart, prevHigh, dayEnd, prevHigh);
        ObjectSet("PrevDayHigh", OBJPROP_COLOR, HighColor);
        ObjectSet("PrevDayHigh", OBJPROP_STYLE, LineStyle);
        ObjectSet("PrevDayHigh", OBJPROP_WIDTH, LineWidth);
        ObjectSet("PrevDayHigh", OBJPROP_RAY, false); // Sugár kikapcsolása

        //--- Low line
        ObjectCreate("PrevDayLow", OBJ_TREND, 0, dayStart, prevLow, dayEnd, prevLow);
        ObjectSet("PrevDayLow", OBJPROP_COLOR, LowColor);
        ObjectSet("PrevDayLow", OBJPROP_STYLE, LineStyle);
        ObjectSet("PrevDayLow", OBJPROP_WIDTH, LineWidth);
        ObjectSet("PrevDayLow", OBJPROP_RAY, false); // Sugár kikapcsolása
    }
    return(0);
}
//+------------------------------------------------------------------+
