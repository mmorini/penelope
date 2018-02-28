//GolemNews.h
//--------------------------------------------------------------------
#import <objectbase/SwarmObject.h>
#import "GolemParms.h"
@interface GolemNews: SwarmObject
//--------------------------------------------------------------------
{
   @public
   int   body[MAX_RULE_LENGTH];
}
//--------------------------------------------------------------------
//CreateBegin and createEnd 
-              createEnd;
//Setters and getters
- (int*)       getBody;
-              printWithLength: (int) iV;
//--------------------------------------------------------------------
@end
