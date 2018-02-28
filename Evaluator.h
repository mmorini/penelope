// Evaluator.h 
#import "defines.h"
#import  "Macro.h"
#import <objectbase/SwarmObject.h>

#import "Golem.h"
#import "GenomaBucket.h"
#import "Dispatcher.h"
#import "OrderList.h"

#ifdef USE_TESTER
#import "Tester.h"
#endif

//--------------------------------------------------------------------
@interface Evaluator: SwarmObject
{
   int     lengthOfGenoma;

   int ordersToPlan;
   GenomaBucket           * theGenomaBucket;
   Golem                  * theGolem;
   Dispatcher             * theDispatcher;
   OrderList              * theOrderList;
#ifdef USE_TESTER
   Tester                 * theTester;
#endif

   int*   aRule;
   float fitness;

   time_t start_t_initial, 
     start_t; //time the simulation starts (or is supposed to)

   int PUsLoaded;
   
#ifdef _HITS
   int trys, misses; //cache efficiency
#endif

@public
   BOOL GBInhibitor; //to force runs (no cached results)
}

- setGenomaBucket:            gb;
- setGolem:                    g;
- setDispatcher:               d;

#ifdef USE_TESTER
- setTester:                   t;
#endif

- setOrderList:               ol;

- setPUsLoaded:          (int) p;
- setOrdersToPlan:       (int) o;

- setPresentTime:     (time_t) t;

- step;

- printConvergency;

- createEnd;

#ifdef USE_TESTER
- benchStep1;
- benchStep2;
#endif


- (int) mapPUOntoCompatPU: (int) pu forOrder: (int) ord;

- realRun;

@end


