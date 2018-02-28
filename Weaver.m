// Weaver.m

#import <stdlib.h> //for malloc
#import "Weaver.h"
#import "Macro.h"

@implementation Weaver

- setInitialSimTime: (time_t) t
{
  L7(printf("[W%3i(X)] Initial sim time set to: %s",number,ctime(&t));)

  initial_simtime = t;
  now = t;

  return self;
}

- resetCost
{
  delayCost = 0;
  setupCost = 0;
  return self;
}


- resetCacc
{
  strcpy(cacc,PU_INITVAL);

  return self;
}

- resetDoneFlag
{
  doneFlag = NO;

  return self;
}


- (float) getCosts
{
  return delayCost + setupCost; //+ bla bla cost...
}

- (float) getDelayCosts
{
  return delayCost;
}

- (float) getSetupCosts
{
  return setupCost;
}



- (float) getDeliveryCost
{
  return delayCost;
}

- stepToTime: (time_t) newtime;
{
  int famOffset=-1;  
  int dlvOffset=-1;  
  int setupOffset=-1;
  //int setupOffsets[NUM_OF_SETUPS]; //vector: 0, 1 for each setup offset


  int i;
  
  int elapsed_t;

  float setupTime;

  setupTime = 0;

  elapsed_t = newtime-now; 
  now       = newtime;

  L7(printf("[W%3i(%c)] step\n",number,status);)

  if ([ordersQueue getCount] > 0) {
    if(timeLeft <= 0) {

      orderOn=[ordersQueue removeFirst];
      
      //FAMILY OFFSET CALCULATOR
      for(i=0;i<NUM_OF_FAMILIES;i++) {
	if(strncmp(orderOn->data.durPerFam[i].family, family, 1) == 0) {
	  famOffset = i;
	  break;
	}
      }

      if (famOffset == -1) {
	printf("[W%3i(%c)] Order #%i (chain %s) has no useful duration data.\n",
	       number,status,orderOn->sernum,orderOn->data.chain);
	exit(DUR_FAM_OFFSET_SEARCH_FAILED);
      }
      //////////////////////////

      //SETUP TIME CALCULATOR

      setupOffset = [self findSetupNeededOffset]; 

      setupCost += (orderOn->data.costAndDurPerKind[setupOffset].cost0 *
		    orderOn->data.costAndDurPerKind[setupOffset].dur0)
	; //'cycle' cost (=hourly 'man' cost * man/hours)
      setupTime  = orderOn->data.costAndDurPerKind[setupOffset].dur1;  //DUR0? 'cycle' time

      //printf("@@@@ %f\n",orderOn->data.costAndDurPerKind[setupOffset].cost0);
      //printf("***%i***\n",setupOffset); //DBG

      //[setuppersPoller askForTime: orderOn->data.setupCostPerKind[setupOffset].dur1;];


      ///////////////////////

      //     printf("[W%3i(%c)] DBG order %f mins long added. \n",number,status,
      //     orderOn->data.durPerFam[famOffset].duration);

      ////////PRODUCTION DURATION//////////////

      timeLeft = setupTime*SETUP_TIMES_COEFF_TO_SECS + 
	((orderOn->data.durPerFam[famOffset].duration)*DURATIONS_COEFF_TO_SECS);

      L7(
      printf("[W%3i(%c)] Start processing order #%i (%s)\n",number,status,[orderOn getSerNum],orderOn->data.flag1);
      printf("[W%3i(%c)] Setup time required is %5.2f hours\n",number,status,setupTime);

      printf("[W%3i(%c)] Total time to work on order %i: %6.2f hours (%6.2f is setup).\n",
	     number, status, [orderOn getSerNum], ( (double) timeLeft/3600), ((double) setupTime));
      )

      status = 'B';
      
    } else {

      timeLeft -= elapsed_t;

      if(timeLeft > 0) {
      L7(printf("[W%3i(%c)] Time left working on order %i: %6.2f hours.\n",
		number, status, [orderOn getSerNum], ( (double) timeLeft/3600));)
      } else {
	L7(printf("[W%3i(%c)] Order %i completed.\n",
		  number, status, [orderOn getSerNum]);)

	//DELIVERY OFFSET CALCULATOR
	  if(strncmp(orderOn->data.flag1, PLAN_FLAG,1) == 0) { 

	    for(i=0;i<COSTS_DAYS_SPAN;i++) {

#define DBG(A) //
	      DBG(
		  printf("DBG offset is: %2i(%2i) - %s",
			 dlvOffset,i,ctime(&orderOn->data.costPerDates[i].time));
		  printf("                         %s",ctime(&now));
		  
	  	  printf("TIME: [%li] vs [%li]\n",
	  		 (long int) (orderOn->data.costPerDates[i].time),
	  		 (long int) now);
		  )
		
		if(orderOn->data.costPerDates[i].time >= now) {
		  dlvOffset=i;
		  break;
		}
	    }

	    if(dlvOffset == -1) {
	      printf("[W%3i(%c)] Order #%i (chain %s) has no useful delivery cost data.\n",
		     number,status,orderOn->sernum,orderOn->data.chain);
	      WARNING_HALT(exit(DLV_COST_OFFSET_SEARCH_FAILED);)
		dlvOffset = COSTS_DAYS_SPAN-1; 
	      
	      delayCost += orderOn->data.costPerDates[dlvOffset].cost;
	    }
	    delayCost += orderOn->data.costPerDates[dlvOffset].cost;
	  }
      }
    } 
    
  } else {
    status = 'I';
    L7(printf("[W%3i(%c)] No orders left in queue.\n",number,status);)
      }
  

  return self;
}

- (int) findSetupNeededOffset
{
  int i;
  char setup[3];
  int sOff=0; //setup offset


  //printf("+++ %s|%s\n",orderOn->data.cacc,cacc); //DBG

  //find out kind of setup 
  //WEAVER:

  //different CAs -> 'CAMBIO', CA (always 'medio', not correct but this was the spec)
  //     same CAs -> 'ANNODATURA', AF/AD
  //                  + AF if new rnote >= old rnote
  //                  + AD if new rnote <  old rnote

    if(strncmp(cacc, orderOn->data.cacc,CACC_SIG_CHARS) != 0) {
      //      setupCycleTime = orderOn->data.costAndDurPerKind
      strcpy(setup,"CM");
    } else {
      strcpy(setup,"AD"); //speedy trick, setup=ad, if exception overwrite
      if(orderOn->data.rnote >= rnote) {
	strcpy(setup,"AF");	
      }
      
    }

    //printf("----- [old %i -> new %i] (%s)\n",rnote,orderOn->data.rnote,setup);

    //printf("+++++ <%s> <%s>\n",cacc, orderOn->data.cacc);

    //UPDATE IVARS
    strcpy(cacc, orderOn->data.cacc);
    rnote = orderOn->data.rnote;
    

    //printf("********** %s *************\n",setup);
    
    //find out offset of found kind of setup on row
    for(i=0;i<NUM_OF_SETUPS;i++) {
      //printf("]]]]] attempting ]]]] %i (%s-%s)\n",i,orderOn->data.costAndDurPerKind[i].setup,setup);
      //printf("%s|%s\n",orderOn->data.costAndDurPerKind[i].setup,setup); //DBG
      if(strncmp(orderOn->data.costAndDurPerKind[i].setup,setup,2) == 0)
      {
	sOff = i;
	break;
      }
    }
    //printf(" ------OFF %i\n",sOff);
    return sOff;
}


+ createBegin: aZone
{
  Weaver *obj;
  
  obj=[super createBegin: aZone];
  obj->desc       = (char *) malloc(41); //Rick Riolo Dixit Nov 1999
  obj->busyUntill = (char *) malloc(31);
  obj->cacc       = (char *) malloc(21);
  obj->hcomb_tolerance = HCOMB_TOL;
  obj->setupKind  = (char *) malloc(5);
  obj->color      = (char *) malloc(2);

  return obj;
}

- (int) enqueue: o
{

  if ([ordersQueue getCount] >= MAX_ORDERS) {
    return -1;
  }
  else
    {
      [ordersQueue addLast: o];
      [[ordersQueue getLast] printData];
      //printf("DBG weaver #%i enqueuing order %i\n",number,[[ordersQueue getLast] getSerNum]);
      //printf("DBG weaver %i queue length: %i\n",number,[ordersQueue getCount]);
  
      return 0;
    }
}

- (int) emptyQueue
{
  int retval = 0;

  if ([ordersQueue getCount] != 0) {
    printf("[W%3i] WARNING: Cleaning a non-empty orders queue. Increase REAL_TIME_SPAN.\n",number);
    
    retval = -1;
    exit(INSUFFICIENT_SIM_RUN_TIME);
  }

  [ordersQueue removeAll];
  return retval;
}

- (int) getQueueLength
{
  return [ordersQueue getCount];
}

- resetTimer
{
  timeLeft = 0;

  return self;
}


- setNumber: (int) n
{
   number = n;
   return self;
}

- (int) getNumber
{
  return number;
}


- setDesc: (const char *) d
{
  strcpy(desc,d);
  return self;
}

- (const char *) getDesc
{
  return desc;
}

- setHeads: (int) h
{
  heads=h;
  return self;
}

- (int) getHeads
{
  return heads;
}

- createEnd
{
  ordersQueue=[List create: [self getZone]]; 
  ordersQueueIndex=[ordersQueue begin: [self getZone]];

  timeLeft = 0; //nothing to do in the beginning
  status = 'I';

   [super createEnd];
   return self;
}

- setFamily: (char *) f
{
   strcpy(family,f);
   return self;
}

- (char *) getFamily
{
  return family;
}

- setRotor: (int) r
{
  if (rotor != r) {
    rotor = r;
    rotor_xchg = 1;
  } else {
    rotor_xchg = 0;
  }

  return self;
}

- (int) getRotor
{
  return rotor;
}

- setCard: (int) c
{
  if (card != c) {
    card = c;
    card_xchg = 1;
  } else {
    card_xchg = 0;
  }

  return self;
}

- (int) getCard
{
  return card;
}

- setNozzle: (int) n
{
  if (nozzle != n) {
    nozzle = n;
    nozzle_xchg = 1;
  } else {
    nozzle_xchg = 0;
  }

  return self;
}

- (int) getNozzle
{
  return nozzle;
}

- setSpeed: (int) s
{
  speed = s;
  return self;
}

- (int) getSpeed
{
  return speed;
}

- setOrderNumber: (int) ornum
{
  lastOrderNumber = ornum;
  return self;
}

- (int) getOrderNumber
{
  return lastOrderNumber;
}


- (float) getTimeWasted;
{
  return timeWasted; //in minutes
}

- setAvailability: (time_t) t
{
  avail=t;
  sscanf(ctime(&avail),"%24c",busyUntill);
  return self;
}

- (time_t) getAvailability;
{
  return avail;
}

- setCacc: (char *) c
{
  strcpy(cacc,c);
  return self;
}

- (char *) getCacc
{
  return cacc;
}

- setHComb: (float) h
{
  // printf("setHcomb: %f -> %f\n",hcomb,h);
  if(hcomb != h) {
    if(abs(hcomb-h)>hcomb_tolerance) {
      hcomb_delta = 2; //'CD', big change
    } else {
      hcomb_delta = 1; //'CM', avg change
    }
    hcomb = h;
  } else {
    hcomb_delta = 0; //'CF', easy change
  }

  return self;
}

- (float) getHComb
{
  return hcomb;
}

- setColor: (char *) c
{
  if (strcmp(color,c) != 0) {
    color_xchg = 1;
    strcpy(color, c);
  } else {
    color_xchg = 0;
  }
  return self;
}

- (char *) getColor
{
  return color;
}

- (char *) getSetupKindA
{
  if (cacc_xchg == 0) {
    strcpy(setupKind,"CA"); //annodatura
  } else {
    switch (hcomb_delta) {
    case 0  : strcpy(setupKind,"CF"); break;
    case 1  : strcpy(setupKind,"CM"); break;
    case 2  : strcpy(setupKind,"CD"); break;
    default : printf("[Wvr] Ooops... internal error in getSetupKind.\n"); exit(1); 
    }
  }
  
  return setupKind;
}

- (int) getSetupKindB
{
  return color_xchg;
}

- (BOOL) checkIfDone
{ 
  return doneFlag;
}


@end





