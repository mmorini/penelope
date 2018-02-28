// Dispatcher.h 

#import <objectbase/SwarmObject.h>
#import "defines.h"

#import "OrderList.h" //and OrderList
#import "Order.h"
#import PU_KIND
#import "Macro.h" //LOG20

@interface Dispatcher: SwarmObject
{
  //external references (lists are made in modelswarm)
  id <List>      PUsList;
  id <ListIndex> PUsListIndex;
  int            PUsNumber;
  OrderList     *theOrderList;
  int            setupOrders; //speedup if known here

@public
  int stepDelta;
}

- setPUsList:           pul;
- setPUsListIndex:     puli;
- setPUsNumber:    (int) pn;
- setOrderList:        ordl;

- setSetupOrders: (int)  so;

- assignSetupOrders;
- assignNthOrder: (int) no toPU: (int) pu;

- cleanQueues;
- resetTimers;
- resetCosts;
- resetCacc;
- resetDoneFlag;


- (float) getCosts;
- (float) getSetupCosts;
- (float) getDelayCosts;

- setStepDelta: (int) sec; //seconds between each step
- broadcastStepToTime: (time_t) t;
- (BOOL) checkIfDone;


- createEnd;


@end


