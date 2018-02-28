// Setupper.m                                        

#import "Setupper.h"

@implementation Setupper

- (BOOL) setBusyTicks: (int) bt;
{
	if (busy == TRUE) return FALSE;

	ticksBusyLeft=bt;

	return TRUE;
}

- step
{
	if (busy == TRUE) ticksBusyLeft--;

	return self;
}

- createEnd
{

   [super createEnd];

   return self;
}


@end








