// ObserverSwarm.h

#import "ModelSwarm.h"
#import <simtoolsgui/GUISwarm.h>

@interface ObserverSwarm: GUISwarm
{
  int displayFrequency;                  // one parameter: update freq

  BOOL quickExec;                        // If 'YES' turns off sons & lumieres         

  id displayActions;                     // schedule data structs
  id displaySchedule;

  ModelSwarm *modelSwarm;          	 // the Swarm we're observing

  id <Colormap> logoColormap;
  id <Raster> logoWindow;
  
  id <Graph> queueLengthGraph;

  id <GraphElement> queueLength; 
  id <GraphElement> limboLength; 

  id <ActiveGraph> queueGrapher;
  id <ActiveGraph> limboGrapher;


  id <Histogram> weaverLoadHisto;
  id <ButtonPanel> probeGenerator;

}

// Methods overriden to make the Swarm.

+ createBegin: aZone;
- createEnd;
- buildObjects;
- buildActions;
- activateIn: swarmContext;

- stopControlPanel;

@end

