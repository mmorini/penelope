// Order.h

#import <objectbase/SwarmObject.h>
#import <simtools.h>
#import <time.h>
#import "defines.h"
#import DBINTERFACE 

@interface Order: SwarmObject
{
@public
  int sernum;
  struct rec_str data; //encapsulated data (= 1 order)
}

- setSerNum: (int) sn;
- (int) getSerNum;
- (int) getChainNum;
- (char *) getChain; //as string

- printData;
- setData: (struct rec_str) ord;
- (struct rec_str) getData;

- createEnd;


@end


