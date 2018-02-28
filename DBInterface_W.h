// DBInterface.h

#import <objectbase/SwarmObject.h>
#import <simtools.h>  // necessary to invoke In/OutFile protocol
#import <time.h>

#import "defines.h"

//#import "DataWareHouse.h"
#import "TimeFilter.h"

#import "Macro.h"

@interface DBInterface: SwarmObject
{
  //  DataWareHouse * myDataWareHouse;
  TimeFilter * myTimeFilter;

  id <InFile> ordersFile;     //ORDERS DB

  //calendar stuff
  id <InFile> weaversCalFile; //CALENDAR DB - WEAVERS
  id <InFile> teamsCalFile;   //CALENDAR DB - TEAMS

  struct calDataStruct {
    int   weaversVector[CALENDAR_SPAN_DAYS];  //half-hours 0/1s
    float teamsVectorHrs[CALENDAR_SPAN_DAYS]; //hours per day
  } calData;

  //------------


  char *lastOrdersFileName;      //displayed in my probe
  char *conventionallyGivenDate; //if an order is missing a delivery date use this
  int zeroCompVectors;

  struct durationsPerFamily {
    float  duration;
    char   family[3];
  } durationsArray[NUM_OF_FAMILIES];

  struct setupCostsAndDurationsPerKind {
    float  cost0;
    float  cost1; //idem as cost0
    float  dur0;  //cycle time (man-hours / men needed)
    float  dur1;  //man-hours
    char   setup[3];
  } costsFamArray[NUM_OF_SETUPS];

  struct costsPerDates {
    time_t time;
    float  cost;
  } costsDatesArray[COSTS_DAYS_SPAN];

  struct costsPerDatesRaw {
    char date[20];
    char cost[20];
  } costsDatesArrayRaw[COSTS_DAYS_SPAN];


  struct rec_str {  // typical database entry made available for other agents
    char flag1[2];  // status (plan/dont plan)
    char flag2[2];  // kind (a telaio/in lavor/in formazione)
    char chain[10]; // chain #
    struct durationsPerFamily  durPerFam[NUM_OF_FAMILIES]; //lead time
    struct setupCostsAndDurationsPerKind costAndDurPerKind[NUM_OF_SETUPS];   //setup costs
    struct costsPerDates       costPerDates[COSTS_DAYS_SPAN];               //delay costs
    char cacc[20];  //CA/CC
    char color[2];  //color 0-gre 1-col
    float hcomb;    //comb h
    int rnote;      //rapp note @@@TODO@@@
    float satperc;  //saturation%
    int pu;         //assigned weaver (if ongoing - used for initial setup)
    char vec[100];  //weaver compat vector

    char code[20]; // used only internally by -ReadOrder and passed to getOrder
  } rec, orderFromFile;

}

+ createBegin: aZone;
- createEnd;

- setTimeFilter: theTimeFilter;


- readOrdersFrom: (char *) of;
- (struct rec_str) getOrder;

- readWeaversCalFromFile: (char *) wf;
- readTeamsCalFromFile:   (char *) tf;
- (struct calDataStruct) getCalData;

- (time_t) getFirstDateAvailable;

@end
