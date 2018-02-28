// OrderList.h

#import <objectbase/SwarmObject.h>
#import <simtools.h>

#import "defines.h"
#import DBINTERFACE
#import "Order.h"


@interface OrderList: SwarmObject
{
  id <List> OrderQueue;
  id <Index> OrderQueueIndex;

  id <List> SetupQueue;
  id <Index> SetupQueueIndex;

  QSort * listSorter;

  int sernum;     
  int sernumsetup;

  DBInterface * myDBInterface;

  int zeroCompVectors, setupOrders;
}

- createEnd;

- setDBInterface: myDBInterface;

- getNthSetupOrder: (int) son;

- getNthOrderFromList: (int) num;


- readNOrdersFromDB: (int) no; 

- (int) getQueueLength;
- (int) getSetupLength;

- saveNumToChainsFile;

@end





