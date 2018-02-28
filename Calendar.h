// Calendar.h 

//object calendar switches PUs 'on' and 'off' according to the work schedule provided

#import <objectbase/SwarmObject.h>

@interface Calendar: SwarmObject
{
  bool PUsActiveVector[REAL_TIME_SPAN];

}

- setPUsList: pul;

- createEnd;


@end


