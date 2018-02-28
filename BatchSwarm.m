// BatchSwarm.m

#import "BatchSwarm.h"
#import "ModelSwarm.h"
#import "Macro.h"
#import <activity.h>
#import <simtoolsgui.h>


@implementation BatchSwarm

+ createBegin: aZone
{
  BatchSwarm *obj;

  obj = [super createBegin: aZone];

  obj->displayFrequency = 1;
  obj->maxEvolutions = 100;

  return obj;
}

- createEnd
{
  evoCounter = 0;

  return [super createEnd];
}

- buildObjects
{

  time_t tm = time(NULL);
  const char *ctime_result = (const char *) ctime(&tm);
 

  printf("wms2/ABM logfile %s------------------------------------------\n",
	 ctime_result);

  if ((modelSwarm = [lispAppArchiver getWithZone: self 
				     key: "modelSwarm"]) == nil) {
    printf("Missing ModelSwarm parameters.\n");
    exit(1);
  }

  
  modelSwarm->theObserverSwarm=self; //UGH!

  [modelSwarm buildObjects];

  return self;
}

- buildActions
{

  [super buildActions];

  [modelSwarm buildActions];


  displayActions = [ActionGroup create: self];

  //[displayActions createActionTo: modelSwarm    message: M(print)];
  [displayActions createActionTo: self          message: M(count)];

  displaySchedule = [Schedule createBegin: self];
  [displaySchedule setRepeatInterval: displayFrequency]; // note frequency!
  displaySchedule = [displaySchedule createEnd];
  [displaySchedule at: 0 createAction: displayActions];



  return self;
}

- activateIn: swarmContext
{
  [super activateIn: swarmContext];

  [modelSwarm activateIn: self];

  [displaySchedule activateIn: self];

  return [self getSwarmActivity];
}

- go
{
  printf ("[BSW] wms2/ABM running batch mode ('-b' or '--batch'): running w/o graphics.\n");
   
  [[self getActivity] run];
  
  return [[self getActivity] getStatus];
}

- count
{
  evoCounter++;
  
  if(evoCounter%PROG_DUMP_FREQ == 0) {
    [modelSwarm printBestGenoma];
  }
  
  else if(evoCounter>maxEvolutions) {
    printf("Maximum number of evolutions reached.\n");

    [modelSwarm printBestGenoma];
    [modelSwarm dumpProgram];
    exit(0);
  }


  printf("[BSW] Evolution step #%6i completed",evoCounter);

  printf("\n");

  return self;
}

@end

