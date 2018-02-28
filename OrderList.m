// OrderList.m

#import "OrderList.h"
#import "Macro.h"

@implementation OrderList

- createEnd
{
   OrderQueue=[List create: [self getZone]]; 
   OrderQueueIndex=[OrderQueue begin: [self getZone]];

   //SETUP orders list
   SetupQueue=[List create: [self getZone]]; 
   SetupQueueIndex=[SetupQueue begin: [self getZone]];

   zeroCompVectors = 0;
   setupOrders = 0;

   [super createEnd];
   return self;
}

- setDBInterface: theDBInterface
{
  myDBInterface = theDBInterface;
  return self;
}

- getNthSetupOrder: (int) son
{
  Order * anOrder;

  [SetupQueueIndex setOffset: son];
  anOrder = [SetupQueueIndex get];

  //printf("[OrdL] Got Setup Order #%i\n",[anOrder getSerNum]);

  return anOrder;

}


- getNthOrderFromList: (int) num // 0<num<(ql-1) is an OFFSET!
{
  Order * anOrder;
  int QLength;

  QLength = [OrderQueue getCount];

  if (QLength == 0) {
    printf("[ORDL] OrderQueue is empty. Should not happen...\n");
    exit(1);
  }

  [OrderQueueIndex setOffset: num]; //as usual, offset=num-1
  anOrder = [OrderQueueIndex get];

  return anOrder;
}



//Next method fills orderQueues with all the orders DBI can handle
- readNOrdersFromDB: (int) no
{
   Order * anOrder;
   struct rec_str tempOrderData;  
   int i=0;

   for (i=0;i<no;i++) {

     tempOrderData=[myDBInterface getOrder];

          //First of all, catch exceptions:
     if (strcmp(tempOrderData.code,"*end*") == 0) {
       L5(printf("[ORDL] Order creation failed: no more data available.\n");)
       return self;
     }

     //We have a regular data structure, proceed.
     anOrder = [Order createBegin: [self getZone]];

     [anOrder setData: tempOrderData]; //gets an order from DBI
     anOrder = [anOrder createEnd];

     if(strcmp(tempOrderData.flag1,PLAN_FLAG) == 0 ) //if yes, PLAN
       {
	 //check for all-zeroed vectors (may happen)
	 if(strchr(tempOrderData.vec, '1') == NULL) {
	   zeroCompVectors++;
	   printf("[ORDL] %4i all-zeroed or empty compatibility vectors in orders to plan found (skipping record around line %i). Please fix.\n", zeroCompVectors, [anOrder getSerNum]);
	 } else {
	   [anOrder setSerNum: sernum++];
	   [OrderQueue         addLast: anOrder];
	 }
       } else { //otherwise, use for setup
	 setupOrders++;
	 L5(printf("[ORDL] %4i setup orders read\n",setupOrders);)
	   [anOrder setSerNum: sernumsetup++];
	 [SetupQueue         addLast: anOrder]; //store for wsetupper
       }

     [anOrder printData];

   }

   return self;
}

- debug
{

  int i;
  int oq; //length

  oq=[OrderQueue getCount];

   for(i=0;i<oq;i++) {
     [OrderQueueIndex setOffset: i];
     printf("[ORDL] DEBUG: OQI order at %i is # %i\n",
	    i,[[OrderQueueIndex get] getSerNum]);
   }
  

  return self;
}

- (int) getQueueLength
{
  int ql;
  
  ql=[OrderQueue getCount];
  return ql;
}

- (int) getSetupLength
{
  int sl;

  sl=[SetupQueue getCount];
  return sl;
}

- saveNumToChainsFile
{

  int i;

  char ntcLine[256] ; 
  char ntcFileName[255];
  id <OutFile> ntcFile;

  strcpy(ntcFileName,ON2CH_FN);
  ntcFile = [OutFile create: [self getZone] setName: ntcFileName];


  if (ntcFile == nil) {
    printf("[OrdL] CRITICAL: Problem writing ORDERS to CHAINS file (%s) to disk...\n", ON2CH_FN);
    exit(0);
  }


  for(i=0;i<[OrderQueue getCount];i++) {
    [OrderQueueIndex setOffset: i];

    /*
    sprintf(ntcLine,"%7i#%6i%c%c",
	   [[OrderQueueIndex get] getChainNum],
	    [[OrderQueueIndex get] getSerNum],
	    CR,LF
	   );
    */

    sprintf(ntcLine,"%s#%6i%c%c",
	   [[OrderQueueIndex get] getChain],
	    [[OrderQueueIndex get] getSerNum],
	    CR,LF
	   );


    [ntcFile putString: ntcLine];


  }
  
  [ntcFile drop];

  return self;
}


@end








