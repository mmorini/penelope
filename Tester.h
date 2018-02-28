// Tester.h 

#import <objectbase/SwarmObject.h>
#import "GolemRule.h" //borrow data struct
#import "OrderList.h"     //FIFO inspects orders
#import "Order.h"

@interface Tester: SwarmObject
{
  GolemRule* RNDRule;
  GolemRule* FIFORule;

  int ordersToPlan;
  int PUsLoaded;
 
  OrderList* theOrderList;
 
}

- setOrderList: ol;

- setOrdersToPlan: (int) o;
- setPUsLoaded:    (int) p;

- buildRules: (id<Zone>) z;
- makeFIFORule;
- makeRNDRule;

- (int *) getRNDRule;
- (int *) getFIFORule;

- createEnd;


@end


