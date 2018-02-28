// Dispatcher.m                                        

#import "Dispatcher.h"

@implementation Dispatcher

- broadcastStepToTime: (time_t) t;
{
  int i;

  for(i=0;i<PUsNumber;i++) {
    [[PUsList atOffset: i] stepToTime: t];
  }

  //[PUsList forEach: M(stepToTime:) : t]; //perhaps randomize execution order

  return self;
}

- (BOOL) checkIfDone
{
  int i;
  BOOL done = 1; 


  for(i=0;i<PUsNumber;i++) {
    if([[PUsList atOffset: i] getQueueLength] != 0) {
      done = 0; 
      break;
    }
  }

  return done;
}

- setStepDelta: (int) sd;
{
  stepDelta = sd;

  return self;
}

- setSetupOrders: (int) so
{
  setupOrders = so;
  return self;
}

- assignSetupOrders
{
  
  Weaver  *PU;
  Order   *ord;
  int i;
  int pu;

  for(i=0;i<setupOrders;i++) {  

    L20(
	printf("[DSP] About to pick order #%i from setup list.\n",i);
	)
    ord = [theOrderList getNthSetupOrder: i];
    L20(
	printf("[DSP] Order has code %s.\n",ord->data.chain);
	)


    L20(
	printf("[DSP] About to select PU #%i from order.\n",ord->data.pu);
	)
    pu = ord->data.pu;

    L20(
	printf("[DSP] About to map PU to PU offset in list (%i).\n",pu - W_OFFSET);
	)
    //need to map PUs# as read from file to the internal range, always 0:PUs#-1
    PU = [PUsList atOffset: pu - W_OFFSET];
    
    L20(printf("[DSP] Enqueuing setup order #%i on PU #%i\n",[ord getSerNum],[PU getNumber]);)
      if([PU enqueue: ord] != 0) {
	printf("[DSP] Production Unit Queue Length exceeded. Aborting.\n");
	exit(PU_QUEUE_OVERFLOW);
      }
  }

  L20(printf("[DSP] %i Setup orders enqueued.\n",i-1);)

  return self;
}

- assignNthOrder: (int) no toPU: (int) pu
{
  Weaver  *PU; //generic production unit
  Order   *ord;

  //PU  = [PUsListIndex setOffset: pu];
  PU = [PUsList atOffset: pu];
  ord = [theOrderList getNthOrderFromList: no];

  L20(printf("[DSP] Enqueuing order #%i on PU #%i\n",[ord getSerNum],[PU getNumber]);)

  if([PU enqueue: ord] != 0) {
    printf("[DSP] Production Unit Queue Length exceeded. Aborting.\n");
    exit(PU_QUEUE_OVERFLOW);
  }
  return self;
}

- cleanQueues
{

  [PUsList forEach: M(emptyQueue)];

  return self;
}

- resetTimers
{
  [PUsList forEach: M(resetTimer)];

  return self;
}

- resetCosts
{
  [PUsList forEach: M(resetCost)];

  return self;
}


- resetCacc
{
  [PUsList forEach: M(resetCacc)];

  return self;
}

- resetDoneFlag
{
  [PUsList forEach: M(resetDoneFlag)];

  return self;
}


- (float) getCosts
{
  int i;
  float totCosts=0;

  for(i=0;i<PUsNumber;i++) {
    totCosts += [[PUsList atOffset: i] getCosts];
  }

  return totCosts;
}

- (float) getDelayCosts
{
  int i;
  float totCosts=0;

  for(i=0;i<PUsNumber;i++) {
    totCosts += [[PUsList atOffset: i] getDelayCosts];
  }

  return totCosts;
}

- (float) getSetupCosts
{
  int i;
  float totCosts=0;

  for(i=0;i<PUsNumber;i++) {
    totCosts += [[PUsList atOffset: i] getSetupCosts];
  }

  return totCosts;
}
- setPUsList: pul
{
  PUsList = pul;

  return self;
}

- setPUsListIndex: puli
{
  PUsListIndex = puli;

  return self;
}

- setPUsNumber: (int) pn
{
  PUsNumber = pn;
  return self;
}

- setOrderList: ol
{
  theOrderList = ol;

  return self;
}

- createEnd
{

   [super createEnd];

   return self;
}


@end








