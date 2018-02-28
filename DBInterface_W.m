// DBInterface.m

#import "DBInterface_W.h"
#import <random.h>
#import <stdlib.h> //for strtod

@implementation DBInterface

/*
- setDataWareHouse: dwh
{
  myDataWareHouse = dwh;
 return self;
}
*/

- setTimeFilter: tf
{
  myTimeFilter=tf;
  return self;
}

- readOrdersFrom: (char *) of
{
  strcpy(lastOrdersFileName,of);

  ordersFile=[InFile create: [self getZone] setName: of];

  if (ordersFile == nil) {
    printf("[DBI] Missing ordersFile (\"%s\"). Try another file name or toggle fakeOrdersG on.\n",of);
    exit(1);
  } 
  else 
    {
      L4(printf("[DBI] Will read orders from \"%s\".\n", of);)
	//[ordersFile skipLine]; //skip headers (if any)
  }

  return self;
}

- (struct rec_str) getOrder //real orders read from a file
{
  //The time the order must be ready 
  static const char *timeOfDeliveryDay=TIME_OF_DELIVERY; //by noon - use as standard time

  int    i=0;
  int    j=0;

  static char  orderLine[ORDERS_LINES_LENGTH]="";

  static char  field1[20]=""; // Chain number
  static char  field2[20]=""; // FLAG1: fixed / plannable
  static char  field3[20]=""; // FLAG2: Record origin - Pela, D, G

  static char  field_famspeed[100]="";   // speeds per family 12x5
  static char  field_setupcosts[200]=""; // setup costs (4 kinds: CA CD CF CM)
  
  static char  field_deliveries[2000]="";

  static char  field4[20]="";  // CA/CC


  static char  field5[2]="";   // color code (0=gr,1=col)
  static char  field6[10]="";  // Comb h
  static char  field7[5]="";   // note report
  static char  field8[8]="";   // saturation percentage

  static char  field8b[8]="";  // assigned weaver
  
  static char  field9[MAX_WEAVERS]=""; // compatibility vector

  /***/

  static struct rec_str dataToReturn;


  char tempDate[20]; 
  //used in trimming date field
  //initial default value keeps bad things 
  //from happening when date fields are empty

  char tempYear[5],tempMonth[3],tempDay[3];

  strcpy(tempYear,"1974");
  strcpy(tempMonth,"07");
  strcpy(tempDay,"26");



  if ([ordersFile getLine: orderLine] != 0) {

    sscanf(orderLine,"%*1c%5c",
	   field1);
    sscanf(orderLine,"%*17c%1c",
	   field2);
    sscanf(orderLine,"%*19c%1c",
	   field3);

    //keep the first # (makes offsetting easier)
    sscanf(orderLine,"%*20c%60c",
	   field_famspeed);

    //read setupcosts at once (keep first #)
    sscanf(orderLine,"%*80c%135c",
	   field_setupcosts); //and durations...

    //read deliverycosts at once (keep first #)
    sscanf(orderLine,"%*215c%1200c",
	   field_deliveries);

    //(read ca/cc) - in weaving is ca/ro/ug
    sscanf(orderLine,"%*1416c%10c",
	   field4);

    //read color
    sscanf(orderLine,"%*1427c%1c",
	   field5);

    //read hcomb
    sscanf(orderLine,"%*1429c%5c",
	   field6);
    //read rapp note
    sscanf(orderLine,"%*1435c%3c",
	   field7);
    //read %sat
    sscanf(orderLine,"%*1439c%5c",
	   field8);
    //read assigned weaver
    sscanf(orderLine,"%*1445c%3c",
	   field8b);

    //read constraining date
    /* NOT USED IN WEAVING
    sscanf(orderLine,"%*1449c%10c",
	   field8c);
    */

    //read compat vector
    sscanf(orderLine,"%*1460c%[01]",
	   field9);


    //    printf("****<%s>\n",orderLine);

    /***trim variables that need trimming***/

    //printf("DEBUG fields 7,8,8b: %s|%s|%s\n",field7,field8,field8b);

    for (i=0;i<NUM_OF_FAMILIES;i++) {
      int f1 = 1;  //1 char for family
      int f2 = 9;  //9 chars for speed
      int ft = 12; //12 chars offset
      char tempDuration[20]=""; //duration as string
      //printf("debug famspeed <%s>\n",field_famspeed);
      // printf(" dura |%12c|\n",field_famspeed[(ft*i)+f1+f2+1]);

      strncpy(durationsArray[i].family,   &field_famspeed[(ft*i)+1], f1);
      strncpy(tempDuration,               &field_famspeed[(ft*i)+f1+2], f2);

      durationsArray[i].duration = strtod(tempDuration,0);
/*
      printf("DEBUG: fam(%i)=<%s> dur(%i)=<%f> |%s|\n",
	     i,durationsArray[i].family,
	     i,durationsArray[i].duration, tempDuration);
*/
    }

    //printf("setupcosts: |%s|\n",field_setupcosts);

    for (i=0;i<NUM_OF_SETUPS;i++) {
      int f1 = 2;  //2 chars for family    #CF
      int f2 = 6;  //6 chars for each cost #123.45
      int f3 = 4;  //4 chars for each duration #10.0
      int ft = 27; //27 chars offset       #[...] each fam+c0+d0+c1+d1
      char tempCost0[10]=""; //cost as string
      char tempCost1[10]=""; //cost as string
      char tempDur0[10]=""; //duration as string
      char tempDur1[10]=""; //duration as string
      //printf("debug setupcosts <%s>\n",field_setupcosts);


      strncpy(costsFamArray[i].setup,  &field_setupcosts[(ft*i)+1], f1); //fields+# of #s
      //printf("* setup type |%s|\n", costsFamArray[i].setup);

      strncpy(tempDur0,                &field_setupcosts[(ft*i)+f1+2],  f3);
      strncpy(tempCost0,               &field_setupcosts[(ft*i)+f1+f3+3], f2);
      //printf("* setup dur0 |%s|\n",tempDur0);
      //printf("* setup cst0 |%s|\n",tempCost0);

      strncpy(tempDur1,                &field_setupcosts[(ft*i)+f1+f3+f2+4], f3);
      strncpy(tempCost1,               &field_setupcosts[(ft*i)+f1+f3+f2+f3+5],    f2);

      costsFamArray[i].cost0 = strtod(tempCost0,0);
      costsFamArray[i].cost1 = strtod(tempCost1,0);

      costsFamArray[i].dur0 = strtod(tempDur0,0);
      costsFamArray[i].dur1 = strtod(tempDur1,0);

/*
            printf("DEBUG: cost(%s[%i]) => <%s> c0=<%f> d0=<%f> c1=<%f> d1=<%f>\n",
           field1, i, costsFamArray[i].setup,
           costsFamArray[i].cost0, costsFamArray[i].dur0,
           costsFamArray[i].cost1, costsFamArray[i].dur1);
*/

    }

    for (i=0;i<COSTS_DAYS_SPAN;i++) {
      int ft = 24; //offset
      int f1 = 10; // 10 chars for date
      int f2 = 12; // 12 chars for cost
      //      printf("|%s|\n", field_deliveries);

      strncpy(costsDatesArrayRaw[i].date, &field_deliveries[(ft*i)+1],  f1);
      strncpy(costsDatesArrayRaw[i].cost, &field_deliveries[(ft*i)+f1+2], f2);
      /*
      printf("DEBUG: date(%i)=%s cost(%i)=%s \n",
      	     i, costsDatesArrayRaw[i].date, i, costsDatesArrayRaw[i].cost);
      */
      //trim date
      sscanf(costsDatesArrayRaw[i].date,
	     "%[0-9]%*[/]%[0-9]%*[/]%[0-9]",tempDay,tempMonth,tempYear);
      //printf("DEBUG: |tY|tM|tD|-|%s|%s|%s|\n",tempYear,tempMonth,tempDay);
      sprintf(tempDate,"%s%s%s%s",tempYear,tempMonth,tempDay,timeOfDeliveryDay);
      //printf("DEBUG: tempdate=|%s|\n",tempDate);

      costsDatesArray[i].time=[myTimeFilter getAbsoluteTime: tempDate];
      costsDatesArray[i].cost=strtof(costsDatesArrayRaw[i].cost,0);

      //printf("DEBUG: day %s - cost=%7.3f\n",ctime(&costsDatesArray[i].time) , costsDatesArray[i].cost);

    }
    
 
    //*****fill the struct with the data we've just read
    strcpy(dataToReturn.chain,field1);
    strcpy(dataToReturn.flag1,field2);
    strcpy(dataToReturn.flag2,field3);
    strcpy(dataToReturn.cacc,field4);
    strcpy(dataToReturn.color,field5);
    dataToReturn.hcomb   = strtof(field6,0);
    dataToReturn.rnote   = strtol(field7,0,10);
    dataToReturn.satperc = strtof(field8,0);
    dataToReturn.pu      = strtol(field8b,0,10);
    strcpy(dataToReturn.vec,field9);
    

    for (j=0;j<NUM_OF_FAMILIES;j++)
      dataToReturn.durPerFam[j] = durationsArray[j];
    for (j=0;j<NUM_OF_SETUPS;j++) {
      strcpy(dataToReturn.costAndDurPerKind[j].setup, costsFamArray[j].setup);
      dataToReturn.costAndDurPerKind[j].cost0 = costsFamArray[j].cost0;
      dataToReturn.costAndDurPerKind[j].cost1 = costsFamArray[j].cost1;
      dataToReturn.costAndDurPerKind[j].dur0 = costsFamArray[j].dur0;
      dataToReturn.costAndDurPerKind[j].dur1 = costsFamArray[j].dur1;
    }
    for (j=0;j<COSTS_DAYS_SPAN;j++) {
      dataToReturn.costPerDates[j].time = costsDatesArray[j].time;
      dataToReturn.costPerDates[j].cost = costsDatesArray[j].cost;
    }

    //Anyway, read next line
    [ordersFile skipLine];

    //In case there aren't any orders left to read...
  } else {
    L4(printf("[DBI] Orders List emptied.\n");)
    L4(printf("[DBI] --------------------\n");)

      strcpy(dataToReturn.code,"*end*"); //magic string to tell (OrderList) that readOrder failed
      //      dataToReturn.kgs=0;
      return dataToReturn;
    }

  return dataToReturn;
}


+ createBegin: aZone
{
  DBInterface *obj;

  obj = [super createBegin: aZone];
  obj->lastOrdersFileName = (char *) malloc(15);
  obj->conventionallyGivenDate = (char *) malloc(9);

  return obj;
}


- createEnd
{
  zeroCompVectors=0;
  //Need a "later" date to assign orders without a delivery date
/*
  time_t now=time(0);
  time_t later;
  struct tm laterBrokenDown;
*/
  [super createEnd];

  /*
  if(fixedMissingDateMode == NO) {
    later=now+(86400*daysLater);; //one day=86400 seconds;
    laterBrokenDown=*localtime(&later);

    sprintf(conventionallyGivenDate,"%04i%02i%02i",
	    laterBrokenDown.tm_year+1900,
	    laterBrokenDown.tm_mon+1,
	    laterBrokenDown.tm_mday);
    L4(printf("[DBI] Date assigned to orders without one is: %s\n",
	   conventionallyGivenDate);)
  } else {
  */
    //strcpy(conventionallyGivenDate,"20380101");
    //L4(printf("[DBI] Date assigned to orders without one is very very far in time.\n");)
  /*
  }
*/

  return self;
}


/************** calendar *****************/

- readTeamsCalFromFile:   (char *) tf;
{
  static char calLine[100];
  static char field1[20]; //date
  static char field2[10]; //hours
  //time_t date;
  //float hours;

  int i;

  teamsCalFile=[InFile create: [self getZone] setName: tf];

   if (teamsCalFile == nil) {
   printf("[DBI] Missing calendar file for teams (\"%s\").\n",tf);
   exit(1);
} else {
   L12(printf("[DBI] Reading calendar file for teams from file \"%s\".\n",tf);)
     }

   for(i=0;i<MAX_SETUP_ORDERS;i++) {
     
     if ([teamsCalFile getLine: calLine] != 0) {
       sscanf(calLine,"%*[#]%[0-9/ ]%*[#]%[0-9. ]",field1,field2);
       
       calData.teamsVectorHrs[i]=strtof(field2,0);
//       printf("[DBI] DEBUG: read %f hours for day %i\n",calData.teamsVectorHrs[i],i);

       [teamsCalFile skipLine];
     } else {
       printf("[DBI] %i records (days) read for teams calendar.\n",i);
       break;
     }
   }     
   
   [teamsCalFile drop];
  return self;
}

- readWeaversCalFromFile: (char *) wf;
{
  static char calLine[WEAVERS_CAL_LINES_LENGTH];
  static char field1[20]; //date
  static char field2[WEAVERS_CAL_LINES_LENGTH]; //availability vectors

  static char date[21];
  static char vectors[WEAVERS_CAL_LINES_LENGTH+1];

  //time_t date;
  //float hours;

  int i;

  weaversCalFile=[InFile create: [self getZone] setName: wf];
  
  if (weaversCalFile == nil) {
    printf("[DBI] Missing calendar file for weavers (\"%s\").\n",wf);
    exit(1);
  } else {
    printf("[DBI] Reading calendar file for weavers from file \"%s\".\n",wf);
      }
  
   for(i=0;i<CALENDAR_SPAN_DAYS;i++) {
     
     if ([weaversCalFile getLine: calLine] != 0) {
       sscanf(calLine,"%*1c%10c",field1);
       sscanf(calLine,"%*12c%50c",field2);

       strncpy(date,field1,20);
       strncpy(vectors,field2,50);

       //printf("[DBI] DEBUG: |%s|%s|\n",date,vectors);
       [teamsCalFile skipLine];
     } else {
       printf("[DBI] %i records (days) read for weavers calendar.\n",i);
       break;
     }
   }     
   
   [weaversCalFile drop];
  return self;
  

  return self;
}

- (struct calDataStruct) getCalData
{
  return calData;
}

- (time_t) getFirstDateAvailable
{
  return costsDatesArray[0].time;
}

@end
