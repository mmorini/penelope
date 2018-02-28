// BatchSwarm.h

#import "ModelSwarm.h"
#import <simtoolsgui/GUISwarm.h>

@interface BatchSwarm: Swarm
{
  int displayFrequency;                  // one parameter: update freq

  id displayActions;                     // schedule data structs
  id displaySchedule;

  ModelSwarm *modelSwarm;          	 // the Swarm we're observing

  int maxEvolutions;
  int evoCounter;
}

// Methods overriden to make the Swarm.

+ createBegin: aZone;
- createEnd;
- buildObjects;
- buildActions;
- activateIn: swarmContext;

- go;

- count;

@end

