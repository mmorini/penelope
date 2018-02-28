// Setupper.h 

#import <objectbase/SwarmObject.h>

@interface Setupper: SwarmObject
{
	BOOL busy; //the entity current state
	int ticksBusyLeft; //ticks left before
}

- (BOOL) setBusyTicks: (int) bt
- createEnd;


@end


