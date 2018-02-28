// TimeFilter.m                                        

#import "TimeFilter.h"
#import "Macro.h"

@implementation TimeFilter

- (time_t) getPresentTime;
{
  time_t now=time(0);

  L13(printf("[TFL] Time is now %s", ctime(&now));)

  return now;
}

- (char *) getPresentTimeAsString; 
{
  
  time_t now;
  struct tm now_brokendown;
  int year,month,day,hour,minute,second;

  now = [self getPresentTime];
  now_brokendown = *localtime(&now);

  year   = now_brokendown.tm_year - 100;
  month  = now_brokendown.tm_mon;
  day    = now_brokendown.tm_mday;
  hour   = now_brokendown.tm_hour;
  minute = now_brokendown.tm_min;
  second = now_brokendown.tm_sec;

  sprintf(now_string,"%02i/%02i/%02i %02i:%02i:%02i",day,month,year,hour,minute,second);

  return now_string;
}

- (time_t) getAbsoluteTime: (char *) str
{
  time_t t;
  struct tm brokenDownTime;
  //int  year,     mon,     mday,     hour,     min,     sec;
  char year_s[5],mon_s[3],mday_s[3],hour_s[3],min_s[3];

  sscanf(str,"%4s%2s%2s%2s%2s",
	 year_s,mon_s,mday_s,hour_s,min_s);

  brokenDownTime.tm_sec = 0;
  brokenDownTime.tm_min = strtol(min_s,0,10);
  brokenDownTime.tm_hour = strtol(hour_s,0,10);
  brokenDownTime.tm_mday = strtol(mday_s,0,10);
  brokenDownTime.tm_mon = strtol(mon_s,0,10)-1;
  brokenDownTime.tm_year = strtol(year_s,0,10)-1900;
  brokenDownTime.tm_isdst = -1;
  
  t=mktime(&brokenDownTime); //Also sets DST info
  L13(printf("[TFL] Transforming %s[TFL] into UTC %i (DST: %i)\n",
	     ctime(&t), (int) t, brokenDownTime.tm_isdst);)
  return (time_t) t; //WILL OVERFLOW CET 2038 Jan 19 around 4:14 am on 32-bit machines
}

// - (int) getMinsFromString: (char *) str
// {
//   int  min;
//   char min_s[3];

//   sscanf(str,"%*10s%2s",min_s);
//   min=strtol(min_s,0,10);

//   return min;
// }


// - (int) getHourFromString: (char *) str
// {
//   int  hour;
//   char hour_s[3];

//   sscanf(str,"%*8s%2s",hour_s);
//   hour=strtol(hour_s,0,10);

//   return hour;
// }

// - (int) getDayFromString: (char *) str
// {
//   int  day;
//   char day_s[3];

//   sscanf(str,"%*6s%2s",day_s);
//   day=strtol(day_s,0,10);

//   return day;
// }

// - (int) getMonthFromString: (char *) str
// {
//   int  month;
//   char month_s[3];

//   sscanf(str,"%*4s%2s",month_s);
//   month=strtol(month_s,0,10);

//   return month;
// } 

// - (int) getYearFromString: (char *) str
// {
//   int  year;
//   char year_s[5];

//   sscanf(str,"%4s",year_s);
//   year=strtol(year_s,0,10);

//   return year;
// }

- createEnd
{

   [super createEnd];

   return self;
}

@end








