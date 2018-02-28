//Golem.h
//--------------------------------------------------------------------
#import <objectbase/SwarmObject.h>
#import <random.h>        
#import "GolemParms.h"           
#import "GolemRule.h"
#import "GolemNews.h"
@interface Golem: SwarmObject
//--------------------------------------------------------------------
{
   id<SimpleRandomGenerator> myGenerator;
   id<UniformDoubleDist>     myUniformDblRand;
   id<UniformIntegerDist>    myUniformIntRand;

   GolemRule*                rules[MAX_NUMBER_OF_RULES];
   GolemRule*                types[MAX_NUMBER_OF_RULES];
   GolemNews*                news[MAX_NUMBER_OF_RULES];

   int                       genomeLengths[MAX_NUMBER_OF_GENOMI];
   int                       genomeMinValues[MAX_NUMBER_OF_GENOMI];                       
   int                       genomeMaxValues[MAX_NUMBER_OF_GENOMI];                       
   char                      genomeTypes[MAX_NUMBER_OF_GENOMI];                       

   GolemRule**               activeRulePtr;
   GolemRule*                activeRule;
   GolemRule*                bestRule;
   GolemRule*                worstRule;
   GolemRule*                mostDiffusedRule;

   GolemRule*                bestRuleEver; //MM 20030709

   float                     totalFitness,meanFitness,convergency,
                             maxFitness,minFitness,quasiMinFitness,   
                             turnoverRate,crossoverRate,mutationRate;

   float                     maxFitnessEver; //MM 20030709

   int                       randomCrossPoints,univocalCrossPoints; 

   int                       ruleLength,numberOfParents,numberOfRules,
                             numberOfSurvivers,numberOfGenomes,
                             maxCopies,evolutions,reproductions,crossovers,
                             mutations,steps,replaced;

   unsigned int              myRandomSeed;

   char                      afterBuildObjects,firstGLSet,bestWillSurvive;

   //Working storage - to avoid passing heavy parameter lists to the service 
   //                  methods

   GolemRule**               currentRulePtr;
   GolemRule**               currentTypePtr;
   GolemNews**               currentNewsPtr;

   GolemRule*                currentRule;
   GolemRule*                currentType;
   GolemNews*                currentNews;

   GolemRule*                firstRule;
   GolemNews*                firstNews;
   GolemRule*                secondRule;
   GolemNews*                secondNews;

   int*                      currentGenomeLength;
   int*                      currentGenomeMinValue;
   int*                      currentGenomeMaxValue;
   char*                     currentGenomeType;

   int*                      currentRuleBody;
   int*                      currentTypeBody;
   int*                      currentNewsBody;
   int*                      currentRuleGenome; 
   int*                      currentNewsGenome;

   int*                      firstRuleBody;
   int*                      secondRuleBody;      
   int*                      firstNewsBody;
   int*                      secondNewsBody;

   int*                      firstRuleCurrentGenome;
   int*                      secondRuleCurrentGenome;      
   int*                      firstNewsCurrentGenome;
   int*                      secondNewsCurrentGenome;

   int                       work1[MAX_GENOMA_LENGTH];
   int                       work2[MAX_GENOMA_LENGTH];
   int*                      work1Ptr;
   int*                      work2Ptr;

}
//--------------------------------------------------------------------
//createEnd and set up methods
+                createBegin:                      aZone;
-                createEnd;           
-                buildObjects:        (id<Zone>)     aV;

//Setters and getters

-                setNumberOfRules:       (int)          iV;
-                setNumberOfGenomes:     (int)          iV;
-                setGenomeLengths:       (int*)         iP;  
-                setGenomeMinValues:     (int*)         iP;  
-                setGenomeMaxValues:     (int*)         iP;  
-                setGenomeTypes:         (char*)        cP;  
-                setRandomSeed:          (unsigned int) iV;          
-                setTurnoverRate:        (float)        fV;
-                setCrossoverRate:       (float)        fV;
-                setRandomCrossPoints:   (int)          iV;
-                setUnivocalCrossPoints: (int)          iV;
-                setMutationRate:        (float)        fV; 
-                setBestWillSurvive:     (char)         cV; 
- (int)          getNumberOfRules;
- (int)          getRuleLength;
- (int)          getNumberOfGenomes;
- (int)          getLengthOfGenome:      (int)          iV;
- (int)          getMinValueOfGenome:    (int)          iV;
- (int)          getMaxValueOfGenome:    (int)          iV;
- (char)         getTypeOfGenome:        (int)          iV;
- (unsigned int) getRandomSeed;
- (float)        getTurnoverRate;
- (float)        getCrossoverRate;
- (int)          getRandomCrossPoints;
- (int)          getUnivocalCrossPoints;
- (float)        getMutationRate;
- (int)          getEvolutions;
- (int)          getReproductions;
- (int)          getCrossovers;
- (int)          getMutations;
- (float)        getTotalFitness;
- (float)        getMaxFitness;
- (float)        getMaxFitnessEver; //MM20030709
- (float)        getMinFitness;
- (float)        getMeanFitness;
- (int)          getMaxCopies;
- (int*)         getActiveRule;
- (int*)         getBestRule;
- (int*)         getBestRuleEver; //MM 20030709
- (int*)         getWorstRule;
- (int*)         getMostDiffusedRule;
- (float)        getConvergency;
- (char)         getBestWillSurvive;
//RuleMaster methods
-                setReward:         (float)        fV;
- (float)        verify;
-                print;
//RuleMaker methods
-                createAtRandom;
-                evolve; 
//Service methods
-                shuffle; 
-                computeNumberOfParents;
-                prepare;           
-                selectParents;  
-                selectSurvivers;
-                reproduce;
-                replace; 
-                cross;
-                doRandomCrossover;
-                doUnivocalCrossover;
-                doRandomMutation;                      
-                doUnivocalMutation; 
-                signalError:       (int)   iV;
//--------------------------------------------------------------------
@end
