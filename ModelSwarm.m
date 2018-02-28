// ModelSwarm.m					simPenelope app

#import "ModelSwarm.h"

#import "Macro.h"
//#import "GMMacro.h" //to check against MAXGL 
#import <random.h>
#import <activity.h>
#import <collections.h>
#import <defobj/version.h>
#import <math.h>

//#define ABSOLUTE_START_TIME "200308021200"
//#define ABSOLUTE_START_TIME "200309152200" //test1
//#define ABSOLUTE_START_TIME "200307312200"

@implementation ModelSwarm  

// These methods provide access to the objects inside the ModelSwarm.
// These objects are the ones visible to other classes via message call.
// In theory we could just let other objects use Probes to read our state,
// but message access is frequently more convenient.

+ createBegin: aZone 
{
  ModelSwarm *obj;

  obj = [super createBegin: aZone];

  obj->weaversMaxNumber   = MAX_WEAVERS;


  // GM-specific parameters:
  obj->numberOfRules       = 100;
  obj->turnoverRate        = 0.5;
  obj->crossoverRate       = 0.5;
  obj->mutationRate        = 0.001;
  obj->evolutionFrequency  = 1;
  obj->childrenFitness     = 0;
  obj->useDeltaFitness     = 1;

  obj->bestFlag        = 'f';

  obj->numberOfGenomes =  2;
  obj->genomaLength[0] = 30;//100; //ORDERS
  obj->genoMin[0]      =  0; 
  obj->genoMax[0]      =  3;//38;
  obj->genoType[0]     = 'u'; //univocal orders
  obj->genomaLength[1] = 10;//100; //PUs
  obj->genoMin[1]      =  0;
  obj->genoMax[1]      = 3;//38;
  obj->genoType[1]     = 'r'; //random PUs


  // ES-specific parameters
  obj->stepDelta       = REAL_TIME_TICKS;  //3600 normally

  obj->genomaTotalLength = 0;

  return obj;
}

- createEnd
{
  /*
  genomaTotalLength += genomaLength[0];
  genomaTotalLength += genomaLength[1];
  */

  maxOrdersToProcess = MAX_ORDERS;

  return [super createEnd];
}

- buildObjects
{

  char ordersFileName[255];
  char dumpFileName[255];
  char programFileName[255];

  time_t simStartTime;

  //file names in defines.h
  strncpy(ordersFileName,ORD_FN,255);
  strncpy(dumpFileName,DUMP_FN,255);
  strncpy(programFileName,PROG_FN,255);

  //--SERVICE-OBJs--------------------------------------
  // Timefilter
  
  theTimeFilter = [TimeFilter createBegin: [self getZone]];
  theTimeFilter = [theTimeFilter createEnd];
  L2(printf("[MDS] theTimeFilter created succesfully.\n");)
    
    // DBInterface
    theDBInterface = [DBInterface createBegin: [self getZone]]; //spinning

  L2(printf("[MDS] DBInterface created succesfully.\n");)
    [theDBInterface setTimeFilter: theTimeFilter];
  L2(printf("[MDS] Initializing DBInterface; loading data from \"%s\"...\n",
	    ordersFileName);)
    [theDBInterface readOrdersFrom: ordersFileName];
  theDBInterface = [theDBInterface createEnd];
  L2(printf("[MDS] ...done.\n");)


    // OrderList 
    theOrderList = [OrderList createBegin: [self getZone]];
  [theOrderList setDBInterface: theDBInterface];
  theOrderList = [theOrderList createEnd];
  L2(printf("[MDS] OrderList created succesfully.\n");)
    
    //----Real-OBJs----------------------------------------

    //Weavers
    [self loadWeavers];


    //Dispatcher
  theDispatcher = [Dispatcher createBegin:[self getZone]];
  theDispatcher = [theDispatcher createEnd];
  [theDispatcher setPUsList: weaverList];
  [theDispatcher setPUsNumber: weaversLoaded];
  [theDispatcher setOrderList: theOrderList];
  [theDispatcher setStepDelta: stepDelta];
  L2(printf("[MDS] Dispatcher created succesfully.\n");)


    //------------------------------------------------------
    //STARTUP SEQUENCE--------------------------------------
    //------------------------------------------------------
    
  [theOrderList readNOrdersFromDB: maxOrdersToProcess];

  //internal numbers - to - orders codes table
  [theOrderList saveNumToChainsFile];

  ordersToPlan  = [theOrderList getQueueLength];
  ordersToSetup = [theOrderList getSetupLength]; 

  [theDispatcher setSetupOrders: ordersToSetup]; //dispatcher needs to know how many
  
  genomaTotalLength = ordersToPlan * 2;  //orders-PUs couples

  L2(printf("[MDS] %i Orders to plan read from file.\n",ordersToPlan);)
  L2(printf("[MDS] %i Orders to setup read from file.\n",ordersToSetup);)      


    //////////////////AG-stuff///////////////////////
    
    //20021025 MM - building genomabucket

    theGenomaBucket = [GenomaBucket createBegin: self];
  [theGenomaBucket createEnd];
  [theGenomaBucket setGenomaTotalLength: genomaTotalLength];
  L2(printf("[MDS] GenomaBucket (C) 2003 MM created succesfully.\n");)
  L2(printf("[MDS] Genomabucket working on %i genes long items.\n",genomaTotalLength);)
      
    //20030517 MM - introducing GOLEM
  aGolem =  [Golem  createBegin:       self];
  [aGolem setNumberOfRules:  numberOfRules];
  [aGolem setNumberOfGenomes: numberOfGenomes]; //[][]

  //'orders' part
  genomaLength[0] = ordersToPlan;
  genoMin[0] = 0;
  genoMax[0] = ordersToPlan - 1; //useless, Golem uses length in U mode

  //'PUs' part
  genomaLength[1] = ordersToPlan; //one pu per each order
  genoMin[1] = 0;
  genoMax[1] = weaversLoaded - 1;
  //golem always returns PUs ranging from 0 to the number of PUs-1 (offsets)


  [aGolem setGenomeLengths:   genomaLength];
  [aGolem setGenomeMinValues:     genoMin];
  [aGolem setGenomeMaxValues:     genoMax];
  [aGolem setGenomeTypes:         genoType]; 
  //
  [aGolem setRandomSeed:     19740726];
  [aGolem setTurnoverRate:   turnoverRate];
  [aGolem setCrossoverRate:  crossoverRate];
  //
  [aGolem setRandomCrossPoints:   1];
  [aGolem setUnivocalCrossPoints: 1];
  //
  [aGolem setMutationRate:   mutationRate];
  //
  [aGolem setBestWillSurvive:     bestFlag];
  //
  [aGolem buildObjects:      self];
  aGolem =  [aGolem createEnd];
  [aGolem createAtRandom];
  L2(printf("[MDS] GOLEM (C) 2003 GLF instantiated succesfully.\n");)


#ifdef USE_TESTER
    //BUILD TESTER
    L2(printf("[MDS] \"Tester\" benchmarking module loaded.\n");)
  theTester = [Tester createBegin: self];
  [theTester setOrderList: theOrderList];
  [theTester createEnd];
  [theTester setOrdersToPlan: ordersToPlan];
  [theTester setPUsLoaded:    weaversLoaded];
  [theTester buildRules: self];
  [theTester makeFIFORule];
  [theTester makeRNDRule];
#endif
    
    //BUILD EVALUATOR (after GB and golem)
    theEvaluator = [Evaluator createBegin: self];
  [theEvaluator setGenomaBucket: theGenomaBucket];
  [theEvaluator setGolem: aGolem];
  [theEvaluator setDispatcher: theDispatcher];
  [theEvaluator setOrderList: theOrderList];
#ifdef USE_TESTER
  [theEvaluator setTester: theTester];
#endif
  theEvaluator = [theEvaluator createEnd];
  L2(printf("[MDS] theEvaluator created succesfully.\n");)

  [theEvaluator setPUsLoaded: weaversLoaded];
  [theEvaluator setOrdersToPlan: ordersToPlan];
  
  simStartTime=[theDBInterface getFirstDateAvailable]+SIMTIME_OFFSET;
  [theEvaluator setPresentTime: simStartTime]; //GOOD!
  L2(
     printf("[MDS] theEvaluator simulated time starts at: %s",ctime(&simStartTime));
  )


    //set initial sim time for spinners
    {
      Weaver * aWeaver;
      int i;

      for(i=0;i<weaversLoaded;i++) {

	[weaverListIndex setOffset: i];
	aWeaver=[weaverListIndex get];

	printf("[MDS] DBG: simstarttime = %s",ctime(&simStartTime));
	[aWeaver setInitialSimTime: simStartTime];
      }

    }

   

    //BUILD OUTPUT MODULE
    output = [Output createBegin: self];
  [output setGolem: aGolem];
  [output setTimeFilter: theTimeFilter];
  [output setEvaluator: theEvaluator];  //to map raw pu's to compat pu's
  output = [output createEnd];
  [output setOrdersToPlan: ordersToPlan]; 
  [output setPUsLoaded: weaversLoaded];
  [output dumpToFile:    dumpFileName];
  [output programToFile: programFileName];

#ifdef USE_TESTER
  [self runBenchmarks];
#endif

  return self;
}

 

- buildActions
{
  int i;

  modelActions = [ActionGroup create: self];
  [modelActions createActionTo: theEvaluator message: M(step)];
  [modelActions createActionTo: output message: M(dumpEvoStep)]; 
  //(is really an informative action but better make it run every step)

  infoActions = [ActionGroup create: self];
  [infoActions createActionTo: theEvaluator message: M(printConvergency)];
  //[infoActions createActionTo: aGolem message: M(print)];   


  modelSchedule = [Schedule createBegin: self];
  [modelSchedule setRepeatInterval: OUTPUT_FREQ];
  modelSchedule = [modelSchedule createEnd];

  for(i=0;i<OUTPUT_FREQ;i++) {
    [modelSchedule at: i createAction: modelActions];
  }

  [modelSchedule at: 0 createAction: infoActions]; //once every OUTPUT_FREQ steps

  return self;
}

- activateIn: swarmContext
{

  [super activateIn: swarmContext];

  [modelSchedule activateIn: self];

  return [self getSwarmActivity];
}

- loadWeavers;
{

  Weaver *aWeaver;

  char weaverDBFileName[255];

 
  id <InFile> weaverDBFile;

  char tempDesc[100]; //weavers descriptive string
  char weaverDescription[50];
  char weaverFamily[2];
  char realWeaverNumberString[5];
  int realWeaverNumber=0; //the numeric ID each weaver has

  int i,offset;

  strcpy(weaverDBFileName,WDB_FN);


  //Weaver creation begins here
      
    weaverDBFile=[InFile create: [self getZone] setName: weaverDBFileName];

    if (weaverDBFile == nil) {
      printf("[MDS] Missing weaverDBFile (\"%s\"). Exiting.\n",weaverDBFileName);
      exit(1);
    }

    L2(printf("[MDS] Weaver DBFileName is: %s\n",weaverDBFileName);)

      weaverList=[List create: [self getZone]];

    L2(printf("[MDS] WeaverList created succesfully. Reading from file...\n");)

      //Create empty list+index to fill (later) with weavers at the appropriate offsets
      //check for duplicate ids -> TO HAPPEN outside wms  

      for (i=0; i<weaversMaxNumber;i++) [weaverList addLast: nil];

    //Create index
    weaverListIndex=[weaverList begin: [self getZone]];

    for (i=0; i<weaversMaxNumber;i++) {
      aWeaver=[Weaver createBegin: self];

      if ([weaverDBFile getLine: (char *) tempDesc] == 0) break;
    
      sscanf(tempDesc,"%*[#] %[0-9 ] %*[#] %[A-Z] %*[#] %[A-Z0-9 ]",
             realWeaverNumberString,weaverFamily,weaverDescription);

        realWeaverNumber = (int) strtol(realWeaverNumberString,0,10);

        [weaverDBFile skipLine];

        [aWeaver setNumber: realWeaverNumber];
        [aWeaver setDesc: weaverDescription];
	[aWeaver setFamily: weaverFamily];

	//initial parameters (nonsense)
        [aWeaver setCacc: PU_INITVAL];


        //FIX TEMP SETUP        

        //printf("%i#%i\n",realWeaverNumber,i);
        //[aWeaver setAvailability: [theTimeFilter getAbsoluteTime: "200303281200"]];

	L2(printf("[MDS] Weaver #%4i (%s) - family <%s>.\n",
                [aWeaver getNumber], [aWeaver getDesc], [aWeaver getFamily]);)
	  
	  //[aWeaver setSpeed: 0]; //useless by now
	  //[aWeaver setOrderNumber: 0];

	aWeaver=[aWeaver createEnd];

      //----------LAST, ADD TO LIST -----------------

      offset=realWeaverNumber-W_OFFSET; //check comment in defines.h

      [weaverListIndex setOffset: offset];


      [weaverListIndex setOffset: offset];
      if([weaverListIndex get] == nil) [weaverListIndex put: aWeaver];
      else {
        printf("[MDS] Big trouble in ModelSwarm - PU #%i defined twice\n",realWeaverNumber);
        exit(PU_NONUNIQUE_IN_DATA);
      }
    }

    [weaverDBFile drop];

    weaversLoaded=i; //'i' starts from 0, so the number is correct
                     //even if for ends when already made one step too much

    L2(printf("[MDS] %i weavers created succesfully.\n",weaversLoaded);)


      /* SHOW WEAVERS IN ORDER */
      L2(
         printf("[MDS] Weavers list ordered by offset:\n");
      for (i=0;i<weaversLoaded;i++) {
        if([weaverList atOffset: i] != nil) {
          printf("[MDS] (%4i) #%4i - %s\n",
                 i,
                 [[weaverList atOffset: i] getNumber],
                 [[weaverList atOffset: i] getDesc]
                 ); 
        } else {
          printf("[MDS] Offset %i is empty - uhm. (!)\n",i);
        }
      }
         )
      //i gives the right number because the loop starts from 0 but 
      //gets incremented one more time when breaking

      //-----end of weavers' creation

  return self;
}

- printBestGenoma
{
  int *body;
  float fitness;
  int i;


  body    = [aGolem getBestRuleEver];
  fitness = [aGolem getMaxFitnessEver];

  printf("-------------------------------\n");
  printf("- Best Solution Found Follows -\n");  
  printf("-------------------------------\n");

  printf("Fitness: %f\n", fitness);
  printf("Body: [");

  for(i=0;i<ordersToPlan;i++) {
    printf("%i ",body[i]);
  }  
  printf("]*[");
  for(i=0;i<ordersToPlan;i++) {
    printf("%i ",body[i+ordersToPlan]);
  }  
  printf("]\n");
  /*
  printf("Assignments:\n");
  for(i=0;i<ordersToPlan;i++) {
    printf("[%4i->%4i]\n",body[i],body[i+ordersToPlan]);
  }
  */

  return self;
}

- dumpProgram
{
  [output dumpProgram];
  [output dumpTxtGantt];
  return self;
}

#ifdef USE_TESTER
- runBenchmarks
{
  printf("[MDS] Running benchmark plans.\n");

  [theEvaluator benchStep1];
  [theEvaluator benchStep2];

  return self;
}
#endif

@end





