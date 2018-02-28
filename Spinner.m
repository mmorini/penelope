// Spinner.m

#import <stdlib.h> //for malloc
#import "Spinner.h"
#import "Macro.h"

//#define DBG(A) A
#define DBG(A) //

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
  DBG(printf("[W%3i(%c)] getCosts returns: %10.4f\n",number,status,delayCost+setupCost);)
  return delayCost + setupCost;
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
  int famOffset=-1;   //what family shall we read the duration from
  int dlvOffset=-1;   //what day the order will be ready
  int i;
  int elapsed_t; //time since last step, in secs.
  float setupTime;

  setupTime = 0;

  elapsed_t = newtime-now; 
  now       = newtime;

  L7(printf("[W%3i(%c)] step\n",number,status);)

    if(([ordersQueue getCount] == 0) && (timeLeft <= 0))
      doneFlag = YES;

    if (([ordersQueue getCount] > 0) &&
	(timeLeft <= 0))
      {
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

      //SETUP TIME CALCULATOR

      [self findSetupNeededOffset];

      for(i=0;i<NUM_OF_SETUPS;i++) {
	if (usedSetupsVector[i] == 1) {
	  setupCost += (orderOn->data.costAndDurPerKind[i].cost0 *
			orderOn->data.costAndDurPerKind[i].dur0)
	    ;
	    }
      }

      ////////PRODUCTION DURATION//////////////
      timeLeft = setupTime + 
	((orderOn->data.durPerFam[famOffset].duration)*60);
      L7(
      printf("[W%3i(%c)] Start processing order #%i\n",number,status,[orderOn getSerNum]);
      printf("[W%3i(%c)] Setup time required is %5.2f hours\n",number,status,setupTime);

      printf("[W%3i(%c)] Total time to work on order %i: %6.2f hours.\n",
	     number, status, [orderOn getSerNum], ( (double) timeLeft/3600));
      )
	status = 'B';

      } 


 

    //    printf("DBG time left=%li\n",timeLeft);

  if(timeLeft > 0)
    { 

      if(orderOn->data.minplan < now) {
      
      timeLeft -= elapsed_t;
      L7(printf("[W%3i(%c)] Time left working on order %i: %6.2f hours.\n",
		number, status, [orderOn getSerNum], ( (double) timeLeft/3600));)

	if(timeLeft <= 0) status='D'; 

      } else {
	L7(
	   printf("[W%3i(%c)] Waiting for minimum planning date to come (order #%i, chain %s).\n",
		  number, status, [orderOn getSerNum],orderOn->data.chain);
	   printf("        time is now: %s",ctime(&now));
	   printf("        waiting for: %s",ctime(&orderOn->data.minplan));
	   )
	  
      }
      
    }
  
  if(status == 'D' && doneFlag != YES) {
    L7(printf("[W%3i(%c)] Order %i completed.\n",
	      number, status, [orderOn getSerNum]);)
      
    DBG(printf("DBG: PU %02i completed order %03i. %02i left in queue\n",number,orderOn->sernum,
	       [ordersQueue getCount]);)
      
      //DELIVERY OFFSET CALCULATOR
      if(strncmp(orderOn->data.flag1, PLAN_FLAG,1) == 0) { 
	
	for(i=0;i<COSTS_DAYS_SPAN;i++) {
	  if(orderOn->data.costPerDates[i].time >= now) {
	    dlvOffset=i;
	    break;
	  }
	}
	
	if(dlvOffset == -1) {
	  printf(
		 "[W%3i(%c)] Order #%i (chain %s) has no useful delivery cost data.\n",
		 number,status,orderOn->sernum,orderOn->data.chain);
	  printf("          completion time: %s",ctime(&now));
	  WARNING_HALT(exit(DLV_COST_OFFSET_SEARCH_FAILED);)
	    dlvOffset = COSTS_DAYS_SPAN-1;
	  
	  delayCost += orderOn->data.costPerDates[dlvOffset].cost;
	}
	
	delayCost += orderOn->data.costPerDates[dlvOffset].cost;
      } //end 'PLAN_FLAG' condition
  }
   
  return self;
}

- findSetupNeededOffset
{
  int i,j;
  char setups[NUM_OF_SETUPS][3];
  int  setup_p;
  char Ca[3], Ca_o[3];
  char Ro[3], Ro_o[3];
  char Ug[3], Ug_o[3];


  setup_p = 0; //initialize

  //printf("\n****CACC: |%s|-|%s|********\n\n",CaRoUg, orderOn->data.cacc);
  //strip setup components
  /*
  sscanf(CaRoUg,"%2c",     Ca);
  sscanf(CaRoUg,"%*3c%2c", Ro);
  sscanf(CaRoUg,"%*6c%2c", Ug);
  */

  strncpy(Ca,&cacc[0],2); 
  strncpy(Ro,&cacc[3],2); 
  strncpy(Ug,&cacc[6],2); 

  strncpy(Ca_o,&orderOn->data.cacc[0],2); 
  strncpy(Ro_o,&orderOn->data.cacc[3],2); 
  strncpy(Ug_o,&orderOn->data.cacc[6],2); 


  Ca[2]='\0';
  Ro[2]='\0';
  Ug[2]='\0';
  Ca_o[2]='\0';
  Ro_o[2]='\0';
  Ug_o[2]='\0';

  //printf("--- [%s] *** {%1s--%s--%s} ---\n",cacc,Ca,Ro,Ug);
  //printf("ord [%s] *** {%1s--%s--%s} ---\n\n",orderOn->data.cacc,Ca_o,Ro_o,Ug_o);
  //printf("------------------------\n");
  //find out kind of setups 

    //SPINNER:
    //SU - always
    //CA - if 'ca' changes in ca/ro/ug
    //RO - if 'ro' changes in ca/ro/ug
    //UG - if 'ug' changes in ca/ro/ug
    //printf("%s\n",cacc);

  strcpy(setups[setup_p], "SU"); //fixed setup, always happens
  setup_p++;

  if(strncmp(Ca,Ca_o,2) != 0) {
    strcpy(setups[setup_p], "CA"); //cardina change
    setup_p++;    
  }


  if(strncmp(Ro,Ro_o,2) != 0) {
    strcpy(setups[setup_p], "RO");
    setup_p++;    
  }

  if(strncmp(Ug,Ug_o,2) != 0) {
    strcpy(setups[setup_p], "UG");
    setup_p++;    
  }

  strcpy(cacc, orderOn->data.cacc);


  for(i=0;i<NUM_OF_SETUPS;i++) usedSetupsVector[i]=0;
  
  
  for(j=0;j<setup_p;j++) {
    
    for(i=0;i<=NUM_OF_SETUPS;i++) { //for every setup to find cycle through all
      
      //printf("%i--%i/%i -- <%c> <%c>\n",j,i, NUM_OF_SETUPS, *orderOn->data.costAndDurPerKind[i].setup, *setups[j]);      
      
      if(strncmp(orderOn->data.costAndDurPerKind[i].setup, setups[j], CRU_USED_CHARS) == 0)
	{
	  usedSetupsVector[i] = 1;
	  break;
	  if (i == NUM_OF_SETUPS) {
	    printf("Nonexistant setup kind found in data. Critical.\n");
	    exit(SETUP_KIND_SEARCH_FAILED);
	  }
	}
    }
    
  }
  
  /*
  DBG(
      for(i=0;i<NUM_OF_SETUPS;i++) {
	printf("---- %c %i\n",*orderOn->data.costAndDurPerKind[i].setup,usedSetupsVector[i]);
      }
      )
  */

  return self;
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
  obj->doneFlag   = NO;  

  //obj->now        = 0; //[][][]

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

      DBG(
	  printf("DBG spinner #%i enqueuing order %i\n",number,[[ordersQueue getLast] getSerNum]);
	  if( ((Order*) o)->setupFlag) printf(" (setup)\n");
	  )

	DBG(printf("DBG spinner %i queue length: %i\n",number,[ordersQueue getCount]);)
  
      return 0;
    }
}

- (int) emptyQueue
{
  int retval = 0;

  L7(
     printf("[W%3i] Trying to empty queue - %i items left.\n",
	    number,[ordersQueue getCount]);
     )
    
  if ([ordersQueue getCount] > 0) {
    printf("[W%3i] WARNING: Cleaning a non-empty orders queue (%i left). Increase REAL_TIME_SPAN.\n",
	   number,[ordersQueue getCount]);
    
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
  now = initial_simtime;

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
  ready = 'W';
  
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
  //printf("[W%2i]: busy until <%s>\n",number,busyUntill);
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
    strcpy(setupKind,"CA");
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
