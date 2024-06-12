
#property strict

#include "INetDownload.mqh"

struct SFFEvent {
   string   title;
   string   country;
   datetime time;
   string   impact;
   string   forecast;
   string   previous;
};

class CFFCalendarDownload : public CINetDownload {

protected:

   void     ParseResponse();
   
public:

   // constructors
   CFFCalendarDownload()                           :  CINetDownload() {};
   CFFCalendarDownload(string path, int timeout)   :  CINetDownload(path, timeout) {};
   ~CFFCalendarDownload() {};
   
   // Properties
   
   // read only properties
   // for this one im just making the member variable public
   SFFEvent    Events[];
   int         Count;
   
   // methods
   // download(url, fileName) from parent still works
   bool        Download(string fileName);
   
};

// used specifically for the FF download
bool     CFFCalendarDownload::Download(string fileName) {

   // just reset the calendar to begin
   ArrayResize(Events, 0);
   
   // just use the parent to do the download and return if that fails
   string   url      =  "https://nfs.faireconomy.media/ff_calendar_thisweek.csv";
   bool     result   =  CINetDownload::Download(url, fileName);
   if (!result) return(false);
   
   ParseResponse();
   
   return(true);
   
}

void  CFFCalendarDownload::ParseResponse(void) {

   string   lines[];
   string   columns[];
   int      size = StringSplit(mResponse, '\n', lines);
   
   // Remember that size includes the heading line
   Count    =  size-1;
   ArrayResize(Events, Count);
   string   dateParts[];
   string   timeParts[];
   for (int i =0; i<Count; i++) {
      
      StringTrimRight(lines[i+1]);
      StringTrimLeft(lines[i+1]);
      StringSplit(lines[i+1], ',', columns);
      
      // some items are simple strings
      Events[i].title      =  columns[0];
      Events[i].country    =  columns[1];
      Events[i].impact     =  columns[4];
      
      // date and time are stored sperately and not in a format easy to convert
      // together stored as MM-DD-YYYY HH:MM(am/pm)
      // first break up the date and time into parts
      StringSplit(columns[2], '-', dateParts);
      StringSplit(columns[3], ':', timeParts);
      
      // converting am/pm to 25h must deal with 12 which could be 00
      if(timeParts[0]=="12") {
         timeParts[0] = "00";
      }
      
      // now if pm just add 12 hours
      if(StringSubstr(timeParts[1], 2, 1)=="p") {
         timeParts[0]      =  IntegerToString(StringToInteger(timeParts[0])+12);
      }
      
      // then take only the first 2 characters from the minutes (remove the am/pm parts))
      timeParts[1]         =  StringSubstr(timeParts[1], 0, 2);
      
      // join it back together as YYYY.MM.DD HH:MM
      string   timeString  =  dateParts[2] + "." + dateParts[0] + "." + dateParts[1] +
                              " " + timeParts[0] + ":" + timeParts[1];
      Events[i].time       =  StringToTime(timeString);
      
      // values in forecast and previous may be in different formats 
      Events[i].forecast   =  columns[5];
      Events[i].previous   =  columns[6];
   }
}