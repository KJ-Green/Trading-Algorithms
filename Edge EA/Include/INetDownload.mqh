
#property strict

class CINetDownload {

protected:

   string   mPath;
   int      mTimeout;
   string   mResponse;
   int      mError;

public:

   // constructors
   CINetDownload();
   CINetDownload(string path, int timeout);
   ~CINetDownload() {};
   
   // properties
   void     Path(string value)   {  mPath = value;    }
   string   Path()               {  return(mPath);    }

   void     Timeout(int value)   {  mTimeout = value; }
   int      Timeout()            {  return(mTimeout); }
   
   // read only properties
   int      Error()              {  return(mError);   }
   string   Response()           {  return(mResponse);}
   
   // methods
   bool     Download(string url, string fileName);
   
};

CINetDownload::CINetDownload(void) {

   CINetDownload("", 10000);

}

CINetDownload::CINetDownload(string path,int timeout) {

   Path(path);
   Timeout(timeout);
   
}

// This is the most simple download, no arguments just the url
bool  CINetDownload::Download(string url, string fileName) {

   string   filePath =  Path() + "\\" + fileName;
   string   cookie   =  NULL;
   string   referer  =  NULL;
   int      timeout  =  Timeout();
   char     data[];
   char     response[];
   string   headers;
   
   mResponse      =  "";
   ResetLastError();
   
   int   result   =  WebRequest("GET", url, cookie, referer, timeout, data, 0, response, headers);
   
   if(result<0) {
      mError   =  GetLastError();
      PrintFormat("%s error %i downloading from %s", __FUNCTION__,mError,url);
      return(false);
   }
   
   mResponse   =  CharArrayToString(response);
   
   int   handle = FileOpen(filePath, FILE_WRITE | FILE_BIN);
   if(handle == INVALID_HANDLE) {
      mError   =  GetLastError();
      PrintFormat("%s error %i opening file %s", __FUNCTION__, mError, filePath);
      return(false);
   }
   
   FileWriteArray(handle, response, 0, ArraySize(response));
   FileFlush(handle);
   FileClose(handle);
   
   return(true);

}