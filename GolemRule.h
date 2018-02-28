//GolemRule.h
//--------------------------------------------------------------------
#import <objectbase/SwarmObject.h>
#import "GolemParms.h"
@interface GolemRule: SwarmObject
//--------------------------------------------------------------------
{
   @public
   int   body[MAX_RULE_LENGTH];
   float fitness;
   float saveFitness;
   int   copies;
   char  willDie;
   char  willGenerate;
}
//--------------------------------------------------------------------
//CreateBegin and createEnd 
-              createEnd;
//Setters and getters
-              setFitness:      (float) fV;
-              setSaveFitness:  (float) fV;
-              setCopies:       (int)   iV;
-              setWillDie:      (char)  cV; 
-              setWillGenerate: (char)  cV;
- (int*)       getBody;
- (float)      getFitness;
- (float)      getSaveFitness;
- (int)        getCopies;
- (char)       getWillDie;
- (char)       getWillGenerate;
-              printWithLength: (int)   iV;
//--------------------------------------------------------------------
@end
