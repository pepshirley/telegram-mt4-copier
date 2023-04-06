//+------------------------------------------------------------------+
//|                                        TelegramToMT4.mq4 |
//|                                           Copyright 2022,Perpetual Vincent |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021,Perpetual Vincent"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

string Host="127.0.0.1";


#define TIMER_FREQUENCY_MS    1000


// Watch for need to create timer;
bool glbCreatedTimer = false;


string file_url = "https://nfs.faireconomy.media/ff_calendar_thisweek.csv";

enum RISK_SOURCE
  {
   balance,
   free_margin
  };

enum LOT_MODE
  {
   fixed,//Fixed lots
   risk//% risk
  };

enum SL_MODE
  {
   custom,//Custom
   signal//Signal
  };

enum TP_MODE
  {
   custom1,//Custom
   signal1//Signal
  };

enum MULTIPLE_TP
  {
   single,//Single order
   multiple,//Multiple orders
  };

enum SHUTDOWN_DAY
  {
   Monday,
   Tuesday,
   Wednesday,
   Thursday,
   Friday,
   Saturday,
   Sunday
  };

enum RESTART_DAY
  {
   Monday1,//Monday
   Tuesday1,//Tuesday
   Wednesday1,//Wednesday
   Thursday1,//Thursday
   Friday1,//Friday
   Saturday1,//Saturday
   Sunday1,//Sunday
  };

string   token = "";//Enter API Token


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string   InpIncludedSymbols = "";//Included symbols (if multiple, separate by commas)

string     InpSep42          = "";//============CHANNEL SETTINGS============
string     InpChannel          = "Premium Golden Circle";//Takes trades from this channel only
input string     InpSep40          = "";//============COMMAND SETTINGS============
input string     InpOTCmds         = "buy,sell,buying,selling,buystop,sellstop,buylimit,selllimit";//Ordertype commands (not case sensitive)
input string     InpCloseCmds      = "close,delete,collect";//Close commands
input string     InpBECmds         = "breakeven,sl to entry,set be,be highest,be lowest";//Breakeven commands
input string     InpSLCmds         = "move sl,update sl,change sl";//SL update commands
input string     InpTPCmds         = "move tp,update tp,change tp";//TP update commands
string     InpPCCmds         = "secure half,close half,secure your half";//Partial close commands

input string     InpSep30            = "";//============SYMBOL OPTIONS============
string     InpExcludedSymbols = "";//Excluded symbols (if multiple, separate by commas)
bool     InpTradeSelect = false;//Trade select symbols only?
string   InpSelectInstruments = "EURUSD,GBPUSD,XAUUSD";//List of select symbols
string   InpLotsPerSymbol    = "EURUSD=0.01,GBPUSD=0.01,XAUUSD=0.01";//Lot size for each selected symbol
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpBrokerSuffix    = "";//Broker symbols suffix (if any)
input string   InpBrokerName      = "GOLD=XAUUSD,NAS100=USTEC";//Add custom symbol (name on signal=name on broker)

input string     InpSep3           = "";//============TRADE & RISK SETTINGS============
string   InpAccCuency = "$";//Account currency
LOT_MODE InpLotMode = risk;//LOT MODE
double   InpLotValue         = 0.01;//Lot value
double   InpRiskPerc   = 1;//Risk Percent
double   InpDefaultTP     = 150;//Default TP
double   InpDefaultSL     = 100;//Default SL
input double   InpBELossPips = 3;//Loss breakeven pips
input bool     InpUseSpreadFilter = false;//Use spread filter?
input double   InpMaxSpread  = 5;//Maximum spread allowed
input double   InpMaxDD      = 5;//Maximum drawdown (%)
input bool     InpCloseOnDD  = false;//Close all trades on max drawdown
bool     InpDynamicSL     = true;//Move SL after each TP is hit
double   InpPipBE         = 30;//Move SL after X pips in profit

string     InpSep911     = "";//============NEWS FILTER============
bool     InpUseNewsFilter = false;//Use News filter?
bool     InpHighImpact  = true;//Filter high impact news
bool     InpMediumImpact  = true;//Filter medium impact news
bool     InpLowImpact  = true;//Filter low impact news
bool     InpShowNews    = false;//Display news on chart
string      InpTimeZoneOffset = "-01:00";//Broker Server Timezone (GMT +/- HH:MM)
int      InpPreNewsShutdownTime = 15;//Stop trading X mins before news
int      InpPostNewsResumeTime  = 15;//Resume trading X mins after news


string     InpSep63   = "";//=============NEWS FILTER=================
bool     InpApplyNews   = false;//Apply news filter


string     InpSep1           = "";//============SHUTDOWN SETTINGS============
bool     InpActivateShutdown = false;//Activate shutdown
SHUTDOWN_DAY InpShutdownDay = Thursday;//EA Close day
string   InpShutdownTime    = "23:59";//EA Close time (Your computer's local time)

RESTART_DAY InpRestartDay  = Monday1;//EA Restart day
string   InpRestartTime    = "00:00";//EA Restart time (Your computer's local time)

int      InpMaxOrderCnt   = 6;//Max Order Count

bool     InpUseShutdown     = true;//Activate Shutdown?
bool     InpUseLimit      = false;//Execute by limit?
int      InpLimitExpiry   = 4;//Limit expiry (hours)
int      InpMaxBlankTradeCnt = 3;//Number of trades (when no SL/TP)

//input double   InpMaxEntryPips  = 1;//Maximum entry slippage (multiples of minimum stop)
RISK_SOURCE InpRiskSource    = balance;//Risk calculation source


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpIndicesList     = "";//Indices list (for lot size classification by instrument type)
string   InpCommoditiesList = "";//Commodities list (for lot size classification by instrument type)
string   InpStocksList      = "";//Crypto list (for lot size classification by instrument type)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpLotsPerTPCurrencies   = "";//Lot size per TP (currency pairs)
string   InpLotsPerTPIndices   = "";//Lot size per TP (indices)
string   InpLotsPerTPCommodities   = "";//Lot size per TP (commodities)
string   InpLotsPerTPStocks   = "";//Lot size per TP (crypto)
bool     InpUseSpread     = false;//Add spread to SL?
bool     InpUseTPSpread   = false;//Add spread to TP?

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpDefTPOthers   = "US30=10000,NAS100=10000,BTCUSD=1000000";//Default TP in points (Other instruments)
string   InpDefSLOthers   = "US30=5000,NAS100=5000,BTCUSD=500000";//Default SL in points (Other instruments)
bool     InpRejectNoSL      = true;//Reject orders without SL
SL_MODE  InpSLMode = signal;//SL MODE
TP_MODE  InpTPMode = signal1;//TP MODE
MULTIPLE_TP InpMultipleTP = multiple;//Multiple TP Handle
string   InpTradesPerTP = "1,1,1,1,1";//Number of trades per TP
bool     InpDivideLot     = false;//Divide lot by TP count




bool   InpUseTrail      = false;//Use trailing stop?
double InpTrailStart    = 30;//Start trail after X pips in profit
double InpTrailPoints   = 10;//Trail price by X pips
int      InpMaxOrderCntPerSymbol   = 5;//Max Order Count Per Symbol
double   InpCloseHalfPerc = 50;//Close Half %
bool     InpShowSender    = true;//Show sender ID on trade ?

string     InpSep4           = "";//============CHANNEL SETTINGS============
bool     InpChannelValid  = true;//Channel Validation
string   InpSupportedChannels = "";//Signal channels (if multiple, separate by commas)






double   InpGoldLot    = 1;//Gold Lot Size
double   InpUS30Lot    = 0.02;//US30 Lot Size
double   InpNAS100Lot  = 0.02;//NAS100 Lot Size



double   InpUS30SL     = 100000;//US30 alternate SL/TP points
double   InpNAS100SL   = 100000;//NAS100 alternate SL/TP points
double   InpGoldSL     = 1000;//Gold alternate SL/TP points





string   InpSigGoldName   = "XAUUSD";//Signal Gold name
string   InpSigUS30Name   = "US30";//Signal US30 name
string   InpSigNasName    = "NASDAQ";//Signal NAS100 name

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpGoldName   = "XAUUSD";//Your broker's Gold name (If XAUUSD, leave empty)
string   InpUS30Name   = "US30";//Your broker's US30 name (If US30, leave empty)
string   InpNasName    = "NAS100";//Your broker's NAS100 name (If NAS100, leave empty)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpBTCName    = "BTCUSD";//Your broker's BTC name (If BTCUSD, leave empty)
double   InpBTCLot     = 0.25;//BTC Lot Size
double   InpUSDTRYLot  = 0.3;//USDTRY Lot Size


double   InpTP1LotSize    = 0.01;//Lot Size
int      InpUpdateInterval = 10;//How often do you want to check for new messages? (seconds)
int      InpConnRetry      = 10;//Maximum of connection retries

string   Hostname = "localhost";    // Server hostname or IP address
ushort   ServerPort = 9999;        // Server port

double   InpTP2LotSize   = 0.01;//TP2 Lot Size
double   InpTP3LotSize   = 0.01;//TP3 Lot Size
int      InpMaxSlippage = 10;//Maximum Slippage
double   InpBEPoints    = 0;//Breakeven points
double   InpPCPerc      = 50;//% for partial close

string   InpSep7       = "";//=========================================
string   InpTitle4      = "";//SYMBOL INPUTS
string   InpSep8       = "";//=========================================
string   InpEthName   = " ";//Your broker's Ethereum name (If ETHUSD, leave empty)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   InpXRPName   = " ";//Your broker's XRP name (If XRPUSD, leave empty)
string   InpSPX500Name   = " ";//Your broker's SPX500 name (If SPX500, leave empty)
string   InpLTCName   = " ";//Your broker's LTC name (If LTCUSD, leave empty)
string   InpSOLName   = " ";//Your broker's SOL name (If SOLUSD, leave empty)

string   InpSep5       = "";//=========================================
string   InpTitle5       = "";//EA INPUTS
string   InpSep66      = "";//=========================================
int      InpMagicNumber = 300922;//EA Magic Number
string   InpTradeComment = "Ilpaulix Telegram  to MT4 EA";//Trade Comment

string        chat_id   = "1380098782";//"1380098782"; //"-1001565908789";
string        message;
string        cookie       = NULL,headers;
char          post[];
char          results[];
int           resu;
string        baseurl      = "https://api.telegram.org";

string PriceChars[] = {"0","1","2","3","4","5","6","7","8","9","."};
string Letters[]    = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"};
string LETTERS[]    = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
string TradeTypes[];
string OtherSymbols[] = {"NAS100","US30","ETHUSD","LTCUSD","XRPUSD","SPX500","SOLUSD","BTCUSD","BITCOIN","XRP","BTC","BITCOIN","NAS","GOLD","ETH","LTC","SOL"};
double TPs[];
double SL;
int Ordertype;
double Entry;
string Symbol_Name;
string QSymbol;
string LastMsgID;
string TicketTPs[];
string TicketTP1;
string TicketTP2;
string TicketTP3;
string TicketTP4;
string TicketTP5;
string TicketTP6;
string TicketTP7;
string TicketTP8;
string TicketTP9;
string TicketTP10;

string sEntry;
string QuotedMsg;

datetime LastMsgTime;

string Message;
string Sender;

bool EAIsOn;

datetime OpenDay;
datetime CloseDay;
int LastNewsUpdateDay;

int TimezoneOffsetSecs;
string BrokerNames[];

string ExcludedSymbols[];

string LotsPerSymbol[];

string SelectPairs[];

string CloseCmds[];
string BECmds[];
string SLCmds[];
string TPCmds[];
string PCCmds[];

string BASE_URL;

string Currencies[] = {"AUD","CAD","CHF","EUR","GBP","JPY","NZD","USD","XAG"};

string USOilNames[] = {"WTIUSD","USOIL","CRUDEOIL","CL","XTIUSD","USOIL.cash"};
string UKOilNames[] = {"BRENT","UKOIL","XBRUSD"};
string US30Names[]  = {"US30","DJ","DOW JONES","DOWJONES","WALL STREET","US30.cash"};
string GoldNames[]  = {"GOLD","XAUUSD","XAUUSDm"};
string SilverNames[] = {"SILVER","XAGUSD"};
string NASNames[]   = {"NAS100","NASDAQ","NASDAQ 100","US100","USTEC","US TEC","NAS 100","NAS","US100.cash"};
string SPNames[]   = {"SPX500","SP500"};

string IDs[];

string LASTMSG;

datetime LastExpiryCheckTime;

int LastDeinitReason;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string today;
string logfile;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   today = TimeToString(TimeCurrent(),TIME_DATE);
   logfile = "COPIER_LOG\\"+today+"_Log.txt";

   ObjectCreate(0,"EAId",OBJ_LABEL,0,0,0);
   ObjectSetString(0,"EAId",OBJPROP_TEXT,".");



   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {

      MessageBox("Please ensure autotrading is allowed and relaunch.");
      return INIT_FAILED;
     }

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {

      MessageBox("Please ensure you are connected to the internet and relaunch.");
      return INIT_FAILED;
     }

   IsNewMessage();

   /*if(!IsDllsAllowed())
     {
      MessageBox("Please allow DLL imports for this EA. Go to Tools -> Options -> Expert Advisors");
      return INIT_FAILED;
     }*/




   string tzparts[];

   string tzoffset = InpTimeZoneOffset;

   StringReplace(tzoffset,"+","");

   StringSplit(tzoffset,StringGetCharacter(":",0),tzparts);

   if(ArraySize(tzparts)==0)
     {
      Alert("Wrong timezone offset.");
      return INIT_FAILED;
     }

   if(StringLen(InpOTCmds) > 0)
      StringSplit(InpOTCmds,StringGetCharacter(",",0),TradeTypes);

   if(StringLen(InpCloseCmds) > 0)
      StringSplit(InpCloseCmds,StringGetCharacter(",",0),CloseCmds);

   if(StringLen(InpBECmds) > 0)
      StringSplit(InpBECmds,StringGetCharacter(",",0),BECmds);

   if(StringLen(InpSLCmds) > 0)
      StringSplit(InpSLCmds,StringGetCharacter(",",0),SLCmds);

   if(StringLen(InpTPCmds) > 0)
      StringSplit(InpTPCmds,StringGetCharacter(",",0),TPCmds);

   if(StringLen(InpPCCmds) > 0)
      StringSplit(InpPCCmds,StringGetCharacter(",",0),PCCmds);

   if(StringLen(InpSelectInstruments) > 0)
      StringSplit(InpSelectInstruments,StringGetCharacter(",",0),SelectPairs);

   if(StringLen(InpLotsPerSymbol) > 0)
     {
      StringSplit(InpLotsPerSymbol,StringGetCharacter(",",0),LotsPerSymbol);
     }


   if(StringLen(InpBrokerName) > 0)
     {
      StringSplit(InpBrokerName,StringGetCharacter(",",0),BrokerNames);
     }

   if(StringLen(InpExcludedSymbols) > 0)
     {
      StringSplit(InpExcludedSymbols,StringGetCharacter(",",0),ExcludedSymbols);
     }


   TimezoneOffsetSecs = ((int)tzparts[0])*60*60 + ((int)tzparts[1])*60;

// Alert("Server timezone is ",TimezoneOffsetSecs," seconds ahead/behind GMT.");

   LastNewsUpdateDay = -1;

// OpenDay  = TimeCurrent() > GetNearestOpenDay() ? GetNearestOpenDay() + 7*86400 : GetNearestOpenDay();
   OpenDay  = MathAbs(TimeCurrent() - GetNearestOpenDay()) <  MathAbs(TimeCurrent() - GetNearestOpenDay() + 7*86400) ? GetNearestOpenDay() : GetNearestOpenDay() + 7*86400;
   CloseDay = MathAbs(TimeCurrent() - GetNearestCloseDay()) <  MathAbs(TimeCurrent() - GetNearestCloseDay() + 7*86400) ? GetNearestCloseDay() : GetNearestCloseDay() + 7*86400;

   if(TimeCurrent() > CloseDay)
     {
      CloseDay = CloseDay + (7*86400);
      OpenDay = OpenDay + (7*86400);
     }

   if(CloseDay > OpenDay)
     {
      OpenDay = OpenDay + (7*86400);
     }



   /* if(!FileIsExist("ea_status.txt"))
      {
        EAIsOn = true;
      }


    else
      {
       int handle = FileOpen("ea_status.txt",FILE_READ);

       if(handle==INVALID_HANDLE)
         {
          Alert("Failed to get EA status. Please restart.");
          return INIT_FAILED;
         }

       EAIsOn = FileReadBool(handle);

       FileClose(handle);
      }*/

   EAIsOn = true;

   CheckEAStatus();

// Alert(GetToday());
// Alert(InpShutdownDay);

   LastDeinitReason = -1;



   string endline = "\n";

   ushort sep = StringGetCharacter(endline,0);



   Comment("");



// LastMsgID = 0;

   LastMsgTime = 0;

   IsNewMessage();

   if(FileIsExist("ticketids.txt"))
     {
      int handle = FileOpen("ticketids.txt",FILE_READ);

      if(handle==INVALID_HANDLE)
         Log("Failed to read ticket id file.");

      else
        {

         ArrayFree(IDs);

         while(!FileIsEnding(handle))
           {
            AddToArray(IDs,FileReadString(handle));

           }

         FileClose(handle);

         FileDelete("ticketids.txt");
        }
     }




   EventSetTimer(1);
   OnTimer();
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {



   if(OrdersTotal()==0)
      ArrayFree(IDs);

   int handle = FileOpen("ticketids.txt",FILE_WRITE);

   if(handle==INVALID_HANDLE)
      Log("Failed to write ticket id file.");

   else
     {

      for(int i=0; i<ArraySize(IDs); i++)
        {
         FileWriteString(handle,IDs[i]+"\n");
        }

      FileClose(handle);
     }

   for(int i=ObjectsTotal(0,-1,-1)-1; i>=0; i--)
     {
      string name = ObjectName(0,i);

      if(StringFind(name,"NEWS") >= 0)
         ObjectDelete(0,name);
     }

   ObjectDelete(0,"EAId");
   ObjectDelete(0,"website");
   ObjectDelete(0,"telegram");


   EventKillTimer();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckEAStatus()
  {

   int todayNum      = GetToday();
   datetime shutdowntime = StringToTime(InpShutdownTime);
   datetime restarttime = StringToTime(InpRestartTime);

   if(todayNum==(InpShutdownDay+1) && TimeCurrent() >= shutdowntime)
     {
      EAIsOn = false;
     }

   if(todayNum==(InpRestartDay+1) && TimeCurrent() >= restarttime)
     {
      EAIsOn = true;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Comment("You are disconnected from the internet. Please ensure you are connected for EA to resume!.");
      return;
     }

   today = TimeToString(TimeCurrent(),TIME_DATE);
   logfile = "COPIER_LOG\\"+today+"_Log.txt";


//StringToUpper(LASTMSG);
//Comment(LASTMSG);

   TradeOnSignal();


   if(InpDynamicSL)
      ModifySL();

   if(InpCloseOnDD)
      CloseOnDD();


  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeOnSignal()
  {


// if(LastMsgID==0)
// IsNewMessage();


   /* for(int i=0; i<ArraySize(TPs); i++)
      {
       Log("TP"+IntegerToString(i+1)+" is "+DoubleToString(TPs[i]));
      }

    Log("Symbol is "+Symbol_Name);
    Log("SL is "+DoubleToString(SL));
    Log("Ordertype is "+IntegerToString(Ordertype));
    Log("Entry is "+DoubleToString(Entry));*/

   int todayNum = GetToday();


   if(InpActivateShutdown)
     {

      if(TimeCurrent() >= CloseDay && TimeCurrent() <= OpenDay)
        {
         Comment("EA is currently shut down. Will resume ",OpenDay);
         return;
        }

      if(TimeCurrent() > OpenDay)
        {
         CloseDay = CloseDay + (7*86400);
         OpenDay  = OpenDay + (7*86400);
         Comment("EA is currently running. Will shutdown on ",CloseDay);
        }
     }

   if(InpUseNewsFilter)
     {
      if(todayNum > LastNewsUpdateDay || todayNum==1)
        {
         Download();

         if(InpShowNews)
            DisplayNews();

         LastNewsUpdateDay = todayNum;
        }
     }


   if(!IsNewMessage())
      return;


//Get Message ID or replied message ID
   char m2s[];
   StringToCharArray(Message,m2s);

   int idstart = -1;

   for(int i=ArraySize(m2s); i>=0; i--)
     {
      if(StringSubstr(Message,i,1)=="{")
        {
         idstart = i;
         break;
        }
     }

   if(idstart==-1)
      Log("Failed to get ID from message.");

   else
     {
      LastMsgID = StringSubstr(Message,idstart);
      StringReplace(LastMsgID,"{","");
      StringReplace(LastMsgID,"}","");
      Log("Message ID is "+LastMsgID);
     }



   if(StringLen(Message)>0)
     {


      // Alert(Message);

      string lastMsg = "";
      QuotedMsg = "";

      if(StringFind(Message,"|") >= 0)
        {
         string parts[];

         StringSplit(Message,StringGetCharacter("|",0),parts);

         if(ArraySize(parts)==2)
           {
            lastMsg = parts[1];
            QuotedMsg = parts[0];
           }

        }

      else
        {
         lastMsg = Message;
        }

      if(StringFind(lastMsg,"{") >= 0 && StringFind(lastMsg,"}") >= 0)
         lastMsg = StringSubstr(lastMsg,0,StringFind(lastMsg,"{"));

      LASTMSG = lastMsg;

      StringToUpper(LASTMSG);

      //If Layer now is in message, signal is quoted message
      if(StringFind(LASTMSG,"LAYER NOW") >= 0)
        {
         Log("Layer message received.");
         lastMsg = QuotedMsg;
         QuotedMsg = "";
        }

      string sender = GetSender();

      WriteSignals(lastMsg);


      bool IsBE = false;
      bool IsPC = false;
      bool IsSLMod = false;
      bool IsTPMod = false;
      bool IsClose = false;


      string lastMsgCopy = lastMsg;

      bool IsTargetedClose = StringFind(lastMsgCopy,"CLOSE HIGHEST") >= 0 || StringFind(lastMsgCopy,"CLOSE LOWEST") >= 0 || StringFind(lastMsgCopy,"CLOSE FIRST") >= 0 || StringFind(lastMsgCopy,"CLOSE LAST") >= 0 || StringFind(lastMsgCopy,"CLOSE ALL LOWEST") >= 0 || StringFind(lastMsgCopy,"CLOSE ALL HIGHEST") >= 0? true : false;
      bool IsProfitClose   = (StringFind(lastMsgCopy,"CLOSE ALL") >= 0 && StringFind(lastMsgCopy,"SET BE") >= 0) || (StringFind(lastMsgCopy,"COLLECT NOW") >= 0 && StringFind(lastMsgCopy,"SET BE") >= 0)  ? true : false;
      bool IsLayerClose    = StringFind(lastMsgCopy,"CLOSE FIRST LAYER") >= 0 ? true : false;
      bool IsNearTPClose   = (StringFind(lastMsgCopy,"CLOSE ALL") >= 0 || StringFind(lastMsgCopy,"CLOSE LOWEST") >= 0) && StringFind(lastMsgCopy,"SET BE") >= 0 ? true : false;

      StringToUpper(lastMsgCopy);

      //BE
      for(int i=0; i<ArraySize(BECmds); i++)
        {
         string cmd = BECmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);

         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0 && !IsProfitClose)
           {
            IsBE = true;
            break;
           }
        }

      //PC
      for(int i=0; i<ArraySize(PCCmds); i++)
        {
         string cmd = PCCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsPC = true;
            break;
           }
        }

      //SL Mod
      for(int i=0; i<ArraySize(SLCmds); i++)
        {
         string cmd = SLCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsSLMod = true;
            break;
           }
        }

      //TP Mod
      for(int i=0; i<ArraySize(TPCmds); i++)
        {
         string cmd = TPCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if(StringFind(lastMsgCopy,cmd) >= 0)
           {
            IsTPMod = true;
            break;
           }
        }

      //Close
      for(int i=0; i<ArraySize(CloseCmds); i++)
        {
         string cmd = CloseCmds[i];

         StringTrimLeft(cmd);
         StringTrimRight(cmd);


         StringToUpper(cmd);

         if((StringFind(lastMsgCopy,cmd) >= 0) && StringFind(lastMsgCopy,"HALF") < 0 && StringFind(lastMsgCopy,"PARTIAL") < 0 && !IsTargetedClose && !IsProfitClose && !IsNearTPClose)
           {
            IsClose = true;
            break;
           }
        }

      /* Log("Entry message = ",IsEntryMsg());
       Log("Entry price is ",Entry);
       Log("Orderttype is ",Ordertype);
       Log("Array size of Tradetypes is ",ArraySize(TradeTypes));*/

      if(IsEntryMsg() && StringLen(QuotedMsg)==0)
        {
         //   Alert("Just received a message.");
         //  Log("Signal was received from ",Sender);
         Log("Entry message received.");
         // if(GetQuotedSymbol() != "")
         //  Log("Quoted symbol is: ",GetQuotedSymbol());


         StringToUpper(lastMsg);

         string lastm = lastMsg;

         string row1 = StringSubstr(lastm,0,StringFind(lastm,"SL")-1);
         string row2 = StringSubstr(lastm,StringFind(lastm,"SL"),(StringFind(lastm,"TP")-1)-StringFind(lastm,"SL"));
         string row3 = StringSubstr(lastm,StringFind(lastm,"TP"));

         string msgDisplay = "";


         msgDisplay = row1+"\n"+row2+"\n"+row3;

         StringReplace(msgDisplay,"TELECOPIERZ\n","");

         Comment("LAST MESSAGE RECEIVED @ "+TimeToString(TimeCurrent())+"\n\n"+msgDisplay);

         CheckError();

         // if(ThisIDTotal(LastMsgID)==0)
         OpenTrade();

         /* if(StringLen(Symbol_Name)>0 && Ordertype>=0 && Entry>0 && SL>0 && ArraySize(TPs)>0)
            {
             Log("All trade parameters met. Trading now!.");
            }*/
        }

      else
         if(!IsEntryMsg())//CLOSE AND TRADE MODIFICATION MESSAGES
           {



            //Log("Other message received.");

            // Log("Quoted symbol is ",QSymbol);
            Log("Signal was received from "+Sender);

            StringToUpper(lastMsg);



            if(QuotedMsg != "")//IF MESSAGE IS IN REPLY TO PREVIOUS MESSAGE
              {

               WriteSignals(QuotedMsg);

               if(Symbol_Name=="")
                 {

                  string prevmsg = "";

                  if(FileIsExist("lastmessage.txt"))
                    {
                     int handle = FileOpen("lastmessage.txt",FILE_READ);

                     if(handle==INVALID_HANDLE)
                        Log("Failed to read last message, "+(string)GetLastError());

                     while(!FileIsEnding(handle))
                       {
                        prevmsg += FileReadString(handle);
                       }

                     FileClose(handle);
                    }

                  WriteSignals(prevmsg);

                 }


               if(Symbol_Name=="")//If Symbol could not be extracted from quoted message and previous message
                 {
                  string ticketgroups = "";

                  datetime opentime = 0;

                  for(int i=0; i<OrdersTotal(); i++)
                    {
                     if(OrderSelect(i,SELECT_BY_POS))
                        if(OrderMagicNumber()==InpMagicNumber)
                           if(OrderOpenTime() > opentime)
                              Symbol_Name = OrderSymbol();
                    }

                  string prevmsg = "";

                  if(FileIsExist(Symbol_Name+"_lasttickets.txt"))
                    {

                     int handle = FileOpen(Symbol_Name+"_lasttickets.txt",FILE_READ);

                     if(handle==INVALID_HANDLE)
                        Log("Failed to read last tickets, "+(string)GetLastError());

                     ticketgroups = FileReadString(handle);

                     FileClose(handle);

                    }


                  string parts[];

                  StringSplit(ticketgroups,StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>0)
                    {
                     int ticket = (int)parts[0];

                     if(OrderSelect(ticket,SELECT_BY_TICKET))
                       {

                        string parts2[];

                        StringSplit(OrderComment(),StringGetCharacter(",",0),parts2);

                        if(ArraySize(parts2) > 1)
                          {
                           sEntry = parts2[1];
                          }
                       }
                    }

                 }

               Log("Quoted symbol is "+Symbol_Name);

               /*    Log("===============================");
                   Log("Symbol: ",Symbol_Name);
                   Log("string Entry: ",sEntry);
                   Log("Stop Loss: ",SL);
                   for(int i=0; i<ArraySize(TPs); i++)
                     {
                      Log("Take Profit: ",TPs[i]);
                     }
                   Log("===============================");*/

               Comment("LAST MESSAGE RECEIVED @ "+TimeToString(TimeCurrent())+"\n\n"+lastMsg+"\n\nIN REPLY TO "+Symbol_Name+" TRADE");

               if(IsNearTPClose)
                 {
                  CloseTP1(Symbol_Name,sEntry);
                  CloseNearTPTrade(Symbol_Name,sEntry);
                  Breakeven(Symbol_Name, sEntry);
                 }

               if(IsBE)
                 {
                  Log("Breakeven message received.");
                  Breakeven(Symbol_Name, sEntry);
                 }

               if(StringFind(lastMsg,"REMOVE SL")>=0)
                  RemoveSL(Symbol_Name,sEntry);

               if(StringFind(lastMsg,"CLOSE LOWEST")>=0 || StringFind(lastMsg,"CLOSE ALL LOWEST")>=0 || StringFind(lastMsg,"CLOSE TP1")>=0)
                 {
                  Log("TP1 close message received.");
                  CloseTP1(Symbol_Name,sEntry);
                 }

               if(StringFind(lastMsg,"CLOSE TP2")>=0)
                 {
                  CloseTP2(Symbol_Name,sEntry);
                  //CloseTP3(Symbol_Name,sEntry);
                 }


               if(StringFind(lastMsg,"CLOSE HIGHEST")>=0 || StringFind(lastMsg,"CLOSE ALL HIGHEST")>=0)
                 {
                  Log("TP3 close message received.");
                  CloseTP3(Symbol_Name,sEntry);
                  //CloseTP2(Symbol_Name,sEntry);
                  //CloseTP1(Symbol_Name, sEntry);
                 }

               if(IsProfitClose)
                 {
                  Log("Profit trades close message received.");
                  CloseProfitTrade(Symbol_Name,sEntry);
                  BreakevenLoss(Symbol_Name,sEntry);
                 }


               if(IsClose || IsLayerClose)
                 {
                  Log("Close message received.");
                  // Log("Attempted to close "+Symbol_Name);
                  // while(SymbolTotal(Symbol_Name, sEntry) > 0)
                  CloseTrade(Symbol_Name,sEntry);
                 }

               if(IsPC)
                 {
                  Log("Partial close message received.");
                  // while(SymbolTotal(Symbol_Name) > 0)
                  // Log("Attempted partial close.");
                  CloseTP1(Symbol_Name,sEntry);
                  Breakeven(Symbol_Name, sEntry);
                 }

               if(GetNewSL(lastMsg,IsSLMod) != 0)
                 {
                  ChangeSL(Symbol_Name,sEntry,GetNewSL(lastMsg,IsSLMod));
                  Log("SL changed to: "+(string)GetNewSL(lastMsg, IsSLMod));
                 }




               if(GetNewTP1(lastMsg, IsTPMod) != 0)
                 {
                  ChangeTP1(Symbol_Name,sEntry,GetNewTP1(lastMsg, IsTPMod),lastMsg);
                  Log("TP1 changed to: "+(string)GetNewTP1(lastMsg, IsTPMod));
                 }




               if(GetNewTP2(lastMsg) != 0)
                 {
                  ChangeTP2(Symbol_Name,sEntry,GetNewTP2(lastMsg));
                  Log("TP2 changed to: "+(string)GetNewTP2(lastMsg));
                 }

               if(GetNewTP3(lastMsg) != 0)
                 {
                  ChangeTP3(Symbol_Name,sEntry,GetNewTP3(lastMsg));
                  Log("TP3 changed to: "+(string)GetNewTP3(lastMsg));
                 }



               // ChangeTP(Symbol_Name,sEntry);




              }


            else
               if(QuotedMsg=="")//If message is not in reply to any previous message
                 {

                  WriteSignals(lastMsg);

                  Symbol_Name = GetIDSymbol(LastMsgID);

                  //Log("Symbol detected = "+Symbol_Name);

                  if(Symbol_Name=="")//If symbol could not be extracted from last message, symbol is last message symbol
                    {

                     string prevmsg = "";

                     if(FileIsExist("lastmessage.txt"))
                       {
                        int handle = FileOpen("lastmessage.txt",FILE_READ);

                        if(handle==INVALID_HANDLE)
                           Log("Failed to read last message, "+(string)GetLastError());

                        while(!FileIsEnding(handle))
                          {
                           prevmsg += FileReadString(handle);
                          }

                        FileClose(handle);
                       }


                     WriteSignals(prevmsg);

                    }




                  if(Symbol_Name=="")//if symbol could not be extracted from last message text file, symbol is last opened symbol
                    {
                     string ticketgroups = "";

                     datetime opentime = 0;

                     for(int i=0; i<OrdersTotal(); i++)
                       {
                        if(OrderSelect(i,SELECT_BY_POS))
                           if(OrderMagicNumber()==InpMagicNumber)
                              if(OrderOpenTime() > opentime)
                                 Symbol_Name = OrderSymbol();
                       }

                    }


                  //TAKE THE TRADES
                  Comment("LAST MESSAGE RECEIVED @ "+TimeToString(TimeCurrent())+"\n\n"+lastMsg+"\n\nIN REPLY TO "+Symbol_Name+" TRADE");

                  if(IsNearTPClose)
                    {
                     CloseTP1(Symbol_Name,sEntry);
                     CloseNearTPTrade(Symbol_Name,sEntry);
                     Breakeven(Symbol_Name, sEntry);
                    }

                  if(IsBE)
                    {
                     Log("Breakeven message received.");
                     Breakeven(Symbol_Name, sEntry);
                    }

                  if(StringFind(lastMsg,"REMOVE SL")>=0)
                     RemoveSL(Symbol_Name,sEntry);

                  if(StringFind(lastMsg,"CLOSE LOWEST")>=0 || StringFind(lastMsg,"CLOSE ALL LOWEST")>=0  || StringFind(lastMsg,"CLOSE TP1")>=0)
                    {
                     Log("TP1 close message received.");
                     CloseTP1(Symbol_Name,sEntry);
                    }

                  if(StringFind(lastMsg,"CLOSE TP2")>=0)
                    {
                     CloseTP2(Symbol_Name,sEntry);
                     //CloseTP3(Symbol_Name,sEntry);
                    }


                  if(StringFind(lastMsg,"CLOSE HIGHEST")>=0 || StringFind(lastMsg,"CLOSE ALL HIGHEST")>=0)
                    {
                     Log("TP3 close message received.");
                     CloseTP3(Symbol_Name,sEntry);
                     //CloseTP2(Symbol_Name,sEntry);
                     //CloseTP1(Symbol_Name, sEntry);
                    }

                  if(IsProfitClose)
                    {
                     Log("Profit trade close message received.");
                     CloseProfitTrade(Symbol_Name,sEntry);
                     BreakevenLoss(Symbol_Name,sEntry);
                    }

                  if(IsClose || IsLayerClose)
                    {
                     Log("Close message received.");
                     // Log("Attempted to close "+Symbol_Name);
                     // while(SymbolTotal(Symbol_Name, sEntry) > 0)
                     CloseTrade(Symbol_Name,sEntry);
                    }

                  if(IsPC)
                    {
                     Log("Partial close message received.");
                     // while(SymbolTotal(Symbol_Name) > 0)
                     // Log("Attempted partial close.");
                     CloseTP1(Symbol_Name,sEntry);
                     Breakeven(Symbol_Name, sEntry);
                    }

                  if(GetNewSL(lastMsg, IsSLMod) != 0)
                    {
                     ChangeSL(Symbol_Name,sEntry,GetNewSL(lastMsg,IsSLMod));
                     Log("SL changed to: "+(string)GetNewSL(lastMsg, IsSLMod));
                    }




                  if(GetNewTP1(lastMsg, IsTPMod) != 0)
                    {
                     ChangeTP1(Symbol_Name,sEntry,GetNewTP1(lastMsg, IsTPMod),lastMsg);
                     Log("TP1 changed to: "+(string)GetNewTP1(lastMsg, IsTPMod));
                    }




                  if(GetNewTP2(lastMsg) != 0)
                    {
                     ChangeTP2(Symbol_Name,sEntry,GetNewTP2(lastMsg));
                     Log("TP2 changed to: "+(string)GetNewTP2(lastMsg));
                    }

                  if(GetNewTP3(lastMsg) != 0)
                    {
                     ChangeTP3(Symbol_Name,sEntry,GetNewTP3(lastMsg));
                     Log("TP3 changed to: "+(string)GetNewTP3(lastMsg));
                    }



                  // ChangeTP(Symbol_Name,sEntry);



                 }




           }


      int handle = FileOpen("lastmessage.txt",FILE_WRITE);

      if(handle==INVALID_HANDLE)
         Log("Failed to write last message, "+(string)GetLastError());

      FileWriteString(handle,lastMsg);
      FileClose(handle);
     }

   AppendToFile(logfile,"============================\n");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetFirstBreak(string text)
  {

   char tta[];

   StringToCharArray(text,tta);

   for(int i=0; i<ArraySize(tta); i++)
     {
      string current = CharToString(tta[i]);
      if(StringGetCharacter(current,0) == StringGetCharacter("\n",0))
         return i;
     }

   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TradesTotal()
  {

   int cnt = 0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
            cnt++;
     }

   return cnt;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void savedata()
  {
   int total = ArraySize(TicketTPs);
   if(total>0)
     {
      if(total==1)
         TicketTP1 = TicketTPs[0];

      if(total==2)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
        }

      if(total==3)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
        }

      if(total==4)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
        }

      if(total==5)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
        }

      if(total==6)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];

        }

      if(total==7)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];

        }

      if(total==8)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];
         TicketTP8 = TicketTPs[7];
        }

      if(total==9)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];
         TicketTP8 = TicketTPs[7];
         TicketTP9 = TicketTPs[8];
        }

      if(total==10)
        {
         TicketTP1 = TicketTPs[0];
         TicketTP2 = TicketTPs[1];
         TicketTP3 = TicketTPs[2];
         TicketTP4 = TicketTPs[3];
         TicketTP5 = TicketTPs[4];
         TicketTP6 = TicketTPs[5];
         TicketTP7 = TicketTPs[6];
         TicketTP8 = TicketTPs[7];
         TicketTP9 = TicketTPs[8];
         TicketTP10 = TicketTPs[9];
        }


      int handle = FileOpen("donovantps.csv",FILE_WRITE|FILE_CSV);
      if(handle==INVALID_HANDLE)
        {Log("invalid handle"); return;}
      else
        {

         FileWrite(handle,TicketTP1);
         FileWrite(handle,TicketTP2);
         FileWrite(handle,TicketTP3);
         FileWrite(handle,TicketTP4);
         FileWrite(handle,TicketTP5);
         FileWrite(handle,TicketTP6);
         FileWrite(handle,TicketTP7);
         FileWrite(handle,TicketTP8);
         FileWrite(handle,TicketTP9);
         FileWrite(handle,TicketTP10);
         FileClose(handle);

        }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getdata()
  {

   int handle = FileOpen("donovantps.csv",FILE_READ|FILE_CSV);
   if(handle==INVALID_HANDLE)
     {Log("invalid handle"); return;}
   else
     {

      TicketTP1 = FileReadString(handle);
      TicketTP2 = FileReadString(handle);
      TicketTP3 = FileReadString(handle);
      TicketTP4 = FileReadString(handle);
      TicketTP5 = FileReadString(handle);
      TicketTP6 = FileReadString(handle);
      TicketTP7 = FileReadString(handle);
      TicketTP8 = FileReadString(handle);
      TicketTP9 = FileReadString(handle);
      TicketTP10 = FileReadString(handle);

      FileClose(handle);
      FileDelete("donovantps.csv");

      ArrayFree(TicketTPs);
      ArrayResize(TicketTPs,10,0);

      TicketTPs[0] = TicketTP1;
      TicketTPs[1] = TicketTP2;
      TicketTPs[2] = TicketTP3;
      TicketTPs[3] = TicketTP4;
      TicketTPs[4] = TicketTP5;
      TicketTPs[5] = TicketTP6;
      TicketTPs[6] = TicketTP7;
      TicketTPs[7] = TicketTP8;
      TicketTPs[8] = TicketTP9;
      TicketTPs[9] = TicketTP10;
      // TicketTPs = {TicketTP1,TicketTP2,TicketTP3,TicketTP4,TicketTP5,TicketTP6,TicketTP7,TicketTP8,TicketTP9,TicketTP10};

     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetQuotedSymbol()
  {

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates?offset="+(string)LastMsgID;

   resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);

   string msg = CharArrayToString(results);

   int text_begin = 0;

   for(int i=ArraySize(results)-1; i>=0; i--)
     {
      if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
        {
         text_begin = i;
         break;
        }
     }

   for(int i=text_begin-1; i>=0; i--)
     {
      if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
        {
         lastMsg = StringSubstr(msg,i,(StringLen(msg)-text_begin)-2);

         int rep = StringReplace(lastMsg,"text\":\"","");
         rep     += StringReplace(lastMsg,"]","");
         rep     += StringReplace(lastMsg,"}","");
         rep     += StringReplace(lastMsg,"\"","");
         rep     += StringReplace(lastMsg,"\\"+"n"," ");
         break;
        }
     }


   return GetSymbol(lastMsg);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetLastMessage()
  {
   QuotedMsg = "";

   QSymbol = "";

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates?offset="+(string)LastMsgID;

   resu = 0;

   int numOfTries = 0;

   while(resu != 200 && numOfTries < InpConnRetry)
     {
      resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);
      numOfTries++;
     }

   if(numOfTries==10 && resu != 200)
     {
      Comment("Failed to get last message due to connection error ",resu);
      return "";
     }

   Log("Connection request for last message succesful, status code = "+(string)resu);


   string msg = CharArrayToString(results);



// Log(StringSubstr(msg,StringLen(msg)-500,StringLen(msg)));

   int text_begin = 0;

   if(StringFind(msg,"\"photo\":") < 0)
     {

      for(int i=ArraySize(results)-5; i>=0; i--)
        {
         if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
           {
            text_begin = i;
            break;
           }
        }

      lastMsg = StringSubstr(msg,text_begin,StringLen(msg)-1);

      int rep = StringReplace(lastMsg,"text\":\"","");
      rep     += StringReplace(lastMsg,"]","");
      rep     += StringReplace(lastMsg,"}","");
      rep     += StringReplace(lastMsg,"\"","");
      rep     += StringReplace(lastMsg,"\\"+"n"," ");

      for(int i=text_begin-5; i>=0; i--)
        {
         if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
           {
            string quoted = StringSubstr(msg,i+4,text_begin-i);

            StringToUpper(quoted);

            if(StringLen(QuotedMsg)==0)
              {

               QuotedMsg = quoted;

               rep      = StringReplace(QuotedMsg,"TEXT","");
               rep     += StringReplace(QuotedMsg,"]","");
               rep     += StringReplace(QuotedMsg,"}","");
               rep     += StringReplace(QuotedMsg,"\"","");
               rep     += StringReplace(QuotedMsg,"\\"+"n"," ");


              }


            for(int j=0; j<SymbolsTotal(true); j++)
              {
               string name = SymbolName(j,true);

               for(int k=0; k<StringLen(quoted); k++)
                 {
                  string check = "";
                  string cleanmsg = quoted;
                  StringReplace(cleanmsg,"/","");
                  check = StringSubstr(cleanmsg,k,StringLen(name));

                  for(int l=0; l<ArraySize(OtherSymbols); l++)
                    {
                     if(StringFind(check,OtherSymbols[l])>=0)
                        check = OtherSymbols[l];
                    }

                  if(check==name || VerifiedSymbol(check)==name)
                    {
                     QSymbol = name;
                     break;
                    }

                 }

              }
           }
        }

     }


   else
      if(StringFind(msg,"\"photo\":") >= 0)
        {
         for(int i=ArraySize(results)-5; i>=0; i--)
           {
            if(CharToString(results[i])=="t" && CharToString(results[i+1])=="e" && CharToString(results[i+2])=="x" && CharToString(results[i+3])=="t")
              {
               text_begin = i;
               break;
              }
           }

         QuotedMsg = StringSubstr(msg,text_begin,StringLen(msg)-1);

         int rep = StringReplace(QuotedMsg,"TEXT\":\"","");
         rep     += StringReplace(QuotedMsg,"]","");
         rep     += StringReplace(QuotedMsg,"}","");
         rep     += StringReplace(QuotedMsg,"\"","");
         rep     += StringReplace(QuotedMsg,"\\"+"n"," ");

         StringToUpper(QuotedMsg);

         QuotedMsg = StringSubstr(QuotedMsg,5,StringFind(QuotedMsg,",PHOTO"));

         int handle = FileOpen("msgtest.csv",FILE_WRITE|FILE_CSV);

         FileWriteString(handle,QuotedMsg);
         FileClose(handle);

         int findcaption = StringFind(msg,"\"caption\"");
         int length      = (StringLen(msg)-1)-findcaption;

         lastMsg = StringSubstr(msg,findcaption,length);

         rep = StringReplace(lastMsg,"\"caption\":\"","");
         rep     += StringReplace(lastMsg,"]","");
         rep     += StringReplace(lastMsg,"}","");
         rep     += StringReplace(lastMsg,"\"","");
         rep     += StringReplace(lastMsg,"\\"+"n"," ");
        }


// LastMsgID = GetLastMsgID();

// Comment(LastMsgID);

   return(lastMsg);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSender()
  {

   QSymbol = "";

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates?offset="+(string)LastMsgID;

   resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);

   string msg = CharArrayToString(results);

   int begin = StringFind(msg,"forward_from_chat");
   int end = StringFind(msg,"forward_from_message_id");

   string sender = StringSubstr(msg,begin,end-begin);

   int begin2 = StringFind(sender,"title");
   int end2 = StringFind(sender,"username");

   sender = StringSubstr(sender,begin2,end2-begin2);

   int rep = StringReplace(sender,"title\":\"","");
   rep     += StringReplace(sender,"]","");
   rep     += StringReplace(sender,"}","");
   rep     += StringReplace(sender,"\"","");
   rep     += StringReplace(sender,"\\"+"n"," ");
   rep     += StringReplace(sender,","," ");

   int cut = StringFind(sender,"type",0);

   if(cut > 0)
      sender = StringSubstr(sender,0,cut);

//Log("Sender was: ",sender);


   return(msg);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLastMsgID()
  {

   int timeout = 2000;

   string lastMsg = "";

   string url = baseurl+"/bot"+token+"/getUpdates";

   resu = 0;

   int numOfTries = 0;

   while(resu != 200 && numOfTries < InpConnRetry)
     {
      resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);
      numOfTries++;
     }

   if(numOfTries==10 && resu != 200)
     {
      Comment("Failed to get last message due to connection error ",resu);
      return -1;
     }

// Log("Connection request for last message succesful, status code = ",resu);


   string msg = CharArrayToString(results);



   int text_begin = 0;

   for(int i=ArraySize(results)-1; i>=0; i--)
     {
      if(CharToString(results[i])=="u" && CharToString(results[i+1])=="p" && CharToString(results[i+2])=="d" && CharToString(results[i+3])=="a" && CharToString(results[i+4])=="t"
         && CharToString(results[i+5])=="e")
        {
         text_begin = i;
         break;
        }
     }

   lastMsg = StringSubstr(msg,text_begin,20);

   int rep = StringReplace(lastMsg,"update_id\":","");
   StringTrimLeft(lastMsg);
   StringTrimRight(lastMsg);


   return((int)lastMsg);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewMessage()
  {

   if(!FileIsExist("lastsignal.txt"))
      return false;



   string Content = "";

   int handle = FileOpen("lastsignal.txt",FILE_READ);

   if(handle==INVALID_HANDLE)
     {
      Log("Failed to read new message file. Error = "+(string)GetLastError());
      return false;
     }

   int linecnt = 0;

   while(!FileIsEnding(handle))
     {
      if(linecnt == 0)
         Sender = FileReadString(handle);

      Content += FileReadString(handle);

      linecnt++;
     }

   FileClose(handle);

   StringToUpper(Content);

   if(Message != Content)
     {
      Log("New message received.");
      Message = Content;
      return true;
     }


   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteSignals(string msg)
  {

   Symbol_Name = "";
   sEntry = "";
   Ordertype = -1;
   Entry = 0;
   SL = 0;
   ArrayFree(TPs);

   StringToUpper(msg);

   int repmsg = 0;


   if(StringFind(msg,"TAKEPROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKEPROFIT","TP");

   if(StringFind(msg,"TAKE PROFIT 1",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 1","TP");

   if(StringFind(msg,"TAKE PROFIT 2",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 2","TP");

   if(StringFind(msg,"TAKE PROFIT 3",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 3","TP");

   if(StringFind(msg,"TAKE PROFIT 4",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT 4","TP");

   if(StringFind(msg,"STOPLOSS",0)>=0)
      repmsg += StringReplace(msg,"STOPLOSS","SL");

   if(StringFind(msg,"STOP LOSS",0)>=0)
      repmsg += StringReplace(msg,"STOP LOSS","SL");

   if(StringFind(msg,"TAKE PROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT","TP");

   if(StringFind(msg,"TP1",0)>=0)
      repmsg += StringReplace(msg,"TP1","TP");

   if(StringFind(msg,"TP2",0)>=0)
      repmsg += StringReplace(msg,"TP2","TP");

   if(StringFind(msg,"TP3",0)>=0)
      repmsg += StringReplace(msg,"TP3","TP");

   if(StringFind(msg,"TP4",0)>=0)
      repmsg += StringReplace(msg,"TP4","TP");

   if(StringFind(msg,"TP5",0)>=0)
      repmsg += StringReplace(msg,"TP5","TP");

   if(StringFind(msg,"TP6",0)>=0)
      repmsg += StringReplace(msg,"TP6","TP");


   if(StringFind(msg,"TP 1:",0)>=0)
      repmsg += StringReplace(msg,"TP 1:","TP:");

   if(StringFind(msg,"TP 2:",0)>=0)
      repmsg += StringReplace(msg,"TP 2:","TP:");

   if(StringFind(msg,"TP 3:",0)>=0)
      repmsg += StringReplace(msg,"TP 3:","TP:");

   if(StringFind(msg,"TP 4:",0)>=0)
      repmsg += StringReplace(msg,"TP 4:","TP:");

   if(StringFind(msg,"TP 5:",0)>=0)
      repmsg += StringReplace(msg,"TP 5:","TP:");

   if(StringFind(msg,"TP 6:",0)>=0)
      repmsg += StringReplace(msg,"TP 6:","TP:");

   if(StringFind(msg,"TP 1 ",0)>=0)
      repmsg += StringReplace(msg,"TP 1 ","TP");

   if(StringFind(msg,"TP 2 ",0)>=0)
      repmsg += StringReplace(msg,"TP 2 ","TP");

   if(StringFind(msg,"TP 3 ",0)>=0)
      repmsg += StringReplace(msg,"TP 3 ","TP");

   if(StringFind(msg,"TP 4 ",0)>=0)
      repmsg += StringReplace(msg,"TP 4 ","TP");

   if(StringFind(msg,"TP 5 ",0)>=0)
      repmsg += StringReplace(msg,"TP 5 ","TP");

   if(StringFind(msg,"TP 6 ",0)>=0)
      repmsg += StringReplace(msg,"TP 6 ","TP");

// repmsg += StringReplace(msg," ","");

   repmsg += StringReplace(msg,"@","");

   StringReplace(msg,"-","");

// Comment(msg);

// Log("Processed message ",msg);

   int tplocs[];
   int slloc = -1;

   char msgToArray[];

   StringToCharArray(msg,msgToArray,0); //Conver string to char array for easy loop


   /*for(int i=0; i<ArraySize(msgToArray); i++)
     {
      if(!IsFound(CharToString(msgToArray[i]),PriceChars) && !IsFound(CharToString(msgToArray[i]),Letters) && !IsFound(CharToString(msgToArray[i]),LETTERS))
         repmsg += StringReplace(msg,CharToString(msgToArray[i]),"");
     }*/


   /*  for(int i=0;i<ArraySize(msgToArray);i++)
       {
         if( !IsFound(CharToString(msgToArray[i]), PriceChars) && !IsFound(CharToString(msgToArray[i]), Letters) && !IsFound(CharToString(msgToArray[i]), LETTERS) && msgToArray[i]!='\n' && msgToArray[i]!=' ')
           StringReplace(msg,CharToString(msgToArray[i]),"");

         Log("Cleaned message: ",msg);
       } */

//Get TP locations
   for(int i=1; i<ArraySize(msgToArray); i++)
     {

      if((CharToString(msgToArray[i])=="P" && CharToString(msgToArray[i-1])=="T"))  //Find any TP strings in message
        {
         ArrayResize(tplocs,ArraySize(tplocs)+1,0);
         tplocs[ArraySize(tplocs)-1] = i-1;//Save all TP string locations into an array
        }

     }

//Get SL Location
   for(int i=1; i<ArraySize(msgToArray); i++)
     {


      if((CharToString(msgToArray[i])=="L" && CharToString(msgToArray[i-1])=="S"))//Find any SL strings in message
        {
         slloc = i-1;
         break;
         // Log(IntegerToString(slloc));
        }


     }

   if(ArraySize(tplocs) > 0)  //Assign only if there is TP in message
     {
      ArrayFree(TPs);
      
      string tpsl = "";

      for(int i=tplocs[0]+2; i<ArraySize(msgToArray); i++)//for a particular TP location, up to the end of the msg string, find the corresponding price
        {
         string this_char = CharToString(msgToArray[i]);

         if(this_char==" " || this_char=="  " || this_char==":")
            continue;

         if(this_char=="." && StringLen(tpsl)==0)
            continue;

         if(IsFound(this_char,PriceChars) || this_char == "/")
           {
            tpsl += this_char;
            // Log("Added ",this_char);
           }

         if(!IsFound(this_char,PriceChars) && this_char != "/" && StringLen(tpsl)>0)
            break;
        }

      

    //  Print("TPSL is ",tpsl);

      // Print("Size of tplocs = ",ArraySize(tplocs));

     // Print(StringFind(tpsl,"/"));

      if(ArraySize(tplocs) == 1 && StringFind(tpsl,"/") >= 0)
        {

         StringReplace(tpsl,":","");
         StringReplace(tpsl,"TP","");
         StringReplace(tpsl,"SL","");

         string tpparts[];

         StringSplit(tpsl,StringGetCharacter("/",0),tpparts);

        // Print("Size of tpparts = ",ArraySize(tpparts));

         if(ArraySize(tpparts) > 0)
           {
            //Log("Size of tpparts = ",ArraySize(tpparts));
            for(int m=0; m<ArraySize(tpparts); m++)
              {
               string thisItem = tpparts[m];

              // Print("TP ",m+1," is ",thisItem);

               StringTrimLeft(StringTrimRight(thisItem));

               AddToArray(TPs,(double)thisItem);
              }
           }

        }

      else
        {
         for(int j=0; j<ArraySize(tplocs); j++)//For each TP location, find the adjacent price value
           {
            string tp = "";

            // Log("========================");

            for(int i=tplocs[j]+2; i<ArraySize(msgToArray); i++)//for a particular TP location, up to the end of the msg string, find the corresponding price
              {
               string this_char = CharToString(msgToArray[i]);

               if(this_char==" " || this_char=="  " || this_char==":")
                  continue;

               if(this_char=="." && StringLen(tp)==0)
                  continue;

               if(IsFound(this_char,PriceChars))
                 {
                  tp += this_char;
                  // Log("Added ",this_char);
                 }

               if(!IsFound(this_char,PriceChars) && StringLen(tp)>0)
                  break;
              }

            //   Log("========================");

            if(tp == "")
               tp = "OPEN";

            StringTrimLeft(StringTrimRight(tp));
            // Log("TP",tplocs[j]+1," ",tp

            if(StringToDouble(tp) != 0 && tp != "OPEN")
              {

               ArrayResize(TPs,ArraySize(TPs)+1,0);
               TPs[ArraySize(TPs)-1] = StringToDouble(tp);//Save the TP prices extracted into an array o TP

              }

            else
               if(tp == "OPEN")
                 {

                  ArrayResize(TPs,ArraySize(TPs)+1,0);
                  TPs[ArraySize(TPs)-1] = 0;//Save the TP prices extracted into an array o TP

                 }

           }
        }

      for(int i=0; i<ArraySize(TPs); i++)
        {
         Log("TP "+IntegerToString(i)+" is "+DoubleToString(TPs[i]));
        }

     }



//Extract SL
   string sl = "";

   if(slloc >= 0)
     {
      SL = 0;

      for(int i=slloc+2; i<ArraySize(msgToArray); i++)
        {

         string this_char = CharToString(msgToArray[i]);

         if(this_char==" " || this_char=="  " || this_char==":")
            continue;

         if(this_char=="." && StringLen(sl)==0)
            continue;

         if(IsFound(this_char,PriceChars))
            sl += this_char;

         if(!IsFound(this_char,PriceChars) && StringLen(sl)>0)
            break;
        }
      StringTrimLeft(StringTrimRight(sl));
      //Log("SL string was ",sl);
      SL = StringToDouble(sl);
      Log("Stop Loss is "+DoubleToString(SL));
     }





//Extract Symbol
   string tempmsg = msg;


   string symbol = "";




   if(symbol=="")
     {
      for(int j=0; j<SymbolsTotal(true); j++)
        {
         string check = "";
         string name = SymbolName(j,true);
         string nameCopy = name;

         StringToUpper(nameCopy);

         if(StringLen(name)<3)
            continue;

         string cleanmsg = msg;
         StringReplace(cleanmsg,"/","");

         if(StringFind(cleanmsg,nameCopy)>=0)
           {
            //StringReplace(tempmsg,name,"");
            symbol = name;
            break;
           }

         else
           {
            char m2a[];

            int suffixPos = -1;

            StringToCharArray(name,m2a);

            for(int k=0; k<ArraySize(m2a); k++)
              {
               if(CharToString(m2a[k])=="." || CharToString(m2a[k])=="-")
                 {
                  suffixPos = k;
                  break;
                 }
              }

            string withoutSuffix = StringSubstr(name,0,suffixPos);

            if(StringFind(cleanmsg,withoutSuffix)>=0)
              {
               symbol = name;
               break;
              }

           }
        }
     }


   if(symbol=="")
     {
      for(int i=0; i<ArraySize(BrokerNames); i++)
        {

         string parts[];

         StringSplit(BrokerNames[i],StringGetCharacter("=",0),parts);

         if(ArraySize(parts) == 0)
            continue;

         StringToUpper(parts[0]);

         if(StringFind(msg,parts[0]) >= 0)
           {
            StringReplace(tempmsg,parts[0],"");
            symbol = parts[1];

            break;
           }
        }
     }




   /* if(symbol=="")
      {

       for(int i=0; i<ArraySize(OtherSymbols); i++)
         {
          string cleanmsg = msg;
          StringReplace(cleanmsg,"/","");

          if(StringFind(cleanmsg,OtherSymbols[i])>=0)
            {
             symbol = VerifiedSymbol(OtherSymbols[i]);
             break;
            }
         }

      }

    if(symbol=="")
      {
       string sigsyms[];

       AddToArray(sigsyms,InpSigGoldName);
       AddToArray(sigsyms,InpSigNasName);
       AddToArray(sigsyms,InpSigUS30Name);

       for(int i=0; i<ArraySize(sigsyms); i++)
         {
          string cleanmsg = msg;
          StringReplace(cleanmsg,"/","");

          if(StringFind(cleanmsg,sigsyms[i])>=0)
            {
             symbol = VerifiedSymbol(sigsyms[i]);
             break;
            }
         }
      }*/



   Symbol_Name = symbol;
   Log("Symbol name is: "+Symbol_Name);

//Extract OT
   int symloc = 0;

   string tempmsg2 = msg;
   StringToUpper(tempmsg2);

   for(int i=ArraySize(TradeTypes)-1; i>=0; i--)
     {
      string type = TradeTypes[i];


      StringTrimLeft(type);
      StringTrimRight(type);

      StringToUpper(type);

      if(StringFind(tempmsg2,type,0)>=0)
        {

         Ordertype = StringToOrdertype(type);

         if(Ordertype==0 && StringFind(msg,"LIMIT") >= 0)
            Ordertype = 2;

         if(Ordertype==1 && StringFind(msg,"LIMIT") >= 0)
            Ordertype = 3;

         if(Ordertype==0 && (StringFind(msg,"BUYSTOP") >= 0 || StringFind(msg,"BUY STOP") >= 0))
            Ordertype = 4;

         if(Ordertype==1 && (StringFind(msg,"SELLSTOP") >= 0 || StringFind(msg,"SELL STOP") >= 0))
            Ordertype = 5;

         Log("Ordertype is "+type);
         break;
        }

     }


//Extract Entry
   if(Ordertype >= 0 && StringLen(Symbol_Name)>0)
     {
      Entry = 0;
      Entry = GetEntry(Ordertype,Symbol_Name, sl, tempmsg);
      Log("Entry is "+DoubleToString(Entry));
     }


// Comment(Symbol_Name,"TP1: ",TP1,"TP2: ",TP2,"TP3: ",TP3,"SL: ",SL)

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadSignals()
  {





  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFound(string value, string &array[])
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(value == array[i])
         return(true);
     }

   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFound(char value, char &array[])
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(value == array[i])
         return(true);
     }

   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFound(double value, double &array[])
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(value == array[i])
         return(true);
     }

   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFound(int value, int &array[])
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(value == array[i])
         return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
int StringToOrdertype(string ot)
  {

   if(ot=="BUY")
      return(OP_BUY);

   if(ot=="SELL")
      return(OP_SELL);

   if(ot=="BUY STOP" || ot=="BUYSTOP" || ot=="STOP BUY" || ot=="STOPBUY")
      return(OP_BUYSTOP);

   if(ot=="BUY LIMIT" || ot=="BUYLIMIT" || ot=="LIMIT BUY" || ot=="LIMITBUY")
      return(OP_BUYLIMIT);

   if(ot=="SELL STOP" || ot=="SELLSTOP" || ot=="STOP SELL" || ot=="STOPSELL")
      return(OP_SELLSTOP);

   if(ot=="SELL LIMIT" || ot=="SELLLIMIT" || ot=="LIMIT SELL" || ot=="LIMITSELL")
      return(OP_SELLLIMIT);

   return(-1);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetEntry(int ot, string sym, string sl, string msg="")
  {

   sEntry = "";

   double entry = 0;



   StringToUpper(msg);

   StringReplace(msg," ","");

   int repmsg = 0;


   if(StringFind(msg,"TAKEPROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKEPROFIT","TP");

   if(StringFind(msg,"STOPLOSS",0)>=0)
      repmsg += StringReplace(msg,"STOPLOSS","SL");

   if(StringFind(msg,"STOP LOSS",0)>=0)
      repmsg += StringReplace(msg,"STOP LOSS","SL");

   if(StringFind(msg,"TAKE PROFIT",0)>=0)
      repmsg += StringReplace(msg,"TAKE PROFIT","TP");

   if(StringFind(msg,"TP1",0)>=0)
      repmsg += StringReplace(msg,"TP1","TP");

   if(StringFind(msg,"TP2",0)>=0)
      repmsg += StringReplace(msg,"TP2","TP");

   if(StringFind(msg,"TP3",0)>=0)
      repmsg += StringReplace(msg,"TP3","TP");

   repmsg += StringReplace(msg," ","");

   repmsg += StringReplace(msg,"@","");

   int begin = 0;

   int end   = 0;

   int slbegin = StringFind(msg,"SL");

   int tpbegin = StringFind(msg,"TP");

   end = (int)MathMin(slbegin, tpbegin);

   bool isRelative = StringFind(StringSubstr(msg,0,end),"AREA") >= 0 ? true : false;

   string ent = "";

   char msgToArr[];

   StringToCharArray(msg,msgToArr,0,end);

   for(int i=0; i<ArraySize(msgToArr); i++)
     {
      if(IsFound(CharToString(msgToArr[i]),PriceChars))
         ent += CharToString(msgToArr[i]);
     }




   StringTrimLeft(StringTrimRight(ent));

   string tocut = StringSubstr(ent,0,StringLen(ent)-StringLen(sl));

// Log("String to cut = ",tocut);

   if(StringLen(ent) > StringLen(sl))
      StringReplace(ent, tocut, "");

//  Log("Entry price should be: ",ent);
// Log("SL string should be: ",sl);

   sEntry = ent;

   if(!isRelative)
      entry = StringToDouble(ent);

   else
      if(isRelative)
        {
         StringTrimLeft(StringTrimRight(tocut));
         entry = (StringToDouble(tocut)+StringToDouble(ent))/2;
        }

   if(ot==0)
      return(SymbolInfoDouble(sym,SYMBOL_ASK));

   else
      if(ot==1)
         return(SymbolInfoDouble(sym,SYMBOL_BID));

      else
         return(entry);

   return(0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSymbolFound(string sym)
  {

   for(int i=0; i<SymbolsTotal(true); i++)
     {
      string name   = SymbolName(i,true);
      string firstletter = StringSubstr(sym,0,1);
      string rest        = StringSubstr(sym,1,StringLen(sym)-1);
      bool firsttoupper = StringToUpper(firstletter);
      bool resttolower  = StringToLower(rest);

      sym = firstletter+rest;
      if(sym==name)
         return(true);


      bool symtoupper = StringToUpper(sym);
      bool nametoupper = StringToUpper(name);

      if(sym==name)
         return true;

     }
   return(false);
  }


//+------------------------------------------------------------------+
bool IsNews(string symbol)
  {

   string parts[];

   StringSplit(today,StringGetCharacter(".",0),parts);

   if(ArraySize(parts) == 0)
      return false;

   today = "";

   today += parts[1]+"-"+parts[2]+"-"+parts[0];


   bool check = false;

   string symcopy = symbol;
   int    len     = StringLen(symcopy);

   string curr1 = StringSubstr(symcopy,0,(int)len/2);
   string curr2 = StringSubstr(symcopy,(int)len/2,(int)len/2);

   if(StringFind(symbol,InpUS30Name) >= 0 || StringFind(symbol,InpNasName) >= 0)
     {
      curr1 = "USD";
      curr2 = "USD";
     }

   if(StringFind(symbol,"DAX") >= 0 || StringFind(symbol,"FRA") >= 0)
     {
      curr1 = "EUR";
      curr2 = "EUR";
     }

   if(StringFind(symbol,"JAP") >= 0)
     {
      curr1 = "JPY";
      curr2 = "JPY";
     }

   if(StringFind(symbol,"AUS") >= 0)
     {
      curr1 = "AUD";
      curr2 = "AUD";
     }

//Log("Currency 1 is ",curr1);
//Log("Currency 2 is ",curr2);

   int handle = FileOpen("News.csv",FILE_READ);

   if(handle==INVALID_HANDLE)
     {
      Log("Failed to read news file.");
      return false;
     }

   while(!FileIsEnding(handle))
     {
      string line = FileReadString(handle);

      StringToUpper(line);
      StringToUpper(curr1);
      StringToUpper(curr2);

      string newssplit[];

      StringSplit(line,StringGetCharacter(",",0),newssplit);

      if(ArraySize(newssplit)==0)
         return false;

      string newstime = TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeTo24h(newssplit[3]);

      datetime nt2d = StringToTime(newstime);

      nt2d = nt2d+TimezoneOffsetSecs;

      bool checkhigh   = InpHighImpact==true ? (StringFind(line,"HIGH") >= 0 || StringFind(line,"High") >= 0) : false;
      bool checkmedium = InpMediumImpact==true ? (StringFind(line,"MEDIUM") >= 0 || StringFind(line,"Medium") >= 0) : false;
      bool checklow    = InpLowImpact==true ? (StringFind(line,"LOW") >= 0 || StringFind(line,"Low") >= 0) : false;

      if((StringFind(line,curr1) >= 0 || StringFind(line,curr2) >= 0 || StringFind(line,"ALL") >= 0) && StringFind(line,today) >= 0 && (checkhigh || checklow || checkmedium))
        {
         string curr = StringFind(line,curr1) >= 0 ? curr1 : curr2;

         if(InpUseNewsFilter)
           {
            if(checkhigh)
               Print("High impact news found today for ",curr," = ",newssplit[0]," @ ",nt2d);

            if(checkmedium)
               Print("Medium impact news found today for ",curr," = ",newssplit[0]," @ ",nt2d);

            if(checklow)
               Print("Low impact news found today for ",curr," = ",newssplit[0]," @ ",nt2d);

            Print(Symbol_Name," trades will be paused between ",nt2d-(InpPreNewsShutdownTime*60)," and ",nt2d+(InpPostNewsResumeTime*60));
           }

         if(TimeCurrent() >= nt2d-(InpPreNewsShutdownTime*60) && TimeCurrent() <= nt2d+(InpPostNewsResumeTime*60))
           {
            check = true;
            if(InpUseNewsFilter)
              {
               Comment("No ",Symbol_Name," trades allowed now due to news. Trading will resume @ ",nt2d+(InpPostNewsResumeTime*60));
              }
            break;
           }
        }

     }

   FileClose(handle);

   return check;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade()
  {

   if(StringFind(LASTMSG,"HIGHRISK") >= 0 || StringFind(LASTMSG,"HIGH RISK") >= 0)
     {
      Log("High risk trade avoided.");
      Comment("High risk trade avoided.");
      return;
     }


   string exc_sym = "";
   double lots    = 0;

   GetChannelParams(lots,exc_sym);

   Log("Excluded symbols: "+exc_sym);
   Log("Lot size: "+(string)lots);

   string excluded[];

   if(StringFind(exc_sym,",") >= 0)
     {

      StringSplit(exc_sym,StringGetCharacter(",",0),excluded);

      if(ArraySize(excluded) > 0)
        {

         for(int i=0; i<ArraySize(excluded); i++)
           {
            string e = excluded[i];

            StringToUpper(e);

            if(StringFind(LASTMSG,e) >= 0)
              {
               Log(Symbol_Name+" trades from "+Sender+" not allowed.");
               Comment(Symbol_Name," trades from ",Sender," not allowed.");
               return;
              }

            if(Symbol_Name==e)
              {
               Log(Symbol_Name+" trades from "+Sender+" not allowed.");
               Comment(Symbol_Name," trades from ",Sender," not allowed.");
               return;
              }
           }

        }

     }

   else
     {
      if(StringFind(LASTMSG,exc_sym) >= 0)
        {
         Log(Symbol_Name+" trades from "+Sender+" not allowed.");
         Comment(Symbol_Name," trades from ",Sender," not allowed.");
         return;
        }

      if(Symbol_Name==exc_sym)
        {
         Log(Symbol_Name+" trades from "+Sender+" not allowed.");
         Comment(Symbol_Name," trades from ",Sender," not allowed.");
         return;
        }
     }

   if(InpUseNewsFilter && IsNews(Symbol_Name))
      return;


   if(IsFound(Symbol_Name,ExcludedSymbols))
      return;

   if(InpTradeSelect && !IsFound(Symbol_Name,SelectPairs))
     {
      Log("Trade not allowed. This instrument is not in the list of allowed instruments.");
      return;
     }

   string SLAmt = "";
   string TPAmt = "";
   string tradeinfo = "";

   int ticket  = 0;

   double Lots = 0;

   double spread = SymbolInfoDouble(Symbol_Name,SYMBOL_ASK) - SymbolInfoDouble(Symbol_Name,SYMBOL_BID);

   if(InpUseSpreadFilter && spread >= PipsToPrice(InpMaxSpread,Symbol_Name))
     {
      Log("Cannot place trade. Current spread is greater than "+(string)InpMaxSpread);
      return;
     }

// Alert("Current spread for ",Symbol_Name," is ",spread);

   if(SL == 0)
     {

      SL = Ordertype==OP_BUY || Ordertype==OP_BUYLIMIT || Ordertype==OP_BUYSTOP ? Entry-PipsToPrice(InpDefaultSL,Symbol_Name) :
           Entry+PipsToPrice(InpDefaultSL,Symbol_Name);
     }

   if(ArraySize(TPs) == 0)
     {
      double tp = Ordertype==OP_BUY || Ordertype==OP_BUYLIMIT || Ordertype==OP_BUYSTOP ? Entry+PipsToPrice(InpDefaultTP,Symbol_Name) :
                  Entry-PipsToPrice(InpDefaultTP,Symbol_Name);
      ArrayFree(TPs);
      AddToArray(TPs,tp);
     }

   int min = ArraySize(TPs);//(int)MathMin(3,ArraySize(TPs));

   double slpricevalue = MathAbs(SL-Entry);

   string lastticketgroup = "";

//  Log("SL without spread = ",SL);

   if(InpUseSpread)
      SL = Ordertype==OP_BUY || Ordertype==OP_BUYLIMIT || Ordertype==OP_BUYSTOP ? SL-spread : SL+spread;

//  Log("SL with spread = ",SL);

   for(int i=0; i<min; i++)
     {
      double lot = InpLotMode==fixed ? InpLotValue : GetLots(slpricevalue);

      if(InpTradeSelect && (ArraySize(LotsPerSymbol)>0 && GetSymbolLot(Symbol_Name) > 0))
        {
         lot = GetSymbolLot(Symbol_Name);
        }

      // Log("Lot size should be ",lot);
      // Lots   = lot > SymbolInfoDouble(Symbol_Name,SYMBOL_VOLUME_MIN) ? lot : SymbolInfoDouble(Symbol_Name,SYMBOL_VOLUME_MIN);
      //  Log("TP without spread = ",TPs[ArraySize(TPs)-1]);

      double tp = TPs[i];//TPs[ArraySize(TPs)-1];

      string SenderCopy = Sender;

      string SenderRefined = "";

      char SenderArray[];

      StringToCharArray(SenderCopy,SenderArray);

      for(int z=0; z<ArraySize(SenderArray); z++)
        {
         if(IsFound(CharToString(SenderArray[z]),Letters) || IsFound(CharToString(SenderArray[z]),LETTERS) || CharToString(SenderArray[z]) == " ")
            SenderRefined += CharToString(SenderArray[z]);
        }


      //if(InpUseSpread)
      //   tp = Ordertype==OP_BUY || Ordertype==OP_BUYLIMIT || Ordertype==OP_BUYSTOP ? TPs[ArraySize(TPs)-1] + spread : TPs[ArraySize(TPs)-1] - spread;

      //   Log("TP with spread = ",tp);

      ticket = OrderSend(Symbol_Name,Ordertype,lots,Entry,InpMaxSlippage,SL,tp,SenderRefined,InpMagicNumber,0,clrNONE);

      if(ticket <= 0)
         Log("Failed to place trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());

      double riskAmount   = GetRiskAmount(slpricevalue,lot);

      double profitAmount = GetRiskAmount(MathAbs(Entry-tp),lot);

      string profit = (string)profitAmount;
      string risk   = (string)riskAmount;

      profit =  StringFind(profit,".") >= 0 ? StringSubstr(profit,0,StringFind(profit,".")) : profit;
      risk = StringFind(risk,".") >= 0 ? StringSubstr(risk,0,StringFind(risk,".")) : risk;

      SLAmt = "SL: "+InpAccCuency+risk;
      TPAmt += "TP"+(string)(i+1)+": "+InpAccCuency+profit+"\n";

      if(ticket > 0)
         AddToArray(IDs,LastMsgID+","+(string)ticket);

      //  WriteEntry(Symbol_Name+","+(string)ticket+","+(string)(i+1)+","+(string)lot+","+sEntry,(string)(i+1)+","+(string)lot+","+sEntry);

      lastticketgroup = (string)lot+",";

      for(int j=0; j<ArraySize(TPs); j++)
        {
         if(j==3)
            break;

         lastticketgroup += (string)TPs[j]+",";
        }

     }

//  Log("Risk amount is: ",SLAmt);
//  Log("Potential profits are ",TPAmt);

   tradeinfo = "MT4 COPIER NEW TRADE ALERT\n====================\nChannel: "+Sender+"\nSymbol: "+Symbol_Name+"\n"+SLAmt+"\n"+TPAmt;


   int hTradeinfo = FileOpen("tradeinfo.txt",FILE_WRITE);

   if(hTradeinfo==INVALID_HANDLE)
      Log("Failed to write write trade info for, "+Symbol_Name+", "+(string)GetLastError());

   FileWriteString(hTradeinfo,tradeinfo);
   FileClose(hTradeinfo);

   lastticketgroup = StringSubstr(lastticketgroup,0,StringLen(lastticketgroup)-1);

   int handle      = FileOpen(Symbol_Name+"_lasttickets.txt",FILE_WRITE);

   if(handle==INVALID_HANDLE)
      Log("Failed to write last set of tickets for, "+Symbol_Name+", "+(string)GetLastError());

   FileWriteString(handle,lastticketgroup);
   FileClose(handle);

   if(ticket>0)
     {
      Symbol_Name = "";
      Ordertype = -1;
      Entry = 0;
      SL = 0;
      ArrayFree(TPs);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIn(string child, string mother)
  {

   if(StringFind(mother,child)>=0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string VerifiedSymbol(string sym)
  {
   bool symtoupper = StringToUpper(sym);

   if(sym==InpSigGoldName)
     {
      if(IsSymbolFound(sym))
         return sym;

      else
         return(InpGoldName);
     }

   if(sym==InpSigUS30Name)
     {
      if(IsSymbolFound(sym))
         return sym;

      else
         return(InpUS30Name);
     }

   if(sym==InpSigNasName)
     {
      if(IsSymbolFound(sym))
         return sym;

      else
         return(InpNasName);
     }

   if(sym=="ETH" || sym=="ETHEREUM" || sym=="ETHUSD")
     {
      if(IsSymbolFound("ETHUSD"))
         return("ETHUSD");

      else
         return(InpEthName);
     }


   if(sym=="GOLD" || sym=="XAU" || sym=="XAUUSD")
     {
      if(IsSymbolFound("XAUUSD"))
         return("XAUUSD");

      else
         return(InpGoldName);
     }


   if(sym=="US30")
     {
      if(IsSymbolFound("US30"))
         return("US30");

      else
         return(InpUS30Name);
     }

   if(sym=="NAS" || sym=="NAS100")
     {
      if(IsSymbolFound("NAS100"))
         return("NAS100");

      else
         return(InpNasName);
     }

   if(sym=="BTC" || sym=="BITCOIN" || sym=="BTCUSD")
     {
      if(IsSymbolFound("BTCUSD"))
         return("BTCUSD");

      else
         return(InpBTCName);
     }

   if(sym=="XRP" || sym=="XRPUSD")
     {
      if(IsSymbolFound("XRPUSD"))
         return("XRPUSD");

      else
         return(InpXRPName);
     }

   if(sym=="LTC" || sym=="LTCUSD")
     {
      if(IsSymbolFound("LTCUSD"))
         return("LTCUSD");

      else
         return(InpLTCName);
     }

   if(sym=="SOL" || sym=="SOLUSD")
     {
      if(IsSymbolFound("SOLUSD"))
         return("SOLUSD");

      else
         return(InpSOLName);
     }

   if(sym=="SPX500")
     {
      if(IsSymbolFound("SPX500"))
         return("SPX500");

      else
         return(InpSPX500Name);
     }


   return("Unknown Symbol");
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SymbolAlt(string sym, string &array[])
  {
   bool symtoupper = StringToUpper(sym);

   if(sym=="XAUUSD")
     {
      AddToArray(array, "GOLD");
     }

   return("Unknown Symbol");
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTP3()
  {

   for(int j=0; j<SymbolsTotal(true); j++)
     {
      string sym = SymbolName(j,true);

      if(SymbolTotal(sym)==0)
         continue;

      if(SymbolTotal(sym)==2)
        {
         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="3")
                  if(OrderMagicNumber()==InpMagicNumber)
                    {

                     if(OrderType()==OP_BUY)
                       {
                        if(OrderStopLoss() < OrderOpenPrice() && OrderProfit()>0)
                          {
                           bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                           // Log("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                          }
                       }

                     else
                        if(OrderType()==OP_SELL)
                          {
                           if(OrderStopLoss() > OrderOpenPrice() && OrderProfit()>0)
                             {
                              bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                              //  Log("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                             }
                          }
                    }


           }
        }

      if(SymbolTotal(sym)==1)
        {

         double newTP = 0;
         datetime closetime = 0;

         for(int i=0; i<OrdersHistoryTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="3")
                  if(OrderMagicNumber()==InpMagicNumber)
                     if(OrderCloseTime() > closetime)
                       {
                        newTP = OrderTakeProfit();
                       }
           }


         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="3")
                  if(OrderMagicNumber()==InpMagicNumber)
                    {

                     if(OrderType()==OP_BUY)
                       {
                        if(OrderStopLoss() < newTP && Bid - MarketInfo(OrderSymbol(),MODE_STOPLEVEL) > newTP)
                          {
                           bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),newTP,OrderTakeProfit(),0,clrNONE);
                           //   Log("SL on remaining trade on ",OrderSymbol()," now moved to TP1.");
                          }
                       }

                     else
                        if(OrderType()==OP_SELL)
                          {
                           if(OrderStopLoss() > newTP && Ask + MarketInfo(OrderSymbol(),MODE_STOPLEVEL) < newTP)
                             {
                              bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),newTP,OrderTakeProfit(),0,clrNONE);
                              //  Log("SL on remaining trade on ",OrderSymbol()," now moved to TP1.");
                             }
                          }

                    }
           }
        }
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTP2()
  {

   for(int j=0; j<SymbolsTotal(true); j++)
     {
      string sym = SymbolName(j,true);

      if(SymbolTotal(sym)==0)
         continue;

      if(SymbolTotal(sym)==1)
        {
         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
               if(OrderSymbol()==sym && StringSubstr(OrderComment(),0,1)=="2")
                  if(OrderMagicNumber()==InpMagicNumber)
                    {

                     if(OrderType()==OP_BUY)
                       {
                        if(OrderStopLoss() < OrderOpenPrice() && OrderProfit()>0)
                          {
                           bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                           // Log("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                          }
                       }

                     else
                        if(OrderType()==OP_SELL)
                          {
                           if(OrderStopLoss() > OrderOpenPrice() && OrderProfit()>0)
                             {
                              bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
                              //  Log("SL on remaining trades on ",OrderSymbol()," now moved to breakeven.");
                             }
                          }
                    }


           }
        }

     }

  }

//+------------------------------------------------------------------+
void AddToArray(string &array[], string value)
  {

   ArrayResize(array,ArraySize(array)+1,0);
   array[ArraySize(array)-1] = value;
  }
//+------------------------------------------------------------------+
void AddToArray(int &array[], int value)
  {

   ArrayResize(array,ArraySize(array)+1,0);
   array[ArraySize(array)-1] = value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddToArray(double &array[], double value)
  {
   ArrayResize(array,ArraySize(array)+1,0);
   array[ArraySize(array)-1] = value;
  }
//+------------------------------------------------------------------+
bool IsEntryMsg()
  {

   if(StringLen(Symbol_Name)>0 && Ordertype>=0 && Entry>0 && SL > 0 && ArraySize(TPs) > 0)
      return true;

   else
     {
      // Log("Not an entry message.");

      if(Ordertype > 0 && StringLen(Symbol_Name)>0)
         Log("Invalid signal format. Failed to retrieve at least one of entry price/stop loss/take profit values.");
     }


   return false;
  }
//+------------------------------------------------------------------+
string GetSymbol(string msg)
  {

   StringToUpper(msg);

   string symbol = "";


   for(int j=0; j<SymbolsTotal(true); j++)
     {
      string check = "";
      string name = SymbolName(j,true);

      for(int i=0; i<StringLen(msg); i++)
        {
         string cleanmsg = msg;
         StringReplace(cleanmsg,"/","");
         check = StringSubstr(cleanmsg,i,StringLen(name));

         if(check==name || VerifiedSymbol(check)==name)
           {
            symbol = name;
            break;
           }

        }

     }



   return symbol;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Breakeven(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);



   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               double point = SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
               double be_price = OrderType()==OP_BUY ? OrderOpenPrice()+(InpBEPoints*point) : OrderOpenPrice()-(InpBEPoints*point);

               //if( StringFind(OrderComment(),"from #")<0)
               //   continue;

               if(entry=="")
                 {
                  if(OrderProfit() > 0 && OrderStopLoss()!=be_price)
                    {
                     bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),be_price,OrderTakeProfit(),0,clrNONE);

                     if(!isBE)
                        Log("Failed to breakeven for ticket "+(string)OrderTicket()+". Error = "+(string)GetLastError());
                    }
                  else
                     if(OrderProfit() <= 0 && OrderStopLoss()!=be_price)
                        Log("Cannot breakeven for ticket "+(string)OrderTicket()+". Reason = ticket not in profit.");
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";


                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];





                  if(OrderProfit() > 0 && OrderStopLoss()!=be_price)
                    {
                     bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),be_price,OrderTakeProfit(),0,clrNONE);

                     if(!isBE)
                        Log("Failed to breakeven for ticket "+(string)OrderTicket()+". Error = "+(string)GetLastError());
                    }

                  else
                     if(OrderProfit() <= 0 && OrderStopLoss()!=be_price)
                        Log("Cannot breakeven for ticket "+(string)OrderTicket()+". Reason = ticket not in profit.");
                 }


              }


     }



  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BreakevenLoss(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);



   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               double point = SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
               double be_price = OrderType()==OP_BUY ? OrderOpenPrice()+(InpBEPoints*point) : OrderOpenPrice()-(InpBEPoints*point);

               //if( StringFind(OrderComment(),"from #")<0)
               //   continue;

               if(entry=="")
                 {
                  if(OrderProfit() > 0 && OrderStopLoss()!=be_price)
                    {
                     bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),be_price,OrderTakeProfit(),0,clrNONE);

                     if(!isBE)
                        Log("Failed to \"breakeven\" for losing ticket "+((string)OrderTicket())+". Error = "+(string)GetLastError());
                    }
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";


                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];

                  double ask = SymbolInfoDouble(OrderSymbol(),SYMBOL_ASK);
                  double bid = SymbolInfoDouble(OrderSymbol(),SYMBOL_BID);

                  int minStop = (int)SymbolInfoInteger(OrderSymbol(),SYMBOL_TRADE_STOPS_LEVEL);

                  string lastError = "";

                  if(OrderType()==OP_BUY)
                    {
                     if(OrderProfit() < 0 && OrderStopLoss()!=ask-PipsToPrice(InpBELossPips,OrderSymbol()))
                       {


                        bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),ask-PipsToPrice(InpBELossPips,OrderSymbol()),OrderTakeProfit(),0,clrNONE);

                        lastError = (string)GetLastError();

                        if(!isBE)
                          {
                           Log("Failed to \"breakeven\" for losing ticket "+(string)OrderTicket()+". Error = "+lastError);

                           if(lastError == "130")
                              Log("Pip value set for \"breakeven\" for loss trades ("+(string)InpBELossPips+") is less than minimum allowed for "+Symbol_Name);
                          }
                       }
                    }

                  else
                     if(OrderType()==OP_SELL)
                       {
                        if(OrderProfit() < 0 && OrderStopLoss()!=bid+PipsToPrice(InpBELossPips,OrderSymbol()))
                          {

                           bool isBE = OrderModify(OrderTicket(),OrderOpenPrice(),bid+PipsToPrice(InpBELossPips,OrderSymbol()),OrderTakeProfit(),0,clrNONE);

                           lastError = (string)GetLastError();

                           if(!isBE)
                             {
                              Log("Failed to \"breakeven\" for losing ticket "+(string)OrderTicket()+". Error = "+lastError);

                              if(lastError == "130")
                                 Log("Pip value set for \"breakeven\" for loss trades ("+(string)InpBELossPips+") is less than minimum allowed for "+Symbol_Name);
                             }
                          }
                       }
                 }


              }


     }



  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveSL(string symbol, string entry="")
  {

   string msg = "";

   int cnt = 0;

   StringToUpper(msg);




   for(int i=0; i<OrdersTotal(); i++)
     {
      string entryprice = "";

      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               if(entry=="")
                 {
                  bool isRS = OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),0,clrNONE);

                  if(isRS)
                     cnt++;
                 }

               else
                 {

                  string parts[];


                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];

                  bool isRS = false;

                  if(StringFind(entry,entryprice)>=0)
                     isRS = OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),0,clrNONE);

                  if(isRS)
                     cnt++;
                 }

              }

     }



  }
//+------------------------------------------------------------------+
void CloseTrade(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);




   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {

               int ticket = OrderTicket();string id = GetTicketID(ticket);if(id != LastMsgID)continue;

               

               
                  

               bool isClosed = false;

               if(entry=="")
                 {
                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                  if(!isClosed)
                     Log("Failed to close trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];





                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                  if(!isClosed)
                     Log("Failed to close trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());

                 }



              }

     }



  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseNearTPTrade(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);




   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               double ask = SymbolInfoDouble(Symbol_Name,SYMBOL_ASK);
               double bid = SymbolInfoDouble(Symbol_Name,SYMBOL_BID);

               if(OrderType()==OP_BUY)
                 {

                  double tpdist   = OrderTakeProfit() - OrderOpenPrice();
                  double neardist = OrderOpenPrice()  + 0.5*tpdist;

                  // Print("50% TP price is ",neardist);

                  if(ask < neardist)
                    {
                     Log("Ticket #"+(string)OrderTicket()+" cannot be closed. Not at least 50% of TP distance yet.");
                     continue;
                    }
                 }

               else
                  if(OrderType()==OP_SELL)
                    {

                     double tpdist   = OrderOpenPrice() - OrderTakeProfit();
                     double neardist = OrderOpenPrice()  - 0.5*tpdist;

                     // Print("50% TP price is ",neardist);

                     if(bid > neardist)
                       {
                        Log("Ticket #"+(string)OrderTicket()+" cannot be closed. Not at least 50% of TP distance yet.");
                        continue;
                       }
                    }

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               bool isClosed = false;

               if(entry=="")
                 {
                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                  if(!isClosed)
                     Log("Failed to close 50-75% profit trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());
                  else
                     Log("Successfully closed 50-75% profit trade on "+Symbol_Name+" from "+Sender);
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];





                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                  if(!isClosed)
                     Log("Failed to close 50-75% profit trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());
                  else
                     Log("Successfully closed 50-75% profit trade on "+Symbol_Name+" from "+Sender);

                 }



              }

     }



  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitTrade(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);




   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               if(OrderProfit() < 0)
                  continue;

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               bool isClosed = false;

               if(entry=="")
                 {
                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                  if(!isClosed)
                     Log("Failed to close trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];





                  if(OrderType() <= 1)
                     isClosed = OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),10,clrNONE);
                  else
                     isClosed = OrderDelete(OrderTicket(),clrNONE);

                  if(!isClosed)
                     Log("Failed to close trade on "+Symbol_Name+" from "+Sender+". Error = "+(string)GetLastError());

                 }



              }

     }



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseHalf(string symbol, string entry="")
  {

   string msg = "";

   StringToUpper(msg);

   int modtotal = 0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               // if(StringFind(OrderComment(),Sender)<0)
               //    continue;

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               double lot = 0;

               if(entry=="")
                 {


                  int pClosed = PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(InpPCPerc*0.01*OrderLots(),OrderSymbol()),InpMagicNumber);
                  modtotal++;

                  if(pClosed > 0)
                     Log("New ticket generated = "+(string)pClosed);

                  else
                     Log("Partial close failed for ticket #"+(string)OrderTicket()+". Error = "+(string)GetLastError());

                  AddToArray(IDs,LastMsgID+","+(string)pClosed);

                 }

               else
                 {

                  int pClosed = PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(InpPCPerc*0.01*OrderLots(),OrderSymbol()),InpMagicNumber);

                  if(pClosed > 0)
                     Log("New ticket generated = "+(string)pClosed);

                  else
                     Log("Partial close failed for ticket #"+(string)OrderTicket()+". Error = "+(string)GetLastError());

                  AddToArray(IDs,LastMsgID+","+(string)pClosed);

                  /*string entryprice = "";

                  string parts[];

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>1)
                     lot = StringToDouble(parts[1]);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];

                  if(OrderLots()==lot)
                    {
                     int pClosed = PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(InpPCPerc*0.01*OrderLots()),InpMagicNumber);
                     modtotal++;
                    }*/
                 }


              }

     }





  }
//+------------------------------------------------------------------+
int SymbolTotal(string symbol, string entry="")
  {

   int cnt = 0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(StringFind(entry,entryprice)>=0)
                  cnt++;
              }
     }

   return cnt;
  }
//+------------------------------------------------------------------+
int PartialOrderClose(int TicketID, double ClosePrice, double LotSize, int EA_MagicNumber)
  {

   int initTickets[];

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         //  if(OrderMagicNumber()==InpMagicNumber)
        {
         int thisTicket = OrderTicket();
         AddToArray(initTickets,thisTicket);
        }
     }


   if(OrderSelect(TicketID,SELECT_BY_TICKET))
     {
      bool pc = OrderClose(TicketID,LotSize,OrderClosePrice(),10,clrNONE);

      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS))
            if(OrderMagicNumber()==InpMagicNumber)
              {
               int thisTicket = OrderTicket();

               if(!IsFound(thisTicket,initTickets))
                  return thisTicket;
              }
        }
     }

   return (0);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CheckError()
  {

   if(StringLen(Symbol_Name)==0)
      Log("Symbol could not be extracted from signal. Please check signal.");

   if(Entry==0)
      Log("Entry price could not be extracted from signal. Please check signal.");

   if(SL==0)
      Log("SL price could not be extracted from signal. Please check signal.");

   if(ArraySize(TPs)==0)
      Log("TP prices could not be extracted from signal. Please check signal.");

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeTP(string symbol, string entry="")
  {
   string msg = "";

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               //  if( StringFind(OrderComment(),"from #")<0)
               //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];


               if(StringFind(msg,"CHANGE")>=0 && StringFind(msg,"TP1")>=0)
                  if(OrderTakeProfit()==TPs[0])
                    {

                     Log("TP1 ticket found: "+ (string)OrderTakeProfit()+" "+(string)TPs[0]);

                     StringReplace(msg,"CHANGE","");
                     StringReplace(msg,"TP1","");

                     char msg2arr[];

                     StringToCharArray(msg,msg2arr);

                     for(int k=0; k<ArraySize(msg2arr); k++)
                       {
                        if(!IsFound(CharToString(msg2arr[k]),PriceChars))
                           StringReplace(msg,CharToString(msg2arr[k]),"");
                       }

                     if(StringSubstr(msg,StringLen(msg)-1,1)==".")
                        msg = StringSubstr(msg,0,StringLen(msg)-2);


                     bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),StringToDouble(msg),0,clrNONE);

                    }



              }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeSL(string symbol, string entry, double price=0)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               // if( StringFind(OrderComment(),"from #")<0)
               //    continue;

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               if(entry=="")
                 {
                  bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0,clrNONE);
                 }

               else
                 {
                  string parts[];

                  string entryprice = "";

                  StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

                  if(ArraySize(parts)>2)
                     entryprice = parts[2];


                  bool isMod = OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0,clrNONE);

                 }

              }
     }
  }
//+------------------------------------------------------------------+
void GetTickets(string symbol, string entry, int &array[])
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               string parts[];

               string entryprice = "";

               double tp = OrderTakeProfit();

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(StringFind(entry,entryprice)>=0)
                  AddToArray(array,OrderTicket());
              }
     }



  }
//+------------------------------------------------------------------+
double GetNewSL(string msg, bool cond)
  {

   StringToUpper(msg);

   if(cond)
     {
      string pMsg = msg;

      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"SL","");
      StringReplace(pMsg,"STOPLOSS","");
      StringReplace(pMsg,"STOP LOSS","");

      double tp1 = 0;
      double tp2 = 0;
      double tp3 = 0;

      if(ArraySize(TPs)>0)
         tp1 = TPs[0];

      if(ArraySize(TPs)>1)
         tp2 = TPs[1];

      if(ArraySize(TPs)>2)
         tp3 = TPs[2];

      if(StringFind(pMsg,"TP1")>=0)
         return tp1;

      else
         if(StringFind(pMsg,"TP2")>=0)
            return tp2;

         else
            if(StringFind(pMsg,"TP3")>=0)
               return tp3;

            else
              {

               string parts[];

               StringSplit(pMsg,StringGetCharacter(" ",0),parts);



               double newSL = 0;

               if(ArraySize(parts)>0)
                 {
                  char pmsg[];

                  StringToCharArray(pMsg,pmsg);

                  for(int k=0; k<ArraySize(pmsg); k++)
                    {
                     if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
                        StringReplace(pMsg,CharToString(pmsg[k]),"");
                    }

                  pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
                  StringTrimLeft(StringTrimRight(pMsg));

                  if(StringToDouble(pMsg)>0)
                     newSL = StringToDouble(pMsg);
                 }

               return StringToDouble(pMsg);

              }
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//TP1
double GetNewTP1(string msg, bool cond)
  {

   StringToUpper(msg);

   if(cond)
     {

      char msg2arr[];

      string pMsg = msg;

      StringReplace(pMsg,"TP 1 ","TP1 ");
      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"TP1","");

      StringReplace(pMsg,"TAKEPROFIT 1","");
      StringReplace(pMsg,"TAKE PROFIT 1","");

      StringToCharArray(pMsg,msg2arr);

      string parts[];

      StringTrimLeft(StringTrimRight(pMsg));

      StringSplit(pMsg,StringGetCharacter(" ",0),parts);



      double newTP = 0;

      if(ArraySize(parts)>0)
        {
         char pmsg[];

         StringToCharArray(pMsg,pmsg);

         for(int k=0; k<ArraySize(pmsg); k++)
           {
            if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
               StringReplace(pMsg,CharToString(pmsg[k]),"");
           }

         pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
         StringTrimLeft(StringTrimRight(pMsg));

         if(StringToDouble(pMsg)>0)
            newTP = StringToDouble(pMsg);
        }


      return newTP;
     }

   return 0;
  }
//+------------------------------------------------------------------+
void ChangeTP1(string symbol, string entry="", double newTP=0, string lastMsg="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               // if( StringFind(OrderComment(),"from #")<0)
               //    continue;

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               double groupTps[];


               double openPrice = OrderOpenPrice();
               double stopLoss = OrderStopLoss();

               datetime opentime = OrderOpenTime();

               string sym = OrderSymbol();
               double tp  = OrderTakeProfit();

               GetGroupTPs(opentime, sym, groupTps);

               ArraySort(groupTps);

               //   Log("Order TP is ",tp);
               //   Log("groupTPs[0] is ",groupTps[0]);
               //   Log("Symbol is ",symbol);


               if(StringFind(lastMsg,"TP1") >= 0 && ArraySize(groupTps)>0)
                 {
                  if(tp==groupTps[0])
                    {
                     bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                    }
                 }

               else
                  if(StringFind(lastMsg,"TP2") >= 0 && ArraySize(groupTps)>1)
                    {
                     if(tp==groupTps[1])
                       {
                        bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                       }
                    }

                  else
                     if(StringFind(lastMsg,"TP3") >= 0 && ArraySize(groupTps)>2)
                       {
                        if(tp==groupTps[2])
                          {
                           bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                          }
                       }

                     else
                        if(StringFind(lastMsg,"TP4") >= 0 && ArraySize(groupTps)>3)
                          {
                           if(tp==groupTps[3])
                             {
                              bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                             }
                          }

                        else
                           if(StringFind(lastMsg,"TP5") >= 0 && ArraySize(groupTps)>4)
                             {
                              if(tp==groupTps[4])
                                {
                                 bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                                }
                             }
                           else
                             {
                              if(tp==groupTps[0] && ArraySize(groupTps)>0)
                                {
                                 // Log("Single TP order.");
                                 bool mod = OrderModify(ticket,openPrice,stopLoss,newTP,0,clrNONE);
                                }
                             }


              }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTP1(string symbol, string entry="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               // if( StringFind(OrderComment(),"from #")<0)
               //    continue;

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               double groupTps[];


               double openPrice = OrderOpenPrice();
               double stopLoss = OrderStopLoss();

               datetime opentime = OrderOpenTime();

               string sym = OrderSymbol();
               double tp  = OrderTakeProfit();

               double closePrice = OrderClosePrice();

               double lots = OrderLots();

               GetGroupTPs(opentime, sym, groupTps);

               if(OrderType()==OP_BUY)
                  ArraySort(groupTps);

               else
                  if(OrderType()==OP_SELL)
                     ArraySort(groupTps,WHOLE_ARRAY,0,MODE_DESCEND);



               //Log("Order TP is ",tp);
               //Log("groupTPs[0] is ",groupTps[0]);
               //   Log("Symbol is ",symbol);


               if(ArraySize(groupTps)>0)
                 {
                  if(tp==groupTps[0])
                    {
                     bool isClosed = OrderClose(ticket,lots,closePrice,10);
                    }
                 }

              }
     }


  }
//+------------------------------------------------------------------+
//TP2
double GetNewTP2(string msg)
  {

   StringToUpper(msg);

   if(StringFind(msg,"CHANGE TP2")>=0)
     {

      char msg2arr[];

      string pMsg = msg;

      StringReplace(pMsg,"TP 2 ","TP2 ");
      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"TP2","");

      StringReplace(pMsg,"TAKEPROFIT 2","");
      StringReplace(pMsg,"TAKE PROFIT 2","");

      StringToCharArray(pMsg,msg2arr);

      string parts[];

      StringTrimLeft(StringTrimRight(pMsg));

      StringSplit(pMsg,StringGetCharacter(" ",0),parts);

      double newTP = 0;

      if(ArraySize(parts)>0)
        {
         char pmsg[];

         StringToCharArray(pMsg,pmsg);

         for(int k=0; k<ArraySize(pmsg); k++)
           {
            if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
               StringReplace(pMsg,CharToString(pmsg[k]),"");
           }

         pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
         StringTrimLeft(StringTrimRight(pMsg));

         if(StringToDouble(pMsg)>0)
            newTP = StringToDouble(pMsg);
        }


      return newTP;
     }

   return 0;
  }
//+------------------------------------------------------------------+
void ChangeTP2(string symbol, string entry="", double tp=0)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               // if( StringFind(OrderComment(),"from #")<0)
               //    continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="2")
                 {
                  bool mod = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
                 }

              }
     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTP2(string symbol, string entry="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               //   if( StringFind(OrderComment(),"from #")<0)
               //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="2")
                 {
                  bool closed = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);
                 }

              }
     }

  }

//TP3
double GetNewTP3(string msg)
  {

   StringToUpper(msg);

   if(StringFind(msg,"CHANGE TP3")>=0)
     {

      char msg2arr[];

      string pMsg = msg;

      StringReplace(pMsg,"TP 3 ","TP3 ");
      StringReplace(pMsg,"CHANGE","");
      StringReplace(pMsg,"TP3","");

      StringReplace(pMsg,"TAKEPROFIT 3","");
      StringReplace(pMsg,"TAKE PROFIT 3","");

      StringToCharArray(pMsg,msg2arr);

      string parts[];

      StringTrimLeft(StringTrimRight(pMsg));

      StringSplit(pMsg,StringGetCharacter(" ",0),parts);

      double newTP = 0;

      if(ArraySize(parts)>0)
        {
         char pmsg[];

         StringToCharArray(pMsg,pmsg);

         for(int k=0; k<ArraySize(pmsg); k++)
           {
            if(!IsFound(CharToString(pmsg[k]),PriceChars) && CharToString(pmsg[k])!=" ")
               StringReplace(pMsg,CharToString(pmsg[k]),"");
           }

         pMsg = StringSubstr(pMsg,0,StringFind(pMsg," "));
         StringTrimLeft(StringTrimRight(pMsg));

         if(StringToDouble(pMsg)>0)
            newTP = StringToDouble(pMsg);
        }


      return newTP;
     }

   return 0;
  }
//+------------------------------------------------------------------+
void ChangeTP3(string symbol, string entry="", double tp=0)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               //   if( StringFind(OrderComment(),"from #")<0)
               //     continue;

               string parts[];

               string entryprice = "";

               StringSplit(OrderComment(),StringGetCharacter(",",0),parts);

               if(ArraySize(parts)>2)
                  entryprice = parts[2];

               if(parts[0]=="3")
                 {
                  bool mod = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
                 }

              }
     }


  }
//+------------------------------------------------------------------+
void CloseTP3(string symbol, string entry="")
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
              {
               // if( StringFind(OrderComment(),"from #")<0)
               //    continue;

               int ticket = OrderTicket();

               string id = GetTicketID(ticket);

               // Log("Ticket ID is ",id);

               // Log("Last message ID is ",LastMsgID);

               if(id != LastMsgID)
                  continue;

               double groupTps[];


               double openPrice = OrderOpenPrice();
               double stopLoss = OrderStopLoss();

               datetime opentime = OrderOpenTime();

               string sym = OrderSymbol();
               double tp  = OrderTakeProfit();

               double closePrice = OrderClosePrice();

               double lots = OrderLots();

               GetGroupTPs(opentime, sym, groupTps);

               if(OrderType()==OP_BUY)
                  ArraySort(groupTps);

               else
                  if(OrderType()==OP_SELL)
                     ArraySort(groupTps,WHOLE_ARRAY,0,MODE_DESCEND);

               // Log("Order TP is ",tp);
               // Log("groupTPs[-1] is ",groupTps[ArraySize(groupTps)-1]);
               //   Log("Symbol is ",symbol);


               if(ArraySize(groupTps)>0)
                 {
                  if(tp==groupTps[ArraySize(groupTps)-1])
                    {
                     bool isClosed = OrderClose(ticket,lots,closePrice,10);
                    }
                 }

              }
     }



  }
//+------------------------------------------------------------------+
double GetLots(double riskPoints)
  {
   if(!IsSymbolFound(Symbol_Name))
      return 0;

   double Balance     = AccountInfoDouble(ACCOUNT_BALANCE);
   double pointValue  = PointValue(Symbol_Name);
   double moneyAtRisk = (InpRiskPerc/100)*Balance;
   riskPoints         = riskPoints/SymbolInfoDouble(Symbol_Name,SYMBOL_POINT);

   double Lots        = moneyAtRisk/(pointValue*riskPoints);

   return FormatLot(Lots,Symbol_Name);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetRiskAmount(double riskPoints, double lots)
  {
   double pointValue  = PointValue(Symbol_Name);
   riskPoints         = riskPoints/SymbolInfoDouble(Symbol_Name,SYMBOL_POINT);




   double moneyAtRisk = lots*pointValue*riskPoints;

//if(StringFind(sym,"XAUUSD") >= 0 || IsFound(Symbol_Name,GoldNames))
// moneyAtRisk = moneyAtRisk*1000;
// Log("Money at risk is ",moneyAtRisk);

   return moneyAtRisk;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceToPoints(double price, string symbol) //Use info of size of a pip to convert SL and TP to Price
  {
   return(price/_Point);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointValue(string symbol)
  {
   if(!IsSymbolFound(Symbol_Name))
      return 0;

   double tickSize = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double point     = SymbolInfoDouble(symbol,SYMBOL_POINT);

   /*string sym = Symbol_Name;

   StringToUpper(sym);

    if(StringFind(sym,"XAUUSD") >= 0 || IsFound(Symbol_Name,GoldNames))
      point = point*10;*/

   double ticksPerPoint = tickSize/point;
   double pointValue = tickValue/ticksPerPoint;




   return(pointValue);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FormatLot(double dlots, string sym)
  {

   double min,max,step,lots;
   int lotdigits = 1;

   step = MarketInfo(sym,MODE_LOTSTEP);

   if(step==0.01)
      lotdigits=2;

   if(step==0.1)
      lotdigits=1;

   lots = StrToDouble(DoubleToStr(dlots,lotdigits));

   min  = MarketInfo(sym,MODE_MINLOT);

   if(lots<min)
      return(min);


   max=MarketInfo(sym,MODE_MAXLOT);

   if(lots>max)
      return(max);

   return(lots);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PipSize(string symbol) //Get Size of a pip in the selected symbol
  {

   double point  =  MarketInfo(symbol,MODE_POINT);
   int    digits = (int)MarketInfo(symbol,MODE_DIGITS);

   double pipsize = (IsFound(symbol,GoldNames)&& (digits%2)==0) /*|| (IsFound(symbol,SilverNames) && (digits%2)==0)*/ || (IsCurrPair(symbol) && (digits%2)==1) ? point*10 :
                    (IsFound(symbol,GoldNames)&& (digits%2)==1) /*|| (IsFound(symbol,SilverNames) && (digits%2)==1)*/ ? point*100 :
                    (IsCurrPair(symbol) && (digits%2)==0) ? point:
                    1;

   return(pipsize);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PipsToPrice(double pips, string symbol) //Use info of size of a pip to convert SL and TP to Price
  {

   double PriceInPips = pips * PipSize(symbol);

   return(PriceInPips);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceToPips(double price, string symbol) //Use info of size of a pip to convert SL and TP to Price
  {
   int    digits = (int)MarketInfo(symbol,MODE_DIGITS);
   double pips = price / PipSize(symbol);

   return((digits%2)==1 ? pips*10 : PointValue(symbol) != 1 ? pips*PointValue(symbol) : (pips*PointValue(symbol))/10) ;
  }
//+------------------------------------------------------------------+
int GetToday()
  {

   datetime now = TimeCurrent();

   MqlDateTime t2s;

   TimeToStruct(now,t2s);

   return(t2s.day_of_week);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetNearestCloseDay()
  {

   datetime day = TimeCurrent();

   MqlDateTime t2s;

   TimeToStruct(day,t2s);

   int daysToClose = t2s.day_of_week - (InpShutdownDay + 1);

   if(daysToClose < 0)
     {
      return(StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpShutdownTime) + -(daysToClose*86400));
     }

   else
      if(daysToClose > 0)
        {
         return(StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpShutdownTime) - (daysToClose*86400));
        }

      else
         return(StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpShutdownTime));


   return(-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetNearestOpenDay()
  {

   datetime day = TimeCurrent();

   datetime openday = 0;

   MqlDateTime t2s;

   TimeToStruct(day,t2s);

   int daysToClose = t2s.day_of_week - (InpRestartDay + 1);

   if(daysToClose < 0)
     {
      openday = (StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpRestartTime) + -(daysToClose*86400));
     }

   else
      if(daysToClose > 0)
        {
         openday = (StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpRestartTime) - (daysToClose*86400));
        }

      else
         openday = (StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+InpRestartTime));

// if(openday < GetNearestCloseDay())
//  openday = openday + (7*86400);

   return(openday);
  }
//+------------------------------------------------------------------+
string DayToString(int day)
  {

   string d2s = "";

   switch(day)
     {
      case 0:
         d2s = "Sunday";
         break;
      case 1:
         d2s = "Monday";
         break;
      case 2:
         d2s = "Tuesday";
         break;
      case 3:
         d2s = "Wednesday";
         break;
      case 4:
         d2s = "Thursday";
         break;
      case 5:
         d2s = "Friday";
         break;
      case 6:
         d2s = "Saturday";
         break;
      default:
         break;
     }

   return d2s;
  }
//+------------------------------------------------------------------+
void ModifySL()
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
            if(OrderType() <= OP_SELL)
              {

               if(FileIsExist(OrderSymbol()+"_lasttickets.txt"))
                 {
                  double open = OrderOpenPrice();

                  string symbol = OrderSymbol();

                  datetime openTime = OrderOpenTime();

                  double tps[];

                  AddToArray(tps,open);

                  int handle      = FileOpen(OrderSymbol()+"_lasttickets.txt",FILE_READ);

                  if(handle==INVALID_HANDLE)
                     Log("Failed to read last set of tickets for, "+OrderSymbol()+", "+(string)GetLastError());

                  string info = FileReadString(handle);

                  string parts[];

                  StringSplit(info,StringGetCharacter(",",0),parts);

                  for(int j=1; j<ArraySize(parts); j++)
                    {
                     AddToArray(tps,(double)(parts[j]));
                    }


                  FileClose(handle);


                  if(OrderType()==OP_BUY)
                    {
                     ArraySort(tps);

                     // Log("TP array is: ",ArrayToString(tps));


                     if(ArraySize(tps) >= 4)
                       {
                        if(IsTicketClosed(symbol,tps[1]))
                           ModifyGroup(symbol,openTime,0,false);

                        /*if(IsTicketClosed(symbol,tps[2]))
                           ModifyGroup(symbol,openTime,tps[1]);

                        if(IsTicketClosed(symbol,tps[3]))
                           ModifyGroup(symbol,openTime,tps[2]);

                        if(ArraySize(tps) >= 5 && IsTicketClosed(symbol,tps[4]))
                           ModifyGroup(symbol,openTime,tps[3]);

                        if(ArraySize(tps) >= 6 && IsTicketClosed(symbol,tps[5]))
                           ModifyGroup(symbol,openTime,tps[4]);

                        if(ArraySize(tps) >= 7 && IsTicketClosed(symbol,tps[6]))
                           ModifyGroup(symbol,openTime,tps[5]);*/
                       }



                    }

                  else
                     if(OrderType()==OP_SELL)
                       {

                        ArraySort(tps,WHOLE_ARRAY,0,MODE_DESCEND);

                        ArraySetItemAsFirst(open,tps);

                        // Log("TP array is: ",ArrayToString(tps));

                        if(ArraySize(tps) >= 4)
                          {
                           if(IsTicketClosed(symbol,tps[1]))
                              ModifyGroup(symbol,openTime,0,false);

                           /*if(IsTicketClosed(symbol,tps[2]))
                              ModifyGroup(symbol,openTime,tps[1]);

                           if(IsTicketClosed(symbol,tps[3]))
                              ModifyGroup(symbol,openTime,tps[2]);

                           if(ArraySize(tps) >= 5 && IsTicketClosed(symbol,tps[4]))
                              ModifyGroup(symbol,openTime,tps[3]);

                           if(ArraySize(tps) >= 6 && IsTicketClosed(symbol,tps[5]))
                              ModifyGroup(symbol,openTime,tps[4]);

                           if(ArraySize(tps) >= 7 && IsTicketClosed(symbol,tps[6]))
                              ModifyGroup(symbol,openTime,tps[5]);*/
                          }

                       }

                 }

              }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
           {
            bool isClosed = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);

            if(!isClosed)
               bool isDeleted = OrderDelete(OrderTicket());
           }
     }
  }
//+------------------------------------------------------------------+
void CloseOnDD()
  {

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   double maxDD   = InpMaxDD < 0 ? InpMaxDD : -InpMaxDD;

   if(equity - balance <= (maxDD/100)*balance)
     {
      CloseAll();
      Log("Maximum drawdown of -$"+(string)InpMaxDD+" hit. All trades now closed.");
     }
  }
//+------------------------------------------------------------------+
void WriteEntry(string name, string text)
  {

   int handle = FileOpen(name,FILE_WRITE);

   if(handle==INVALID_HANDLE)
     {
      Log("Failed to write entry "+name+", error="+(string)GetLastError());
      return;
     }

   FileWriteString(handle,text);
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Download()
  {

   int timeout = 2000;

   string lastMsg = "";

   resu = WebRequest("GET",file_url,cookie,NULL,timeout,post,0,results,headers);

   string msg = CharArrayToString(results);


   if(resu != 200)
      return(-1);

   int handle = FileOpen("News.csv",FILE_WRITE | FILE_BIN);

   if(handle==INVALID_HANDLE)
     {

      int mError = GetLastError();
      PrintFormat("%s error %i opening file %s",__FUNCTION__,mError,"\\Test");
      return(-1);

     }



   FileWriteArray(handle,results,0,ArraySize(results));
   FileFlush(handle);
   FileClose(handle);

// Comment(resu);

   return(resu);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeTo24h(string time)
  {

   string t = time;

   StringToUpper(t);

   if(StringFind(t,"AM") >= 0)
     {
      StringReplace(t,"AM","");

      if(StringFind(t,"12:00") >= 0)
         return "00:00";

      if(StringLen(t) < 5)
         t = "0"+t;

      return t;
     }

   else
      if(StringFind(t,"PM") >= 0)
        {
         string parts[];
         StringSplit(t,StringGetCharacter(":",0),parts);

         if(ArraySize(parts) ==0)
            return "";

         int hour = (int)parts[0]+12 < 24 ? (int)parts[0]+12 : (int)parts[0];


         StringReplace(parts[1],"PM","");

         if(hour < 10 && StringSubstr(t,0,1) != "0")
            return "0"+(string)hour+":"+parts[1];

         else
            return (string)hour+":"+parts[1];
        }

   return "";
  }
//+------------------------------------------------------------------+
void DisplayNews()
  {

   for(int i=ObjectsTotal(0,-1,-1)-1; i>=0; i--)
     {
      string name = ObjectName(0,i);

      if(StringFind(name,"NEWS") >= 0)
         ObjectDelete(0,name);
     }


   string News[];

   int handle = FileOpen("News.csv",FILE_READ);

   if(handle==INVALID_HANDLE)
     {
      int mError = GetLastError();
      PrintFormat("%s error %i opening file %s",__FUNCTION__,mError,"\\Test");
      return;
     }

   while(!FileIsEnding(handle))
     {
      AddToArray(News,FileReadString(handle));
     }

   FileClose(handle);

   int ypos = 290;


   objectCreate(OBJ_LABEL,"NEWS TITLE",50,250,100,100,"NEWS LINEUP FOR "+TimeToString(TimeCurrent(),TIME_DATE),16777215,16777215,White,10);
   objectCreate(OBJ_LABEL,"NEWS BREAK",50,270,100,100,"==============================",16777215,16777215,White,10);

   for(int i=0; i<ArraySize(News); i++)
     {
      bool checkhigh   = InpHighImpact==true ? (StringFind(News[i],"HIGH") >= 0 || StringFind(News[i],"High") >= 0) : false;
      bool checkmedium = InpMediumImpact==true ? (StringFind(News[i],"MEDIUM") >= 0 || StringFind(News[i],"Medium") >= 0) : false;
      bool checklow    = InpLowImpact==true ? (StringFind(News[i],"LOW") >= 0 || StringFind(News[i],"Low") >= 0) : false;



      string parts[];

      StringSplit(today,StringGetCharacter(".",0),parts);

      if(ArraySize(parts) == 0)
         return;

      today = "";

      today += parts[1]+"-"+parts[2]+"-"+parts[0];

      if(StringFind(News[i],today) < 0 || (!checkhigh && !checkmedium && !checklow))
         continue;

      color textColor = checkhigh ? OrangeRed : checkmedium ? Orange : Gray;

      objectCreate(OBJ_LABEL,"NEWS"+(string)(i+1),50,ypos,100,100,News[i],16777215,16777215,textColor);

      ypos += 20;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objectCreate(ENUM_OBJECT type, string name, int xpos, int ypos, int xsize, int ysize, string text="", color pbgcolor=White, color pbordercolor=White, color pcolor=OrangeRed, int fontsize=8, int corner=4)
  {

   ObjectCreate(0, name, type, 0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,xpos);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,ypos);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,xsize);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,ysize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,pcolor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR,pbordercolor);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,pbgcolor);
   ObjectSetInteger(0, name, OBJPROP_CORNER,corner);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,fontsize);

  }
//+------------------------------------------------------------------+
bool IsTicketClosed(string symbol,double tp)
  {

   bool isClosed = false;

   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if(OrderTakeProfit()==tp)
                 {
                  isClosed = true;
                  break;
                 }
     }


   return isClosed;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyGroup(string symbol, datetime opentime, double newSL=0, bool closePartial=false)
  {


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if((int)MathAbs(iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime()) - iBarShift(OrderSymbol(),PERIOD_M1,opentime)) <= 1)
                 {
                  if(newSL==0)
                     newSL = OrderOpenPrice();

                  if(OrderType()==OP_BUY && OrderStopLoss() < newSL)
                    {
                     bool isMOD = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrNONE);

                     if(closePartial==true)
                       {
                        if(PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(0.5*OrderLots(),OrderSymbol()),OrderMagicNumber())==0)
                           Log("Failed to close partial. Error = "+(string)GetLastError());
                       }
                    }

                  if(OrderType()==OP_SELL && OrderStopLoss() > newSL)
                    {
                     bool isMOD = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrNONE);

                     if(closePartial==true)
                       {
                        if(PartialOrderClose(OrderTicket(),OrderClosePrice(),FormatLot(0.5*OrderLots(),OrderSymbol()),OrderMagicNumber())==0)
                           Log("Failed to close partial. Error = "+(string)GetLastError());
                       }
                    }
                 }
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetGroupTPs(datetime ticketOpenTime, string symbol, double &tps[])
  {


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if(((int)MathAbs(iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime()) - iBarShift(OrderSymbol(),PERIOD_M1,ticketOpenTime)) <= 1) || OrderComment()==Sender)
                 {
                  if(!IsFound(OrderTakeProfit(),tps))
                    {
                     AddToArray(tps,OrderTakeProfit());
                    }
                 }
     }

   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==symbol)
            if(OrderMagicNumber()==InpMagicNumber)
               if(((int)MathAbs(iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime()) - iBarShift(OrderSymbol(),PERIOD_M1,ticketOpenTime)) <= 1) || OrderComment()==Sender)
                 {
                  if(!IsFound(OrderTakeProfit(),tps))
                    {
                     AddToArray(tps,OrderTakeProfit());
                    }
                 }
     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArraySetItemAsFirst(double elem, double &array[])
  {

   double temparray[];

   for(int i=0; i<ArraySize(array); i++)
     {
      if(array[i] != elem)
         AddToArray(temparray,array[i]);
     }

   ArrayFree(array);
   AddToArray(array,elem);

   for(int j=0; j<ArraySize(temparray); j++)
     {
      AddToArray(array,temparray[j]);
     }
  }
//+------------------------------------------------------------------+
string Request(string subdirectory)
  {

   int timeout = 10000;

   string url = BASE_URL+"/"+subdirectory;

   resu = WebRequest("GET",url,cookie,NULL,timeout,post,0,results,headers);

   return CharArrayToString(results);
  }
//+------------------------------------------------------------------+
void CreateLabels()
  {
   objectCreate(OBJ_LABEL,"website",500,0,0,0,"www.telecopierz.com",Yellow,Yellow,Yellow,20);
   objectCreate(OBJ_LABEL,"telegram",530,40,0,0,"contact t.me/ask2admin",White,White,White,14);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objectCreate(string name, int xpos, int ypos, int xsize, int ysize, ENUM_OBJECT type=OBJ_RECTANGLE_LABEL,string text="")
  {

   ObjectCreate(0,name,type,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xpos);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,ypos);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xsize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ysize);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,Yellow);

   if(type==OBJ_LABEL)
     {
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_FONT,"Verdana");
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsCurrPair(string symbol)
  {


   int cnt = 0;

   for(int i=0; i<ArraySize(Currencies); i++)
     {
      if(StringFind(symbol,Currencies[i]) >= 0)
         cnt++;
     }


   bool isOil = false;

   char m2a[];

   int suffixPos = -1;

   StringToCharArray(symbol,m2a);

   for(int k=0; k<ArraySize(m2a); k++)
     {
      if(CharToString(m2a[k])=="." || CharToString(m2a[k])=="-")
        {
         suffixPos = k;
         break;
        }
     }

   string withoutSuffix = "";

   if(suffixPos >= 0)
     {

      withoutSuffix = StringSubstr(symbol,0,suffixPos);

      // Log("Without suffix is ",withoutSuffix);

      if(IsFound(withoutSuffix,USOilNames) || IsFound(withoutSuffix,UKOilNames))
        {
         isOil = true;
        }
     }



   if(cnt >= 2 || isOil)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BEPips()
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
           {

            double bepoint = 0;
            double open = OrderOpenPrice();
            string symbol = OrderSymbol();
            double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
            double bid = SymbolInfoDouble(symbol,SYMBOL_BID);

            bool isBE = false;

            if(OrderType()==OP_BUY)
              {
               bepoint = OrderOpenPrice()+PipsToPrice(InpPipBE,symbol);

               if(bid >= bepoint && OrderStopLoss() < OrderOpenPrice())
                  isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
              }

            if(OrderType()==OP_SELL)
              {
               bepoint = OrderOpenPrice()-PipsToPrice(InpPipBE,symbol);

               if(ask <= bepoint && OrderStopLoss() > OrderOpenPrice())
                  isBE = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
              }
           }
     }

  }
//+------------------------------------------------------------------+
string GetTicketID(int ticket)
  {
   string id = "";

   for(int i=0; i<ArraySize(IDs); i++)
     {
      if(StringFind(IDs[i],(string)ticket) >= 0)
        {
         string index = IDs[i];
         string parts[];
         StringSplit(index,StringGetCharacter(",",0),parts);

         if(ArraySize(parts) > 0)
           {
            id = parts[0];
            break;
           }
        }
     }

   return id;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetIDSymbol(string id)
  {
   int ticket = -1;
   string symbol = "";

   for(int i=0; i<ArraySize(IDs); i++)
     {
      if(StringFind(IDs[i],id) >= 0)
        {
         string index = IDs[i];
         string parts[];
         StringSplit(index,StringGetCharacter(",",0),parts);

         if(ArraySize(parts) > 1)
           {
            ticket = (int)parts[1];
            break;
           }
        }
     }

   if(OrderSelect(ticket,SELECT_BY_TICKET))
      symbol = OrderSymbol();
   else
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY))
         symbol = OrderSymbol();

   return symbol;
  }
//+------------------------------------------------------------------+
int ThisIDTotal(string id)
  {
   int cnt = 0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==InpMagicNumber)
           {
            int ticket = OrderTicket();
            string thisid = GetTicketID(ticket);

            if(thisid == id)
               cnt++;
           }
     }

   return cnt;
  }
//+------------------------------------------------------------------+
double GetSymbolLot(string symbol)
  {

   double lot = 0;

   for(int i=0; i<ArraySize(LotsPerSymbol); i++)
     {
      if(StringFind(LotsPerSymbol[i],symbol) >= 0)
        {
         string parts[];

         StringSplit(LotsPerSymbol[i],StringGetCharacter("=",0),parts);

         if(ArraySize(parts)==0)
            continue;

         lot = (double)parts[1];

         break;
        }
     }

   return lot;
  }
//+------------------------------------------------------------------+
void GetChannelParams(double &lots, string &exc_syms)
  {

   int handle      = FileOpen("channel_settings.txt",FILE_READ);

   if(handle==INVALID_HANDLE)
      Log("Failed to read settings file. Error = "+(string)GetLastError());

   while(!FileIsEnding(handle))
     {
      string line = FileReadString(handle);

      string parts[];

      StringSplit(line,StringGetCharacter("|",0),parts);

      if(parts[0] != Sender)
         continue;

      if(ArraySize(parts) > 2)
        {
         lots     = (double)parts[1];
         exc_syms = parts[2];
        }

     }


   FileClose(handle);

  }
//+------------------------------------------------------------------+
void Log(string info)
  {

   int handle  = -1;

   string now = TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);


   if(!FileIsExist(logfile))
     {

      handle = FileOpen(logfile,FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ);

      if(handle==INVALID_HANDLE)
        {
         Print("Failed to open log file.");
         return;
        }
      // FileWriteString(handle,"================================");
      FileWriteString(handle,now+" "+info+"\n");
      // FileWriteString(handle,"================================");

      FileClose(handle);
     }

   else
     {
      // FileWriteString(handle,"================================");
      AppendToFile(logfile,now+" "+info+"\n");
      //  FileWriteString(handle,"================================");
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendToFile(string file, string row)
  {

   int handle = FileOpen(file,FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ);

   while(!FileIsEnding(handle))
     {
      if(row == FileReadString(handle))
         return;
     }

   FileSeek(handle,0,SEEK_END);
   FileWriteString(handle, row, StringLen(row));
   FileClose(handle);

  }
//+------------------------------------------------------------------+
