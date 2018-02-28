// Spinner.h -- named weaver as a binary object - compatobility reasons

#import <objectbase/SwarmObject.h>
#import <simtools.h>  // necessary to invoke OutFile protocol
#import <time.h>      // time_t structure

#import "defines.h"
#import "Order.h"

@interface Weaver: SwarmObject
{
 int number; //own number - from R01 in KMAC

 id <List> ordersQueue;
 id <Index> ordersQueueIndex; //pointer to the first free position
 Order *orderOn; //order in progress

 long int timeLeft;
 time_t now, start; //present time, starting time

 int stepDelta;

 char status; // 'I'dle or 'B'usy
 char ready;  // 'W'aiting for raw materials or 'R'eady to go

 float delayCost, setupCost; 

 /////////////////////////////////////////////////////////////////

 char *desc; //(40) - [40]; //R02 in KMAC
 char *busyUntill; //descriptive string for (time_t) avail;
 int heads;  //R03 in KMAC
 // int kind;   //own kind ("confezione"): {0,1}={T,M/S}
 char family[2]; //Vamatex, Dornier...
 float hcomb_tolerance; //CM--CD threshold (cm)
 int rnote; //'rapporto nota'

 //SPINNING MILL only
 int rotor;  //own rotor: {0,1,2,3,4}={R1,R2...}
 int card;   //own "cardìna": {0,1,2,3,4}={C1,C2...}
 int nozzle; //own 'ugello': {0,1,2,3,4}={U1,U2...}
 int speed;  //own yarn speed

 int usedSetupsVector[NUM_OF_SETUPS]; //0,1's

 char *cacc;  //order CA/CC
 float hcomb; //order comb height
 char *color;   //{0,1}={greggio,tinto}
 char *setupKind; //'CA' 'CF' 'CM' 'CD'

 time_t avail; //time when the last queued order production will end (UTC)

 int lastOrderNumber; //last order sent to process

 float timeWasted;

 int card_xchg, rotor_xchg, nozzle_xchg; //flags useful for WeaverRulemaster
 int cacc_xchg, color_xchg;
 int hcomb_delta; //{CF,CM,CD}={0,1,2}

 time_t initial_simtime; //the time in real time the simulation starts

 BOOL doneFlag;

}

- createEnd;

- (int) enqueue: o;
- (int) emptyQueue;
- resetTimer;
- resetCost;
- resetCacc;
- resetDoneFlag;

- (float) getDeliveryCost;
- (float) getCosts;
- (float) getDelayCosts;
- (float) getSetupCosts;

//- setStepDelta: (int) sd;
- stepToTime: (time_t) t;

- findSetupNeededOffset;

- setNumber: (int) n;
- (int) getNumber;
- setDesc: (const char *) d;
- (const char *) getDesc;
- setHeads: (int) h;
- (int) getHeads;

- setFamily: (char *) f;
- (char *) getFamily;

- setCacc: (char *) c;
- (char *) getCacc;
- setHComb: (float) h;
- (float) getHComb;
- setColor: (char *) c;
- (char *) getColor;

- (char *) getSetupKindA; //CA,CF,CM,CD
- (int) getSetupKindB;    //if color changes 0->1 or 1->0


- setRotor: (int) r;
- (int) getRotor;
- setCard: (int) c;
- (int) getCard;
- setNozzle: (int) n;
- (int) getNozzle;
- setSpeed: (int) s;
- (int) getSpeed;

- setOrderNumber: (int) o;
- (int) getOrderNumber;

- setAvailability: (time_t) t;
- (time_t) getAvailability;

- setInitialSimTime: (time_t) t;

- (BOOL) checkIfDone;

@end




