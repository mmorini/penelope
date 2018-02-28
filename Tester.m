// Tester.m                                        

#import "Tester.h"

#import <stdlib.h> //random

@implementation Tester

- buildRules:  (id<Zone>) z
{

  FIFORule = [GolemRule createBegin: z];
  [FIFORule createEnd];

  RNDRule = [GolemRule createBegin: z];
  [RNDRule createEnd];

  return self;
 
}

- makeFIFORule
{
  Order *anOrder;
  int i,j;

  int  gantt[MAX_WEAVERS][MAX_ORDERS]; //final 'fifo' gantt
  char last_loaded[MAX_WEAVERS][255];  //'last' cacc loaded
  int  pu_index[MAX_WEAVERS];          //pointer to last slot per PU
  int  pu_rev_index;                   //pointer for unmatched orders

  int rule_index;

  int match_flag=0;

  for(i=0;i<PUsLoaded;i++) {pu_index[i]=0;}
  for(i=0;i<PUsLoaded;i++) //init gantt (-1 = empty slot)
    {
      for(j=0;j<MAX_ORDERS;j++) {gantt[i][j]=-1;}
    }
  
  pu_rev_index=PUsLoaded-1;

  //#define DBG(A) A
#define DBG(A) //

  for(i=0;i<ordersToPlan;i++) {
    anOrder=[theOrderList getNthOrderFromList:i];
    DBG(printf("...got order #%i (cacc %s)\n",anOrder->sernum,anOrder->data.cacc);)
    
    match_flag=0;
    for(j=0;j<PUsLoaded;j++) {
      DBG(printf("comparing [%s]-[%s] (PU %i)\n",anOrder->data.cacc,last_loaded[j],j);)
      if (strncmp(anOrder->data.cacc,last_loaded[j],FIFO_MATCHING_CHARS) == 0) {
	match_flag=1;
	gantt[j][pu_index[j]]=i;
	pu_index[j]++;
	strncpy(last_loaded[j],anOrder->data.cacc,FIFO_MATCHING_CHARS);	
	DBG(printf("Order %i -> PU %i \n",anOrder->sernum,j);)
	break;
      } 
    }

    //if not matched...
    if (match_flag == 0) {
      DBG(printf("Order %i -> PU %i (UNMATCH)\n",anOrder->sernum,pu_rev_index);)
      gantt[pu_rev_index][pu_index[pu_rev_index]]=i;
      pu_index[pu_rev_index]++;
      strncpy(last_loaded[pu_rev_index],anOrder->data.cacc,FIFO_MATCHING_CHARS);
      pu_rev_index--;
      if(pu_rev_index < 0) pu_rev_index = PUsLoaded-1; //rewrap
    }
    
    
  }
  
  /*
  printf("DEBUG FIFO\n");
  for(i=0;i<PUsLoaded;i++) {
    printf("PU: %i***\n",i);    
    for(j=0;j<ordersToPlan;j++) {
      printf("%3i ",gantt[i][j]);
    }
    printf("\n----------\n");
  }
  printf("DEBUG FIFO--end--\n");
  */
  
  rule_index=0;
  for(i=0;i<PUsLoaded;i++) {
    for(j=0;j<ordersToPlan;j++)
      {
	if(gantt[i][j] == -1) break;

	FIFORule->body[rule_index]              = gantt[i][j]; //order number
	FIFORule->body[rule_index+ordersToPlan] = i; //PU number
	rule_index++;
      }
  }


  printf("FIFORule: ");
  for(i=0;i<ordersToPlan;i++) 
    printf("(%i->%i) ", FIFORule->body[i], FIFORule->body[i+ordersToPlan]);
  printf("\n");

  return self;
}

- makeRNDRule
{
  int i;
  int randpu;

  srand(26071974);

  for(i=0;i<ordersToPlan;i++) {

    randpu = (int) ((double) (PUsLoaded) * rand() / RAND_MAX);

    RNDRule->body[i]              = i; //order number
    RNDRule->body[i+ordersToPlan] = randpu;
  }

  printf("RNDRule: ");
  for(i=0;i<ordersToPlan;i++) 
    printf("(%i->%i) ", RNDRule->body[i], RNDRule->body[i+ordersToPlan]);
  printf("\n");

  return self;
}

- (int *) getRNDRule
{
  return RNDRule->body;
}

- (int *) getFIFORule
{
  return FIFORule->body;
}

- createEnd
{

   [super createEnd];

   return self;
}

- setOrdersToPlan: (int) o
{
  ordersToPlan = o;
  return self;
}

- setPUsLoaded:    (int) p
{
  PUsLoaded = p;
  return self;
}

- setOrderList: ol
{
  theOrderList = ol;

  return self;
}

@end








