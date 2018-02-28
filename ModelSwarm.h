// ModelSwarm.h					simPenelope App


//GM stuff

#import "GenomaBucket.h"
#import "Golem.h"
#import "Evaluator.h"

#import <objectbase/Swarm.h>
#import <space.h>
#import <simtoolsgui.h>
#import <gui.h>
#import <analysis.h>

#import "defines.h"
#import "GolemParms.h"

//-------------------

#import "TimeFilter.h"
#import DBINTERFACE

#import "OrderList.h"
#import "Dispatcher.h"
#import PU_KIND

#import "Output.h"

#ifdef USE_TESTER
#import "Tester.h"
#endif

@interface ModelSwarm: Swarm
{
  id modelActions, infoActions;
  id modelSchedule;

  Golem * aGolem;
  GenomaBucket * theGenomaBucket;
  Evaluator       * theEvaluator;

  //GM-specific variables
  float turnoverRate,crossoverRate,mutationRate,evolutionFrequency,
    childrenFitness,useDeltaFitness;
  int randomCrossPoints,
    univocalCrossPoints,bestWillSurvive;

  int numberOfRules;

  int numberOfGenomes;
  int  genomaLength[MAX_NUMBER_OF_GENOMI];
  int  genoMin[MAX_NUMBER_OF_GENOMI];
  int  genoMax[MAX_NUMBER_OF_GENOMI];
  char genoType[MAX_NUMBER_OF_GENOMI];
  //unsigned int rS; //random seed
  char bestFlag;
  int  genomaTotalLength; //genomabucket needs this: total length of genoma

  //ES-specific variables

  int stepDelta; //each Evaluator internal step is stepDelta seconds long

  //SERVICE OBJECTS

  TimeFilter* theTimeFilter; //almost every agent needs it
  
  DBInterface     * theDBInterface;
  OrderList       * theOrderList;

  Dispatcher      * theDispatcher;
  Output          * output;

#ifdef USE_TESTER
  Tester          * theTester;
#endif


  // real OBJECTS

  id <List>  weaverList;
  id <Index> weaverListIndex;
  int weaversLoaded,weaversMaxNumber;


  //-----------------------
  // iVars
  int maxOrdersToProcess;
  int ordersToPlan, ordersToSetup;

@public

  id theObserverSwarm; //Don't even think of giving this id a type.

}



+ createBegin: aZone;
- createEnd;
- buildObjects;
- buildActions;
- activateIn: swarmContext;

- loadWeavers;

- printBestGenoma;
- dumpProgram;

#ifdef USE_TESTER
- runBenchmarks;
#endif

@end




