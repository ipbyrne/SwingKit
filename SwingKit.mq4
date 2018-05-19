#property strict
#property indicator_chart_window

sinput string Info_1=""; //--------- A) DATA OPTIONS  ------------------------------
input int lookBack = 10000; // Number of Bars to Analyze
input int MASpeed = 8; // Speed of MAs that make bands
input int MAShift = 1; // Shit of MAs that make bands
input bool rejectsAreTrends = true; // Count Reject Swing as Trends
sinput string Info_2=""; //--------- B) DRAWING OPTIONS  ---------------------------
input string ObjPrefix="SWINGKIT_";  //Prefix for object names
input bool drawMAs = true; // Draw MA Bands
input bool drawSwings = true; // Draw Swings
input bool drawPendingLevels = true; // Draw Potential Levels for Next Swing
input bool drawTriggerLine = true; // Draw Trigger Line
input bool drawSpreadRisk = true; // Draw Spread Risks
input bool drawSwingtoSwingData = true; // Draw Swing to Swing Data
input bool drawOppurtunityAnalysisData = true; // Draw Oppurtunity Analysis Data
sinput string Info_3=""; //--------- C) COLOR OPTIONS  -----------------------------
input color URcolor = Blue; // Color of UR legs
input color UTcolor = Green; // Color of UT Legs
input color DRcolor = Purple; // Color of DR Legs
input color DTcolor = Red; // Color of DT Legs
input color TextColor=clrRed; //Color of Text
sinput string Info_4=""; //--------- D) STATISTICAL PARAMETERS ---------------------
input bool writeFile = false;
sinput string InpDirectoryName= "Statistics"; //Folder name
sinput string InpFileName = "SWINGKIT.txt"; //File name
sinput datetime iPeriod_Start=D'2000.01.01 00:00:00'; //Start period for statistics

int startCheck = 0;

int swingSequence[10000]; // Sequence of Swings - Array of Swing Types
double swingStart[10000]; // Starting Level of Swing (Bottom)
int swingStartTime[10000]; // Starting Time of Swing
double swingEnd[10000]; // Ending Level of Swing (Top)
int swingEndTime[10000]; // Ending Time of Swing
int swingRetrace[10000]; // Swing Retrace %
int swingLength[10000]; // Lengths of Each Swing in Cadnles
int swingLengthClass[10000]; // 1 = D | 2 = C | 3 = B | 4 = A - Swings classified by Levels 1 shortest 4 longest
int swingLengthDist[10000]; // Lengths of Each Swing Distributions
int longestSwing = 0; // Length of Longest Swing
int meanSwingLength = 0; // Mean Length of Swings
// Time Counters/Checks/Levels
int firstTimeLevel = 0; // First Time Cut Off
int firstTimeLevelCheck = 0;
int secondTimeLevel = 0; // Second Time Cut Off
int secondTimeLevelCheck = 0;
int thirdTimeLevel = 0; // Third Time Cut Off
int thirdTimeLevelCheck = 0;

// Basic Swing Counters
int URtoDR = 0;
int URtoDT = 0;
int UTtoDR = 0;
int UTtoDT = 0;

int DRtoUR = 0;
int DRtoUT = 0;
int DTtoUR = 0;
int DTtoUT = 0;

// Chi Square Test Value
double URpValue = 0;
double UTpValue = 0;
double DRpValue = 0;
double DTpValue = 0;


string objprefix = ObjPrefix + Symbol();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   IndicatorBuffers(0);
//--- indicator lines
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){DeleteObjects(objprefix);}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   // ---------
   // Counters
   // ---------
   int i=lookBack;
   int swingSequnceCounter = 0;
   int firstLeg = 0; // 1 = Up Leg | -1 = Down Leg 
   int lastLeg = 0; //  1 = Up Leg | -1 = Down Leg 
   int currentLeg = 0;// -2 = DT | -1 = DR | 1 = UR | 2 = UT
   int lineWidth = 3;
   
   double currentPeak = 0; // Value of current peak, for the current leg being drawn.
   double currentPit = 0; // Value of current pit, for the current leg being drawn | Previous Peak = Current Pit
   double lastPeak = 0; // Value of breakout area for current leg | Previous Pit  = Last Peak
   
   int currentPeakTime = 0; // Time Current Peak was set
   int currentPitTime = 0; // Time Current Pit was set
   int lastPeakTime = 0; // Time Last Peak was set
   
   int trendCheck = 0;

   // ---------
   // Main Loop - Create Swings, Draw Swings, and Gather Basic Swing Data
   // ---------
   while(i>-1)
     {
     // Create Bands to Draw Levels
     double highBand = iMA(NULL,0,MASpeed,MAShift,MODE_LWMA,PRICE_HIGH,i); // 48 on 5 min = 8 on 30 min
     double lowBand = iMA(NULL,0,MASpeed,MAShift,MODE_LWMA,PRICE_LOW,i); // 48 on 5 min = 8 on 30 min
     
     
     // ---------
     // Checks/Requirements to Start - First Full legs Needs to be drawn before classification can begin.
     // ---------
     // If price starts inbetween bands, move till price is out to draw first leg.
     
     
     // Start Drawing First Leg
     if(Close[i] < lowBand && startCheck == 0) {firstLeg = -1; currentPeak = Low[i]; currentPeakTime = i; startCheck = 1;} if (Close[i] > highBand && startCheck == 0) {firstLeg = 1; currentPeak = High[i]; currentPeakTime = i; startCheck = 1;}

     
     // Look for New Low and Look For Cross
     if(firstLeg == 1) 
       {
       if(High[i] > currentPeak) {currentPeak = High[i]; currentPeakTime = i;} // New High Reached
       
       if(Close[i] < lowBand) {currentPit = currentPeak; currentPitTime = currentPeakTime; currentPeak = Low[i]; currentPeakTime = i; firstLeg = -2;} // Check for End of First Leg
       }
     
     else if(firstLeg == -1) 
       {
       if(Low[i] < currentPeak) {currentPeak = Low[i]; currentPeakTime = i;}// New High Reached
       
       if(Close[i] > highBand) {currentPit = currentPeak; currentPitTime = currentPeakTime; currentPeak = High[i]; currentPeakTime = i; firstLeg = 2;} // Check for End of First Leg
       }
       
     if(firstLeg == 2) 
       {
       if(High[i] > currentPeak) {currentPeak = High[i]; currentPeakTime = i;} // New High Reached
       
       if(Close[i] < lowBand) {lastPeak = currentPit; lastPeakTime = currentPitTime; currentPit = currentPeak; currentPitTime = currentPeakTime; currentPeak = Low[i]; currentPeakTime = i; firstLeg = -3;} // Check for End of First Leg
       }
     
     else if(firstLeg == -2) 
       {
       if(Low[i] < currentPeak) {currentPeak = Low[i]; currentPeakTime = i; }// New High Reached
       
       if(Close[i] > highBand) {lastPeak = currentPit; lastPeakTime = currentPitTime; currentPit = currentPeak; currentPitTime = currentPeakTime; currentPeak = High[i]; currentPeakTime = i; firstLeg = 3;} // Check for End of First Leg
       }
     
     // Draw First Leg
     if(drawSwings && (firstLeg == -3 || firstLeg == 3))
       { 
       // Draw First Line
       string trendLineName = objprefix + "First Swing";
       ObjectCreate(trendLineName, OBJ_TREND, 0, Time[lastPeakTime], lastPeak, Time[currentPitTime], currentPit);
       ObjectSet(trendLineName, OBJPROP_COLOR, Yellow);
       ObjectSet(trendLineName, OBJPROP_STYLE, STYLE_SOLID);
       ObjectSet(trendLineName, OBJPROP_WIDTH, lineWidth);
       ObjectSet(trendLineName, OBJPROP_RAY,0);
       
       // Create Next Line
       trendLineName = objprefix + IntegerToString(swingSequnceCounter);
       ObjectCreate(trendLineName, OBJ_TREND, 0, Time[currentPitTime], currentPit, Time[currentPeakTime], currentPeak);
       if(firstLeg == -3) 
         {
         if(currentPeak < lastPeak) {ObjectSet(trendLineName, OBJPROP_COLOR, DTcolor);}
         else {ObjectSet(trendLineName, OBJPROP_COLOR, DRcolor);}
         } 
       else 
         {
         if(currentPeak > lastPeak) {ObjectSet(trendLineName, OBJPROP_COLOR, UTcolor);}
         else {ObjectSet(trendLineName, OBJPROP_COLOR, URcolor);}
         }
       ObjectSet(trendLineName, OBJPROP_STYLE, STYLE_SOLID);
       ObjectSet(trendLineName, OBJPROP_WIDTH, lineWidth);
       ObjectSet(trendLineName, OBJPROP_RAY,0);   
       }  
       
       
     // Determine if Starting Leg is Up or Down So Classification can Begin
     if(firstLeg == -3) {lastLeg = 1; firstLeg = -4;} else if(firstLeg == 3) {lastLeg = -1; firstLeg = 4;}
     // ---------
     // End of Checks/Requirements to Start
     // ---------
     
     // ---------
     // Start Classifying Legs
     // ---------
     if(lastLeg == 1) // Previous Leg was Up, Current Leg is Moving Down
       {
       // Check to Update Leg Classification - Compare Low to Current Peak
       if(Low[i] < currentPeak) 
         {
         currentPeak = Low[i];
         currentPeakTime = i;
         }

       // If Updated Check for new Classification
       if(currentPeak < lastPeak && Close[i] < lastPeak) {trendCheck = -1;}
       if(rejectsAreTrends)
         {
         if(currentPeak < lastPeak) {currentLeg = -2;} else {currentLeg = -1;}
         }
       else
         {
         if(currentPeak < lastPeak && trendCheck == -1) {currentLeg = -2;} else {currentLeg = -1;}
         }
       
       // Update Swing
       if(drawSwings)
         {
         string trendLineName = objprefix + IntegerToString(swingSequnceCounter);
         ObjectSet(trendLineName, OBJPROP_TIME2, Time[currentPeakTime]);
         ObjectSet(trendLineName, OBJPROP_PRICE2, currentPeak);
         if(currentLeg == -2) {ObjectSet(trendLineName, OBJPROP_COLOR, DTcolor);}
         else {ObjectSet(trendLineName, OBJPROP_COLOR, DRcolor);}
         }
       
       // Check to Close Leg 
       if(Close[i] > highBand)
         {
         
         // If Closed, Push Leg Classification into Sequence Array 
         swingSequence[swingSequnceCounter] = currentLeg;
         swingStart[swingSequnceCounter] = currentPit;
         swingStartTime[swingSequnceCounter] = currentPitTime;
         swingEnd[swingSequnceCounter] = currentPeak;
         swingEndTime[swingSequnceCounter] = currentPeakTime;
         swingLength[swingSequnceCounter] = currentPitTime - currentPeakTime;
         swingLengthDist[currentPitTime - currentPeakTime]++;
         if(currentPitTime - currentPeakTime > longestSwing) {longestSwing = currentPitTime - currentPeakTime;}  
         swingSequnceCounter++;
         
         
         // Update Trackers to start drawing Next Leg
         lastPeak = currentPit; 
         currentPit = currentPeak; 
         currentPeak = High[i]; 
         lastPeakTime = currentPitTime;
         currentPitTime = currentPeakTime;
         currentPeakTime = i;
         lastLeg = -1;
         trendCheck = 0;
         
         // Create Next Swing
         if(drawSwings)
           {
           string trendLineName = objprefix + IntegerToString(swingSequnceCounter);
           ObjectCreate(trendLineName, OBJ_TREND, 0, Time[currentPitTime], currentPit, Time[currentPeakTime], currentPeak);
           if(currentPeak > lastPeak) {ObjectSet(trendLineName, OBJPROP_COLOR, UTcolor);}
           else {ObjectSet(trendLineName, OBJPROP_COLOR, URcolor);}
           ObjectSet(trendLineName, OBJPROP_STYLE, STYLE_SOLID);
           ObjectSet(trendLineName, OBJPROP_WIDTH, lineWidth);
           ObjectSet(trendLineName, OBJPROP_RAY,0);
           }
           
         if(drawTriggerLine)
           {
           string dotName = objprefix+"Dot"+IntegerToString(swingSequnceCounter);
           ObjectCreate(dotName, OBJ_TEXT, 0, Time[i], highBand); 
           ObjectSetText(dotName, CharToStr(159), 14, "Wingdings", UTcolor);
           }
         }
       }
     
     else if(lastLeg == -1) // Previous Leg was Down, Current Leg is Moving Up
       {
       // Check to Update Leg Classification - Compare High to Current Peak
       if(High[i] > currentPeak) 
         {
         currentPeak = High[i];
         currentPeakTime = i;
         }
       
       // If Updated Check for new Classification
       if(currentPeak > lastPeak && Close[i] > lastPeak) {trendCheck = 1;}
       if(rejectsAreTrends)
         {
         if(currentPeak > lastPeak) {currentLeg = 2;} else {currentLeg = 1;} 
         }
       else
         {
         if(currentPeak > lastPeak && trendCheck == 1) {currentLeg = 2;} else {currentLeg = 1;} 
         }
       
       
       // Update Swing
       if(drawSwings)
         {
         string trendLineName = objprefix + IntegerToString(swingSequnceCounter);
         ObjectSet(trendLineName, OBJPROP_TIME2, Time[currentPeakTime]);
         ObjectSet(trendLineName, OBJPROP_PRICE2, currentPeak);
         if(currentLeg == 2) {ObjectSet(trendLineName, OBJPROP_COLOR, UTcolor);}
         else {ObjectSet(trendLineName, OBJPROP_COLOR, URcolor);}
         }
         
       // Check to Close Leg
       if(Close[i] < lowBand)
         {

         // If Leg will be Closed, Push Leg Classification into Sequence Array before closing
         swingSequence[swingSequnceCounter] = currentLeg;
         swingStart[swingSequnceCounter] = currentPit;
         swingStartTime[swingSequnceCounter] = currentPitTime;
         swingEnd[swingSequnceCounter] = currentPeak;
         swingEndTime[swingSequnceCounter] = currentPeakTime;
         swingLength[swingSequnceCounter] = currentPitTime - currentPeakTime;
         swingLengthDist[currentPitTime - currentPeakTime]++;
         if(currentPitTime - currentPeakTime > longestSwing) {longestSwing = currentPitTime - currentPeakTime;} 
         swingSequnceCounter++;
         
         // Update Trackers to Start Drawing Next Leg
         lastPeak = currentPit; 
         currentPit = currentPeak; 
         currentPeak = Low[i]; 
         lastPeakTime = currentPitTime;
         currentPitTime = currentPeakTime;
         currentPeakTime = i;
         lastLeg = 1;
         trendCheck = 0;
         
         // Creat Next Swing
         if(drawSwings)
           {
           string trendLineName = objprefix + IntegerToString(swingSequnceCounter);
           ObjectCreate(trendLineName, OBJ_TREND, 0, Time[currentPitTime], currentPit, Time[currentPeakTime], currentPeak);
           if(currentPeak < lastPeak) {ObjectSet(trendLineName, OBJPROP_COLOR, DTcolor);}
           else {ObjectSet(trendLineName, OBJPROP_COLOR, DRcolor);}
           ObjectSet(trendLineName, OBJPROP_STYLE, STYLE_SOLID);
           ObjectSet(trendLineName, OBJPROP_WIDTH, lineWidth);
           ObjectSet(trendLineName, OBJPROP_RAY,0);
           }
           
         if(drawTriggerLine)
           {
           string dotName = objprefix+"Dot"+IntegerToString(swingSequnceCounter);
           ObjectCreate(dotName, OBJ_TEXT, 0, Time[i], lowBand); 
           ObjectSetText(dotName, CharToStr(159), 14, "Wingdings", DTcolor);
           }  
         }
       }   

     i--;
     }
   
   
   // ---------
   // Gather & Analyze Data 
   // ---------
   i = swingSequnceCounter++;
   int u = 0;
   while(i>1)
      {
      // Gather Swing to Swing Data
      if(swingSequence[u] == 1 && swingSequence[u+1] == -1) {URtoDR++;}
      if(swingSequence[u] == 1 && swingSequence[u+1] == -2) {URtoDT++;}
      if(swingSequence[u] == 2 && swingSequence[u+1] == -1) {UTtoDR++;}
      if(swingSequence[u] == 2 && swingSequence[u+1] == -2) {UTtoDT++;}
      
      if(swingSequence[u] == -1 && swingSequence[u+1] == 1) {DRtoUR++;}
      if(swingSequence[u] == -1 && swingSequence[u+1] == 2) {DRtoUT++;}
      if(swingSequence[u] == -2 && swingSequence[u+1] == 1) {DTtoUR++;}
      if(swingSequence[u] == -2 && swingSequence[u+1] == 2) {DTtoUT++;}

      i--;
      u++;      
      }
  
   
   // Draw Swing End Dot - Top MA/Bottom MA
   if(lastLeg == 1 && drawTriggerLine) // Current Swing is Down
      {
      string dotName = objprefix+"Dot";
      double dot = iMA(NULL,0,MASpeed,0,MODE_LWMA,PRICE_HIGH,0);
      ObjectCreate(dotName, OBJ_TEXT, 0, Time[0], dot); 
      ObjectSetText(dotName, CharToStr(159), 14, "Wingdings", Yellow);
      }
   
   if(lastLeg == -1 && drawTriggerLine) // Current Swing is Up
      {
      string dotName = objprefix+"Dot";
      double dot = iMA(NULL,0,MASpeed,0,MODE_LWMA,PRICE_LOW,0);
      ObjectCreate(dotName, OBJ_TEXT, 0, Time[0], dot); 
      ObjectSetText(dotName, CharToStr(159), 14, "Wingdings", Yellow);
      }   
   
   SwingLengthAnalysis();
   ChiSquaredTest();
   DrawStats();
   if(writeFile == true) {WriteFile();}
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|HELPER FUNCTIONS                                                  |
//+------------------------------------------------------------------+ 
//+----------------
//| Swing Length Analysis                                           
//+----------------
void SwingLengthAnalysis()
   {
   // Find Mean Swing Length
   double sum = 0;
   int x = 0;
   while(x<=longestSwing)
      {
      sum+= swingLengthDist[x];
      x++;
      }
   
   x = 0;
   double runningTotal = 0.0;
   while(x<=longestSwing)
      {
      double probability;
      probability = swingLengthDist[x]/sum;
      runningTotal += probability;
      if(runningTotal >= 0.50 && meanSwingLength == 0)
         {
         meanSwingLength = x;
         }
      x++;
      }
   }
//+----------------
//| Chi-Squared Tests                                            
//+----------------
void ChiSquaredTest()
  {
  // Link to Chi-Square Table: http://ib.bioninja.com.au/_Media/chi-table_med.jpeg
  
  //----------
  // UR p-value
  //----------
  double observedOne = URtoDR;
  double observedTwo = URtoDT;
  
  double expectedVal = (URtoDR + URtoDT)/2;
  
  double sampDistOne = (((observedOne - expectedVal)*((observedOne - expectedVal)))/expectedVal);
  double sampDistTwo = (((observedTwo - expectedVal)*((observedTwo - expectedVal)))/expectedVal);
  
  double X2 = sampDistOne + sampDistTwo;
  
  if(X2 > 3.84)
   {
   URpValue = 0.05;
   }
  
  if(X2 > 6.63)
   {
   URpValue = 0.01;
   }
  
  //----------
  // UT p-value
  //----------
  observedOne = UTtoDR;
  observedTwo = UTtoDT;
  
  expectedVal = (UTtoDR + UTtoDT)/2;
  
  sampDistOne = (((observedOne - expectedVal)*((observedOne - expectedVal)))/expectedVal);
  sampDistTwo = (((observedTwo - expectedVal)*((observedTwo - expectedVal)))/expectedVal);
  
  X2 = sampDistOne + sampDistTwo;
  
  if(X2 > 3.84)
   {
   UTpValue = 0.05;
   }
  
  if(X2 > 6.63)
   {
   UTpValue = 0.01;
   }
   
  //----------
  // DR p-value
  //----------
  observedOne = DRtoUR;
  observedTwo = DRtoUT;
  
  expectedVal = (DRtoUR + DRtoUT)/2;
  
  sampDistOne = (((observedOne - expectedVal)*((observedOne - expectedVal)))/expectedVal);
  sampDistTwo = (((observedTwo - expectedVal)*((observedTwo - expectedVal)))/expectedVal);
  
  X2 = sampDistOne + sampDistTwo;
  
  if(X2 > 3.84)
   {
   DRpValue = 0.05;
   }
  
  if(X2 > 6.63)
   {
   DRpValue = 0.01;
   }
  
  //----------
  // DT p-value
  //----------
  observedOne = DTtoUR;
  observedTwo = DTtoUT;
  
  expectedVal = (DTtoUR + DTtoUT)/2;
  
  sampDistOne = (((observedOne - expectedVal)*((observedOne - expectedVal)))/expectedVal);
  sampDistTwo = (((observedTwo - expectedVal)*((observedTwo - expectedVal)))/expectedVal);
  
  X2 = sampDistOne + sampDistTwo;
  
  if(X2 > 3.84)
   {
   DTpValue = 0.05;
   }
  
  if(X2 > 6.63)
   {
   DTpValue = 0.01;
   }
   
  }
//+----------------
//| Draw Statistics                                            
//+----------------
void DrawStats()
  {
   int i = 20;
   int j = 2000;
   
   if(drawSpreadRisk)
   {
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"---------------------------------------",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
    
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Spread Risk",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"---------------------------------------",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Max Spread Risk (Min 20 Pips SL to TP): " + DoubleToStr((MarketInfo(Symbol(),MODE_SPREAD)/10)/20*100,2) + "%",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Max Spread Risk (Min 30 Pips SL to TP): " + DoubleToStr((MarketInfo(Symbol(),MODE_SPREAD)/10)/30*100,2) + "%",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Max Spread Risk (Min 40 Pips SL to TP): " + DoubleToStr((MarketInfo(Symbol(),MODE_SPREAD)/10)/40*100,2) + "%",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Max Spread Risk (Min 50 Pips SL to TP): " + DoubleToStr((MarketInfo(Symbol(),MODE_SPREAD)/10)/50*100,2) + "%",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Max Spread Risk (Min 75 Pips SL to TP): " + DoubleToStr((MarketInfo(Symbol(),MODE_SPREAD)/10)/75*100,2) + "%",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=10;
   j++;
   
   ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
   ObjectSetText(objprefix+IntegerToString(j),"Max Spread Risk (Min 100 Pips SL to TP): " + DoubleToStr((MarketInfo(Symbol(),MODE_SPREAD)/10)/100*100,2) + "%",7,"Verdana",TextColor);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
   ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
   i+=20;
   j++;  
   }
   
   
   double totalUpURSwings = URtoDR + URtoDT ;
   double totalUpUTSwings = UTtoDR + UTtoDT;
   
   double totalDownDRSwings = DRtoUR + DRtoUT;
   double totalDownDTSwings = DTtoUR + DTtoUT;
   if(drawSwingtoSwingData)
      {
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"---------------------------------------",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"Basic Swing to Swing Probabilties",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"---------------------------------------",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"UR to DR ("+ IntegerToString(URtoDR) + "): " + DoubleToStr((double(URtoDR)/totalUpURSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"UR to DT ("+ IntegerToString(URtoDT) + "): " + DoubleToStr((double(URtoDT)/totalUpURSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"UR Chi-Square P Value: " + DoubleToStr(URpValue*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=20;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"UT to DR ("+ IntegerToString(UTtoDR) + "): " + DoubleToStr((double(UTtoDR)/totalUpUTSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"UT to DT ("+ IntegerToString(UTtoDT) + "): " + DoubleToStr((double(UTtoDT)/totalUpUTSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"UT Chi-Square P Value: " + DoubleToStr(UTpValue*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=20;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"DR to UR ("+ IntegerToString(DRtoUR) + "): " + DoubleToStr((double(DRtoUR)/totalDownDRSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"DR to UT ("+ IntegerToString(DRtoUT) + "): " + DoubleToStr((double(DRtoUT)/totalDownDRSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"DR Chi-Square P Value: " + DoubleToStr(DRpValue*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=20;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"DT to UR ("+ IntegerToString(DTtoUR) + "): " + DoubleToStr((double(DTtoUR)/totalDownDTSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"DT to UT ("+ IntegerToString(DTtoUT) + "): " + DoubleToStr((double(DTtoUT)/totalDownDTSwings)*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"DT Chi-Square P Value: " + DoubleToStr(DTpValue*100,2) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=20;
      j++;
      }
  
  if(drawOppurtunityAnalysisData)
      {
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"---------------------------------------",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"Oppurtunity Analysis",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"---------------------------------------",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"Mean Swing Length: " + IntegerToString(meanSwingLength),7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"Oppurtunities Per Week: " + DoubleToStr((120/(double(meanSwingLength*4))),0),7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=10;
      j++;
      
      
      double risk = 55;
      double reward = 45;
      double winrate = (((double(URtoDT)/totalUpURSwings)) + ((double(DRtoUT)/totalDownDRSwings)))/2;
      double expectedValue = (reward*winrate) - (risk*(1-winrate));
      double evAsPofRisk = (expectedValue/risk);
      double spreadRisk = ((MarketInfo(Symbol(),MODE_SPREAD)/10)/75)*100;
      
      ObjectCreate(objprefix+IntegerToString(j),OBJ_LABEL,0,0,0);
      ObjectSetText(objprefix+IntegerToString(j),"R to T Min EV (No Spread Risk): " + DoubleToStr((evAsPofRisk*100),0) + "%",7,"Verdana",TextColor);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_CORNER,1);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_XDISTANCE,10);
      ObjectSet(objprefix+IntegerToString(j),OBJPROP_YDISTANCE,i);
      i+=20;
      j++;
      }
  }
//+--------------
//|DELETE OBJECTS                                                 
//+--------------  
void DeleteObjects(string prefix)
  {
   string strObj;
   int ObjTotal=ObjectsTotal();
   for(int i=ObjTotal-1;i>=0;i--)
     {
      strObj=ObjectName(i);
      if(StringFind(strObj,prefix,0)>-1)
        {
         ObjectDelete(strObj);
        }
     }
  }
//+--------------------------
//|WRITE STATISTICS INTO FILE                                        
//+--------------------------
bool WriteFile()
  {
   int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for writing",InpFileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));

      Print("Start of frequency distribution: "+TimeToString(iPeriod_Start,TIME_DATE|TIME_MINUTES));

      string strData="";
      
      strData = strData + "SwingKit" + "\n";
      int x = 0;
      while(x<=longestSwing)
         {
         strData = strData + IntegerToString(swingLengthDist[x]) + "\n";
         x++;
         }

      FileWriteString(file_handle,strData);

      //--- close the file
      FileClose(file_handle);
      PrintFormat("Data is written, %s file is closed",InpFileName);
      
      return(true);
     }
   else
     {
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
      return(false);
     }
  }
  
