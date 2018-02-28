// Evaluator.m                                        

#import "Evaluator.h"

@implementation Evaluator

- setGolem: g
{
  theGolem = g;

  return self;
}


- setGenomaBucket: gb
{
  theGenomaBucket = gb;

  return self;
}

- setDispatcher: d
{
  theDispatcher = d;

  return self;
}

#ifdef USE_TESTER
- setTester: t
{
  theTester = t;

  return self;
}
#endif

- setOrderList: ol
{
  theOrderList = ol;

  return self;
}

- setPUsLoaded: (int) pl
{
  PUsLoaded = pl;

  return self;
}

- setOrdersToPlan: (int) o
{
  ordersToPlan = o;
  return self;
}

- setPresentTime: (time_t) t
{
  start_t_initial = t;
  start_t = t;

  return self;
}

- step
{

  //get plan from theGolem
  aRule=[theGolem getActiveRule];

  [self realRun];

  return self;

}

- printConvergency
{
  [theGolem verify];

  printf("[EVA] GA convengercy rate: %5.2f (%i genomi)\n",
	 [theGolem getConvergency],[theGolem getNumberOfRules]);

  return self;
}

- createEnd
{
  GBInhibitor = NO;

   [super createEnd];

   return self;
}

#ifdef USE_TESTER
- benchStep1
{

  aRule=[theTester getFIFORule];
  [self realRun];

  printf("[EVA] FIFO Benchmark  - Fitness: %12.2f\n",fitness);

  return self;
}
#endif

#ifdef USE_TESTER
- benchStep2
{
  aRule=[theTester getRNDRule];
  [self realRun];      

  printf("[EVA] RND Benchmark  - Fitness: %12.2f\n",fitness);
 
  return self;
}
#endif


- (int) mapPUOntoCompatPU: (int) p forOrder: (int) ord
{

  Order * anOrder; //to get the PUs compatibility vector
  
  int goodWeavers=0;  //used to apply modulus operator
  int goodWeaversVector[MAX_WEAVERS];

  int compPU;
  int i;

  //printf("mapping pu # %i (For ord %i)\n",p,ord);
  anOrder = [theOrderList getNthOrderFromList: ord];

  // MAP assign ONLY on good weavers (check with compatVector) -- careful of offset
  for(i=0;i<PUsLoaded;i++) {
    if(strncmp(&anOrder->data.vec[i], "1", 1) == 0) {
      // printf("[%c] %i - %i\n",anOrder->data.vec[i],i,goodWeavers);
      goodWeaversVector[goodWeavers]=i;
      goodWeavers += 1;
    }
  }
  //Fix all-zeroed (wrong) vectors
  if(goodWeavers == 0) {
    printf("[EVA] All-zeroed compatibility vector in getOrder (order %i - %s). Should not happen.\n",
	   anOrder->sernum,anOrder->data.chain);
    exit(1);
    //for(i=0;i<weaverNumber;i++) orderData.vec[i]='1';
  }
  
  compPU=(goodWeaversVector[p%goodWeavers]);
  //printf("mapped to pu: %i\n",compPU);


  return compPU;

}



- realRun
{

  //get plan from theGolem

  //aRule=[theGolem getActiveRule];

  //aRule=[theTester getRNDRule];
  //aRule=[theTester getFIFORule];


#ifdef USE_GB
  fitness=[theGenomaBucket getFitnessOfGenoma: aRule];

  //printf("DEBUG: GBInhibitor = %i\n", GBInhibitor);

  HITS(trys++;)
    if(fitness == 0 || GBInhibitor) { //no pre-calculated genoma found in GB - RUN MODEL ____
                                      // if GBInhibitor == YES then force RUN MODEL
      HITS(misses++;)
	
#endif

      
      { //***********REAL RUN****************
      int q, no, pu;
      time_t time_i;
      int time_step=theDispatcher->stepDelta;   //seconds
      int time_run=REAL_TIME_SPAN; //simulation lasts n seconds

      start_t = start_t_initial; //also reset self;
      
      [theDispatcher cleanQueues];
      [theDispatcher resetTimers]; //init to initial simulated time
      [theDispatcher resetCosts];
      [theDispatcher resetCacc];
      [theDispatcher resetDoneFlag];



      //enqueue orders <<<<<<<<<<<<<<<<<<<<

      //first of all, assign 'setup' orders:

      [theDispatcher assignSetupOrders];

      //then , real orders decoded from the rule body

      for(q=0;q<ordersToPlan;q++)
	{
	  no=aRule[q]; //order
	  pu=aRule[q+ordersToPlan]; //PU found at ordersToPlan offset

	  //printf("correcting body - remapping order %02i from PU %02i",no,pu);
	  /*correct with COMPATIBILITY VECTOR --- TEMPORARY WORKAROUND*/
	  pu = [self mapPUOntoCompatPU: pu forOrder: no];
	  /************************************************************/
	  //printf(" onto PU %02i\n",pu); //@#@#
	  [theDispatcher assignNthOrder: no toPU: pu];
    	}

      //then, assign 'last-orders' to cap working loop in PUs
      //     [theDispatcher assignLastOrders]; //@#@#@#


      //run simulated time <<<<<<<<<<<<<<<<
      for(time_i=start_t;time_i<start_t+time_run;time_i+=time_step) {
      L19(printf("[EVA] Simulated time is now: %s",
		 ctime(&time_i));)
	if([theDispatcher checkIfDone] == 1) break; //if all queues are empty stop @#@#CHECK!!!

      [theDispatcher broadcastStepToTime: time_i];
      }

      fitness = -([theDispatcher getCosts]);

      printf("[EVA]    Cost details: setup = %8.2f; delay = %8.2f (aggregate = %8.2f)\n",
	     [theDispatcher getSetupCosts],[theDispatcher getDelayCosts],[theDispatcher getCosts]);


    }
#ifdef USE_GB
    //***********
      [theGenomaBucket storeGenoma: aRule hasFitness: fitness];
  }
#endif

  [theGolem setReward: fitness];

  HITS(
       printf("[%5.2f%% hits (%i out of %i)]\n",(float) (trys-misses)/trys*100,trys-misses,trys);
       )


  printf("[EVA] MinFitness: %12.2f - MaxFitness: %12.2f\n",[theGolem getMinFitness],[theGolem getMaxFitnessEver]);
 

  return self;
}

@end








