//+------------------------------------------------------------------+
//|                        PrevDayHighLow.mq4                        |
//|   Az előző napok maximumát és minimumát húzza ki                 |
//|   Módosítva: Külön paraméterezhető korábbi napok stílusa/vastagsága|
//+------------------------------------------------------------------+
#property indicator_chart_window

//--- input parameters
input color   HighColor = clrLime;         // Legutóbbi előző napi high vonal színe
input color   LowColor  = clrRed;          // Legutóbbi előző napi low vonal színe
input int     LineStyle = STYLE_SOLID;     // Legutóbbi előző napi vonalak stílusa
input int     LineWidth = 2;               // Legutóbbi előző napi vonalak vastagsága

input color   HistoryHighColor = clrGray;  // Korábbi high vonalak színe
input color   HistoryLowColor = clrGray;   // Korábbi low vonalak színe
input int     HistoryLineStyle = STYLE_DOT; // Korábbi vonalak stílusa (ÚJ)
input int     HistoryLineWidth = 1;       // Korábbi vonalak vastagsága (ÚJ)

input int     HistoryDays = 30;            // Hány napra visszamenőleg rajzoljon

//--- global variables
datetime prevDay = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Töröljük az összes objektumot, amit az indikátor létrehozott
    DeleteAllObjects(HistoryDays);
}

//+------------------------------------------------------------------+
//| Delete all indicator objects                                     |
//+------------------------------------------------------------------+
void DeleteAllObjects(int days) // Paraméterként átvesszük a napok számát
{
    // Töröljük az összes vonalat az adott számú napra visszamenőleg
    // Biztonság kedvéért kicsit többet törlünk, ha esetleg a HistoryDays változott
    for (int i = 0; i <= days + 5; i++)
    {
        ObjectDelete(0, "PrevDayHigh_" + IntegerToString(i)); // Chart ID hozzáadva (0 = aktuális)
        ObjectDelete(0, "PrevDayLow_" + IntegerToString(i));  // Chart ID hozzáadva (0 = aktuális)
    }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() // Régebbi MQL4 stílus, de működik
{
    //--- Get the current day's start time
    datetime today = iTime(NULL, PERIOD_D1, 0);

    //--- Only update if new day or first run
    if (prevDay != today)
    {
        //--- Delete all previous lines before drawing new ones
        //--- Fontos, hogy a ciklus előtt töröljünk, hogy ne villogjon
        DeleteAllObjects(HistoryDays);

        //--- Draw lines for the most recent previous day and historical days
        for (int i = 0; i <= HistoryDays; i++)
        {
            //--- Get high and low for the (i+1) previous day
            //--- i=0 -> tegnap (1 barral ezelőtt a D1-en)
            //--- i=1 -> tegnapelőtt (2 barral ezelőtt a D1-en)
            //--- stb.
            double dayHigh = iHigh(NULL, PERIOD_D1, i + 1);
            double dayLow = iLow(NULL, PERIOD_D1, i + 1);

            // Ha nincs adat az adott napra (pl. túl régi), ne rajzoljunk
            if (dayHigh == 0 || dayLow == 0) continue;

            //--- Calculate the start and end time for the day being drawn
            //--- Ez a nap i nappal ezelőtt kezdődött a *jelenlegi* naphoz képest
            datetime dayStart = iTime(NULL, PERIOD_D1, i);
            datetime dayEnd = dayStart + PeriodSeconds(PERIOD_D1); // Pontosabb, mint 24*60*60

            //--- Set colors, style, and width based on whether it's the most recent previous day (i=0) or historical (i>0)
            color currentHighColor;
            color currentLowColor;
            int   currentStyle;
            int   currentWidth;

            if (i == 0) // Legutóbbi előző nap
            {
                currentHighColor = HighColor;
                currentLowColor = LowColor;
                currentStyle = LineStyle;
                currentWidth = LineWidth;
            }
            else // Korábbi napok
            {
                currentHighColor = HistoryHighColor;
                currentLowColor = HistoryLowColor;
                currentStyle = HistoryLineStyle; // Új paraméter használata
                currentWidth = HistoryLineWidth; // Új paraméter használata
            }

            //--- High line
            string highLineName = "PrevDayHigh_" + IntegerToString(i);
            // Objektum létrehozása vagy módosítása (biztonságosabb, mint a create)
            if (!ObjectCreate(0, highLineName, OBJ_TREND, 0, dayStart, dayHigh, dayEnd, dayHigh))
            {
                 // Ha már létezik, csak a végpontot módosítjuk (bár itt a törlés miatt ez nem feltétlen szükséges)
                 ObjectSetInteger(0, highLineName, OBJPROP_TIME, 1, dayEnd);
                 ObjectSetDouble(0, highLineName, OBJPROP_PRICE, 1, dayHigh);
            }
            ObjectSetInteger(0, highLineName, OBJPROP_COLOR, currentHighColor);
            ObjectSetInteger(0, highLineName, OBJPROP_STYLE, currentStyle);
            ObjectSetInteger(0, highLineName, OBJPROP_WIDTH, currentWidth);
            ObjectSetInteger(0, highLineName, OBJPROP_RAY_RIGHT, false); // Sugár kikapcsolása jobbra
            ObjectSetInteger(0, highLineName, OBJPROP_BACK, true); // Háttérbe küldés

            //--- Low line
            string lowLineName = "PrevDayLow_" + IntegerToString(i);
            if (!ObjectCreate(0, lowLineName, OBJ_TREND, 0, dayStart, dayLow, dayEnd, dayLow))
            {
                 ObjectSetInteger(0, lowLineName, OBJPROP_TIME, 1, dayEnd);
                 ObjectSetDouble(0, lowLineName, OBJPROP_PRICE, 1, dayLow);
            }
            ObjectSetInteger(0, lowLineName, OBJPROP_COLOR, currentLowColor);
            ObjectSetInteger(0, lowLineName, OBJPROP_STYLE, currentStyle);
            ObjectSetInteger(0, lowLineName, OBJPROP_WIDTH, currentWidth);
            ObjectSetInteger(0, lowLineName, OBJPROP_RAY_RIGHT, false); // Sugár kikapcsolása jobbra
            ObjectSetInteger(0, lowLineName, OBJPROP_BACK, true); // Háttérbe küldés
        }

        prevDay = today; // Store the current day's start time for the next check
        ChartRedraw(); // Frissítsük a chartot a rajzolás után
    }

    return(0);
}
//+------------------------------------------------------------------+
