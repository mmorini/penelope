// GenomaBucket.m                                        

#import "GenomaBucket.h"
#import "Macro.h"

#include <stdlib.h> //exit() 
#include <sys/time.h>


@implementation GenomaBucket

- storeGenoma: (int *) g hasFitness: (float) f
{

  L16(
      if(firstItemFree%LOG_FREQ == 0)
      printf("[GnB] used slots: %i\n",
	     (fullTableFlag ? ITEMS : firstItemFree)
	     );
      )
    
  /*---------------------------------*/

    firstItemFree++;
    if(firstItemFree >= ITEMS) {

      printf("[GnB] Hashtable full; overwriting older items.\n");
      firstItemFree=0;
      fullTableFlag = YES;

    }
    
    lookupTable[firstItemFree].occurrencies++;
    lookupTable[firstItemFree].fitness=f;

    //copy the array of integers into a record
    {
      int i;
      
      for(i=0;i<genomaTotalLength;i++) {
	lookupTable[firstItemFree].genoma[i]=g[i];
      }
    }    
    
    //    strcpy(lookupTable[firstItemFree].genoma,g);//memcpy? @#@#@#    
  
  return self;
}

- (float) getFitnessOfGenoma: (int *) g;
{
float fitness;
int i, j;

//20021230 MM
#ifdef _LOG16
struct timeval tm0, tm1;
gettimeofday(&tm0,NULL);
#endif

  fitness=0;

  // if table is full and new items overwritten search it all, else only
  // stored items

  //printf("DEBUG fullTableFlag = %i; lookup %i items\n", (int) fullTableFlag,(fullTableFlag ? ITEMS : firstItemFree));

  for(i=(fullTableFlag ? ITEMS : firstItemFree);i>=0;i--) {
 
      for(j=0;j<=genomaTotalLength;j++) {
	//printf("DEBUG: comparing item %i\n",j);
	if(lookupTable[i].genoma[j] != g[j]) {
	  //printf("DEBUG: +++ compare failed at item %i\n",j);
	  break;
	}
	else if (j == genomaTotalLength) { //if last item = then genomas are =
	  fitness=lookupTable[i].fitness;
	  lookupTable[i].occurrencies++;
	} 
      }
  }

#ifdef _LOG16
  gettimeofday(&tm1,NULL);
  if(firstItemFree%100 == 0) {
    long int s_t, e_t, d_t;
    int items;

    s_t=tm0.tv_sec*1000000 + tm0.tv_usec;
    e_t=tm1.tv_sec*1000000 + tm1.tv_usec;
    d_t=e_t-s_t;
    items=( fullTableFlag ? 
	    ITEMS
	    :
	    (firstItemFree == 0 ? 1 : firstItemFree)
	    );
    
    printf("[GnB] %i-elements table lookup took: %li microseconds (%f usec/item) - ",
	   items, d_t, (double) (d_t/(double)items));
    if ( i == -1) printf("no hits\n");
    else printf("hit item #%i\n",i);

  }
#endif

  return fitness;
}

- createEnd
{
  id obj;
  int i;
  firstItemFree=-1;
  fullTableFlag = NO;

  for(i=0;i<ITEMS;i++) {
    lookupTable[i].occurrencies=0;
    lookupTable[i].fitness=0;
    //    strcpy(lookupTable[i].genoma,"");//initialize vector
  }

   obj=[super createEnd];

   return obj;
}

- setGenomaTotalLength: (int) gtl
{
  genomaTotalLength = gtl;

  return self;
}

@end








