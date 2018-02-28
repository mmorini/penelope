// Order.m

#import "Order.h"
#import "Macro.h"

@implementation Order

- createEnd
{
  [super createEnd];
  return self;
}

- setSerNum: (int) sn
{
  sernum=sn;
  return self;
}

- (int) getSerNum
{
  return sernum;
}

- (int) getChainNum
{
  return strtol(data.chain,0,10);
}

- (char *) getChain
{
  return data.chain;
}

- printData
{
  
  L6(printf("[ORD] /-------------\n");)

    L6(printf("[ORD] # %i CHAIN<%s> |%s|%s|\n",
	      sernum, data.chain, data.flag1, data.flag2);)
    L6(printf("[ORD] CA/CC [%s] color [%s] comb [%6.2f]\n",
	     data.cacc, data.color, data.hcomb);)
    L6(printf("[ORD] saturation %5.1f%%\n[ORD] >%s<\n",
	     data.satperc, data.vec);)
  L6(printf("[ORD]                               -------------/\n");)

    //#define DBG(A) A
#define DBG(A) //

    DBG(
    {
      int qq;
      printf("---(%i): %s -------\n",sernum,data.chain);
      for(qq=0;qq<NUM_OF_SETUPS;qq++)
	printf("[%s] c0=%4.2f d0=%4.2f c1=%4.2f d1=%4.2f\n", data.costAndDurPerKind[qq].setup,
	       data.costAndDurPerKind[qq].cost0, data.costAndDurPerKind[qq].dur0,
	       data.costAndDurPerKind[qq].cost1, data.costAndDurPerKind[qq].dur1);
    }
)

  return self;
}

- setData: (struct rec_str) ord
{
  data = ord;
  return self;
}

- (struct rec_str) getData
{
   return data;
}

@end








