// Output.m                                        

#import "Output.h"

@implementation Output

- createEnd
{
  
   [super createEnd];
   return self;
}

- programToFile: (char *) f
{
  programFile = [OutFile create: [self getZone] setName: f];

  if (programFile == nil) {
    printf("[GMRM] CRITICAL: Problem writing PROGRAM file to disk...");
    exit(PROG_FILE_CREAT_FAILED);
  }

  return self;
}

- dumpToFile: (char *) f
{

  dumpFile = [OutFile create: [self getZone] setName: f];

  if (dumpFile == nil) {
    printf("[GMRM] CRITICAL: Problem writing DUMP file to disk...");
    exit(DUMP_FILE_CREAT_FAILED);
  }

  //HEADERS LINE
  [dumpFile putString:
	      "Date/Time, minFitness, avgFitness, maxFitness, maxFitnessHistoric\n"
   ];
  

  return self;
}

- dumpEvoStep
{
  char dumpTextLine[1024]; //min avg max max_ever
  char datetime[255];
  
  float minFitness, meanFitness, maxFitness, maxFitnessEver;

  strncpy(datetime, [theTimeFilter getPresentTimeAsString], 255);

  minFitness     = [theGolem getMinFitness];
  meanFitness    = [theGolem getMeanFitness];  
  maxFitness     = [theGolem getMaxFitness];
  maxFitnessEver = [theGolem getMaxFitnessEver];


  sprintf(dumpTextLine,"%s, %10.2f, %10.2f, %10.2f, %10.2f\n",
	  datetime,
	  minFitness, meanFitness, maxFitness, maxFitnessEver
	  );
  

  [dumpFile putString: dumpTextLine];

  return self;
}

- dumpProgram
{
  char programTextLine[20]; // x # y
  //int ganttMatrix[MAX_WEAVERS][MAX_ORDERS];

  int *body;
  int orderNum, puNum;

  int i;

  body = [theGolem getBestRuleEver];

  for(i=0;i<ordersToPlan;i++) {
    orderNum=body[i];
    puNum=body[i+ordersToPlan];
    /*map to correct pu by CompVector*/
    puNum = [theEvaluator mapPUOntoCompatPU: puNum forOrder: orderNum];


    sprintf(programTextLine,"%6i # %6i%c%c",orderNum,puNum+W_OFFSET,CR,LF);

    [programFile putString: programTextLine];
  }


  return self;
}

- dumpTxtGantt
{
  int ganttMatrix[MAX_WEAVERS][MAX_ORDERS];
  int ganttIndex[MAX_WEAVERS];

  int *body;
  int orderNum, puNum;

  int i,j;

  body = [theGolem getBestRuleEver];
  
  //fill matrix
  for(i=0;i<ordersToPlan;i++) {
    orderNum=body[i];           //points to an order
    puNum=body[i+ordersToPlan]; //points to a pu
    /*map to correct pu by CompVector*/
    puNum = [theEvaluator mapPUOntoCompatPU: puNum forOrder: orderNum];

    ganttMatrix[puNum][ganttIndex[puNum]] = orderNum;
    ganttIndex[puNum]++;
  }

  //dump stuff  
  for(i=0;i<PUsLoaded;i++) {
    printf("WEAVER #%2i: ",i+W_OFFSET); //correct for weaver real number
    for(j=0;j<ganttIndex[i];j++) {
      printf("%i ",ganttMatrix[i][j]); /*printf("*[%i][%i]*",i,j);*/
    }
    printf("\n");
    ganttIndex[i]=0;
  }

  return self;
}


- setGolem: g
{
  theGolem = g;

  return self;
}

- setTimeFilter: t
{
  theTimeFilter = t;

  return self;
}

- setEvaluator: ev
{
  theEvaluator = ev;

  return self;
}

- setOrdersToPlan: (int) o
{
  ordersToPlan = o;

  return self;
}

- setPUsLoaded: (int) p
{
  PUsLoaded = p;

  return self;
}

@end








