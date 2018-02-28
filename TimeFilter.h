// TimeFilter.h 

#import <objectbase/SwarmObject.h>
#import <stdlib.h>
#import <time.h>

@interface TimeFilter: SwarmObject
{

  char now_string[255];

}

- (time_t) getPresentTime;
- (char *) getPresentTimeAsString;
- (time_t) getAbsoluteTime: (char *) str;

/* - (int) getMinsFromString:  (char *) str; */
/* - (int) getHourFromString:  (char *) str; */
/* - (int) getDayFromString:   (char *) str; */
/* - (int) getMonthFromString: (char *) str; */
/* - (int) getYearFromString:  (char *) str; */

- createEnd;


@end


