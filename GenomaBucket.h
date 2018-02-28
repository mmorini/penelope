// GenomaBucket.h 

#import <objectbase/SwarmObject.h>

#import "defines.h"

//HASH table stuff
//#include <sys/types.h>
//#include <limits.h>
//#include <db1/db.h>

@interface GenomaBucket: SwarmObject
{
  struct item {
//    char  genoma[MAXGL];
    int genoma[MAXGL];
    float fitness;
    int occurrencies;
  } ;

  struct item lookupTable[ITEMS] ;

  int firstItemFree;
  BOOL fullTableFlag;

  int genomaTotalLength;

}
- setGenomaTotalLength: (int) gtl;

- storeGenoma: (int *) g hasFitness: (float) f;
- (float) getFitnessOfGenoma: (int *) g;

- createEnd;


@end


