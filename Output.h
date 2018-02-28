// Output.h 

#import <objectbase/SwarmObject.h>
#import <simtools.h> //OutFile
#import "Golem.h"
#import "TimeFilter.h"
#import "Evaluator.h"
#import "defines.h"

@interface Output: SwarmObject
{
  id <OutFile> programFile;
  id <OutFile> dumpFile;   

  Golem * theGolem;
  TimeFilter * theTimeFilter;
  Evaluator * theEvaluator;

  int ordersToPlan, PUsLoaded;

  struct {
    int   pu;
    int   order;
    char  code[20];
    //struct tm time;
    time_t time;
    int heads;
  } gantt;

}

- programToFile: (char *) f; //file name
- dumpToFile: (char *) f;    // id.
//- ganttToFile: (char *) f;

- dumpProgram;
- dumpEvoStep;
- dumpTxtGantt;

- setGolem: g;
- setTimeFilter: t;
- setEvaluator: ev;
- setOrdersToPlan: (int) o;
- setPUsLoaded: (int) p;
- createEnd;


@end


