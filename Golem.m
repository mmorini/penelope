// Golem.m                      
//=========================================================================
#import "Golem.h"
@implementation Golem
//=========================================================================
//  Part 1 creation of the object
//=========================================================================
+ createBegin: aZone
{
   Golem* obj;

   obj                       = [super createBegin: aZone];
   obj->turnoverRate         = DEFAULT_TURNOVER_RATE;
   obj->crossoverRate        = DEFAULT_CROSSOVER_RATE;
   obj->randomCrossPoints    = DEFAULT_CROSSPOINTS;
   obj->univocalCrossPoints  = DEFAULT_CROSSPOINTS;
   obj->mutationRate         = DEFAULT_MUTATION_RATE;
   obj->ruleLength           = DEFAULT_RULE_LENGTH;
   obj->numberOfRules        = DEFAULT_NUMBER_OF_RULES;
   obj->genomeLengths[0]     = DEFAULT_GENOME_LENGTH;      
   obj->numberOfGenomes      = DEFAULT_NUMBER_OF_GENOMES;   
   obj->myRandomSeed         = DEFAULT_RANDOM_SEED;
   obj->bestWillSurvive      = DEFAULT_BEST_WILL_SURVIVE; 
   obj->afterBuildObjects    = 'f';
   obj->firstGLSet           = 't';

   return obj;
}

//-------------------------------------------------------------------------
- buildObjects: (id<Zone>) aV
{
   int         i;

   currentRulePtr  = rules;
   currentNewsPtr  = news;

   myGenerator      = [MT19937gen         create: aV
                                setStateFromSeed: myRandomSeed];
   myUniformDblRand = [UniformDoubleDist  create: aV
                                    setGenerator: myGenerator];
   myUniformIntRand = [UniformIntegerDist create: aV
                                    setGenerator: myGenerator];

   for(i=0;i<numberOfRules;i++)
   {
      currentRule = [GolemRule   createBegin: aV];
      currentRule = [currentRule createEnd];
      *currentRulePtr++ = currentRule;
     
      currentNews = [GolemNews   createBegin: aV];
      currentNews = [currentNews createEnd];
      *currentNewsPtr++ = currentNews;
   }

   //MM 20030709
   bestRuleEver = [GolemRule createBegin: aV];
   bestRuleEver = [bestRuleEver createEnd];
   

   afterBuildObjects = 't';
   return self;
}

//-------------------------------------------------------------------------
// Number of parents must be computed also here: If the user had set number
// of rules after setting turnover rate, parents would have been computed
// starting from default number of rules. 
- createEnd
{
   evolutions=reproductions=crossovers=mutations=steps = 0;
   replaced=0;
   [self computeNumberOfParents];
   activeRule = bestRule = worstRule = mostDiffusedRule = *rules;

   maxFitnessEver = -HUGE_VAL; //MM20030709_
   activeRulePtr = rules;
   return [super createEnd];
}

//=========================================================================
//  Part 2 - setters
//  For each parameter max and min values are provided, so user's setting
//  are limited into the established range.
//  If no user's setting are done, default values are also provided; they
//  are set during createBegin phase.
//=========================================================================
- setNumberOfRules: (int) iV
{
   if (afterBuildObjects == 'f')
   {
      numberOfRules = iV;
      numberOfRules = numberOfRules + numberOfRules % 2;
      if (numberOfRules < MIN_NUMBER_OF_RULES) [self signalError: 1];
      if (numberOfRules > MAX_NUMBER_OF_RULES) [self signalError: 2];
   }
   return self;
}
//-------------------------------------------------------------------------
- setNumberOfGenomes: (int) iV
{
   if (afterBuildObjects == 'f')
   {
      numberOfGenomes = iV;
      if (numberOfGenomes < MIN_NUMBER_OF_GENOMI) [self signalError: 3];
      if (numberOfGenomes > MAX_NUMBER_OF_GENOMI) [self signalError: 4];
   }
   return self;
}

//-------------------------------------------------------------------------
- setGenomeLengths: (int*) iP
{
   int  i;
   int* len=iP; 

   currentGenomeLength = genomeLengths;
   if (afterBuildObjects == 'f')
   {
      if(firstGLSet == 't')
      {
         ruleLength = 0;
         firstGLSet = 'f';
      }

      for(i=0;i<numberOfGenomes;i++)
      {
         if (*len < MIN_GENOMA_LENGTH) [self signalError: 5];
         if (*len > MAX_GENOMA_LENGTH) [self signalError: 6];
         ruleLength += *len;
         if (ruleLength > MAX_RULE_LENGTH) [self signalError: 7];
         *currentGenomeLength++ = *len++;
      }
   }
   return self;
}

//-------------------------------------------------------------------------
- setGenomeMinValues: (int*) iP  
{
   int  i;
   int* min;
 
   min = iP;
   currentGenomeMinValue = genomeMinValues;
   for(i=0;i<numberOfGenomes;i++) *currentGenomeMinValue++ = *min++;
   return self;
}

//-------------------------------------------------------------------------
- setGenomeMaxValues: (int*) iP   
{
   int  i;
   int* max;

   max = iP;
   currentGenomeMaxValue = genomeMaxValues;
   for(i=0;i<numberOfGenomes;i++) *currentGenomeMaxValue++ = *max++;
   return self;
}

//-------------------------------------------------------------------------
- setGenomeTypes: (char*) cP    
{
   int   i;
   char* type;

   type = cP;
   currentGenomeType = genomeTypes;
   for(i=0;i<numberOfGenomes;i++) *currentGenomeType++ = *type++;
   return self;
}

//-------------------------------------------------------------------------
- setRandomSeed: (unsigned int) iV
{
   if (afterBuildObjects == 'f') myRandomSeed = iV;
   return self;
}

//-------------------------------------------------------------------------
- setTurnoverRate: (float) fV
{
   turnoverRate = fV;
   if (turnoverRate < MIN_TURNOVER_RATE) [self signalError: 8];
   if (turnoverRate > MAX_TURNOVER_RATE) [self signalError: 9];
   [self computeNumberOfParents];
   return self;
}

//-------------------------------------------------------------------------
- setCrossoverRate: (float) fV
{
   crossoverRate = fV;
   if (crossoverRate < MIN_CROSSOVER_RATE) [self signalError: 10];
   if (crossoverRate > MAX_CROSSOVER_RATE) [self signalError: 11];
   return self;
}

//-------------------------------------------------------------------------
- setRandomCrossPoints: (int) iV
{
   randomCrossPoints = iV;
   if (randomCrossPoints < MIN_RANDOM_CROSSPOINTS) [self signalError: 17];
   if (randomCrossPoints > MAX_RANDOM_CROSSPOINTS) [self signalError: 18];
   return self;
}

//-------------------------------------------------------------------------
- setUnivocalCrossPoints: (int) iV
{
   univocalCrossPoints = iV;
   if (univocalCrossPoints < MIN_UNIVOCAL_CROSSPOINTS) [self signalError: 19];
   if (univocalCrossPoints > MAX_UNIVOCAL_CROSSPOINTS) [self signalError: 20];
   return self;
}

//-------------------------------------------------------------------------
- setMutationRate: (float) fV
{
   mutationRate = fV;
   if (mutationRate < MIN_MUTATION_RATE) [self signalError: 12];
   if (mutationRate > MAX_MUTATION_RATE) [self signalError: 13];
   return self;
}

//-------------------------------------------------------------------------
- setBestWillSurvive: (char) cV
{
   bestWillSurvive = cV;
   if ((bestWillSurvive != 't') && (bestWillSurvive != 'f'))
        [self signalError: 21];
   return self;
}

//=========================================================================
//  Part 3 - getters
//=========================================================================
- (int) getNumberOfRules
{
   return numberOfRules;
}

//-------------------------------------------------------------------------
- (int) getRuleLength
{
   return ruleLength;
}

//-------------------------------------------------------------------------
- (int) getNumberOfGenomes
{
   return numberOfGenomes;
}

//-------------------------------------------------------------------------
- (int) getLengthOfGenome: (int) iV
{
   if(iV >= numberOfGenomes) [self signalError: 14];
   return genomeLengths[iV]; 
}

//-------------------------------------------------------------------------
- (int) getMinValueOfGenome: (int) iV
{
   if(iV >= numberOfGenomes) [self signalError: 14];
   return genomeMinValues[iV]; 
}

//-------------------------------------------------------------------------
- (int) getMaxValueOfGenome: (int) iV
{
   if(iV >= numberOfGenomes) [self signalError: 14];
   return genomeMaxValues[iV]; 
}

//-------------------------------------------------------------------------
- (char) getTypeOfGenome: (int) iV
{
   if(iV >= numberOfGenomes) [self signalError: 14];
   return genomeTypes[iV]; 
}

//-------------------------------------------------------------------------
- (unsigned int) getRandomSeed
{
   return myRandomSeed;
}

//-------------------------------------------------------------------------
- (float) getTurnoverRate
{
   return turnoverRate;
}

//-------------------------------------------------------------------------
- (float) getCrossoverRate
{
   return crossoverRate;
}

//-------------------------------------------------------------------------
- (int) getRandomCrossPoints
{
   return randomCrossPoints;
}

//-------------------------------------------------------------------------
- (int) getUnivocalCrossPoints
{
   return univocalCrossPoints;
}

//-------------------------------------------------------------------------
- (float) getMutationRate
{
   return mutationRate;
}

//-------------------------------------------------------------------------
- (int) getEvolutions
{
   return evolutions;
}

//-------------------------------------------------------------------------
- (int) getReproductions
{
   return reproductions;
}

//-------------------------------------------------------------------------
- (int) getCrossovers
{
   return crossovers;
}

//-------------------------------------------------------------------------
- (int) getMutations
{
   return mutations;
}

//-------------------------------------------------------------------------
- (float) getTotalFitness
{
   return totalFitness;
}

//-------------------------------------------------------------------------
- (float) getMaxFitness
{
   return bestRule->fitness;
}

//-------------------------------------------------------------------------
- (float) getMaxFitnessEver
{
   return bestRuleEver->fitness;
}

//-------------------------------------------------------------------------
- (float) getMinFitness
{
   return worstRule->fitness;
}

//-------------------------------------------------------------------------
- (float) getMeanFitness
{
   return meanFitness;
}

//-------------------------------------------------------------------------
- (int) getMaxCopies
{
   return mostDiffusedRule->copies; 
}

//-------------------------------------------------------------------------
- (int*) getActiveRule
{
   return activeRule->body;
}

//-------------------------------------------------------------------------
- (int*) getBestRule
{
   return bestRule->body;
}

//-------------------------------------------------------------------------
- (int*) getBestRuleEver
{
   return bestRuleEver->body;
}

//-------------------------------------------------------------------------
- (int*) getWorstRule
{
   return worstRule->body;
}

//-------------------------------------------------------------------------
- (int*) getMostDiffusedRule
{
   return mostDiffusedRule->body; 
}

//-------------------------------------------------------------------------
- (float) getConvergency
{
   return convergency;
}

//-------------------------------------------------------------------------
- (char) getBestWillSurvive
{
   return bestWillSurvive;
}

//========================================================================
//  Part 4 - ruleMaster
//========================================================================
- setReward: (float) fV
{
   activeRule->fitness = fV;    

   if (steps == 0)
   {
      minFitness  = quasiMinFitness = maxFitness =
      meanFitness = totalFitness    = fV;
      //maxFitnessEver = fV; //MM20030709
      worstRule = bestRule = activeRule = mostDiffusedRule = *rules; 
   }
   else
   {
      totalFitness += fV;
     //MM 20030709
      if (fV > maxFitnessEver)
	{
	  int i;

	  for(i=0;i<ruleLength;i++) bestRuleEver->body[i] = activeRule->body[i];
	  bestRuleEver->fitness = activeRule->fitness;

	  maxFitnessEver = fV;
	}
     /////////////
      if (fV > maxFitness)
      {
         bestRule   = activeRule;
         maxFitness = fV;
      }
      if (fV < minFitness)
      {
         worstRule       = activeRule;
         minFitness      = fV;
      }
      if ((fV > minFitness) && (fV < quasiMinFitness))
      {
         quasiMinFitness = fV;
      }
   }

   steps++;
   activeRulePtr++;
   if (steps >= numberOfRules)
   {
      [self evolve];
      steps = 0;
      activeRulePtr = rules;
   }
   activeRule = *activeRulePtr;


   return self;
}

//--------------------------------------------------------------------
- (float) verify
{

   int i,j,k,found,numberOfTypes=0;

   currentRulePtr = rules;

   for(i=0;i<numberOfRules;i++)
   {
      currentRule     = *currentRulePtr++;
      currentRuleBody = currentRule->body;
      found = 0;
      j     = 0;
      currentTypePtr = types;

      while ((found == 0) && (j < numberOfTypes))
      {
         currentType     = *currentTypePtr++;
         currentTypeBody = currentType->body;
         k     = 0;
         while ((*currentRuleBody++ == *currentTypeBody++)
                 && (k < ruleLength)) k++;
         if (k == ruleLength)
         {
            currentType->copies += 1;
            found = 1;
         }
         j++;
      }
      if (j == numberOfTypes)
      {
         currentRule->copies = 1;
         *currentTypePtr = currentRule;
         numberOfTypes++;
      }
   }

   maxCopies = 0;
   currentTypePtr = types;

   for(j=0;j<numberOfTypes;j++)
   {
      currentType = *currentTypePtr++;
      if (currentType->copies > maxCopies)
      {
         maxCopies        = currentType->copies;
         mostDiffusedRule = currentType;
      }
   }

   convergency = (maxCopies*1.0)/(numberOfRules*1.0);
   return convergency;
}

//------------------------------------------------------------------------
- print
{
   int i,j,k;

   currentRulePtr  = rules;

   printf("\n========= Rules \n");
   for(i=0;i<numberOfRules;i++)
   {
      currentRule           = *currentRulePtr++;
      currentGenomeLength   = genomeLengths;
      currentGenomeMinValue = genomeMinValues;
      currentGenomeMaxValue = genomeMaxValues;
      currentGenomeType     = genomeTypes;

      currentRuleBody = currentRule->body;

      printf("Rule %4d at: %8X fitness = %f willgenerate = %c willDie = %c\n",
            i,(int) currentRule,currentRule->fitness,
            currentRule->willGenerate,currentRule->willDie);

      for(j=0;j<numberOfGenomes;j++)
      {
         printf("genome %4d type = %c min = %5d max = %5d",
                j,*currentGenomeType,*currentGenomeMinValue,
                *currentGenomeMaxValue);

         for(k=0;k<*currentGenomeLength;k++)
         {
             if(k%16 == 0) printf("\n");
             else          printf(".");
             printf("%5d",*currentRuleBody++);
         }
         printf("\n");
         currentGenomeLength++;
         currentGenomeMinValue++;
         currentGenomeMaxValue++;
         currentGenomeType++;
      }
   }
   printf("BestRule is %8X mostDiffusedRule is %8X worstRule is %8X\n",
           (int)bestRule,(int)mostDiffusedRule,(int)worstRule);

   printf("\n========= Statistics \n");
   printf("Convergency is: %f\n",convergency);
   printf("Evolution has been performed %d times\n",evolutions);
   printf("%d reproductions has been performed \n",reproductions);
   printf("with %d crossovers and %d mutations - replaced %d\n",
           crossovers,mutations,replaced);

   return self;
}
//========================================================================
//  Part 4 - ruleMaker
//========================================================================
- createAtRandom
{
   int i,j,k,v;

   currentRulePtr = rules;

   for(i=0;i<numberOfRules;i++)
   {
      currentRule               = *currentRulePtr++;
      currentRuleBody           = currentRule->body;
      currentRuleGenome         = currentRule->body;
      currentGenomeLength       = genomeLengths;
      currentGenomeMinValue     = genomeMinValues;
      currentGenomeMaxValue     = genomeMaxValues;
      currentGenomeType         = genomeTypes;

      currentRule->willGenerate = 'f';
      currentRule->willDie      = 't';

      for(j=0;j<numberOfGenomes;j++)
      {
         if (*currentGenomeType == 'r')
         {
            for(k=0;k<*currentGenomeLength;k++)
               *currentRuleBody++ = [myUniformIntRand
                                  getIntegerWithMin: *currentGenomeMinValue
                                            withMax: *currentGenomeMaxValue];
         }
         
         
         if   (*currentGenomeType == 'u')
         {
            v = *currentGenomeMinValue;
            for(k=0;k<*currentGenomeLength;k++) *currentRuleBody++ = v++;
            [self shuffle];
         }

         currentRuleGenome = currentRuleBody;
         currentGenomeLength++;
         currentGenomeMinValue++;
         currentGenomeMaxValue++;
         currentGenomeType++;
      }
   }
//   [self print];
   return self;
}

//--------------------------------------------------------------------
- evolve
{
   evolutions++;
   [self prepare];
   [self selectParents];
   [self selectSurvivers];
   [self reproduce];
   [self replace];  
   return self;
}

//====================================================================
//Service methods
//====================================================================
- shuffle
{
   int v1,v2; 
   int i,j,k,len;

   len = *currentGenomeLength / 2;
   for (i=0;i<len;i++)
   {
      j = [myUniformIntRand getIntegerWithMin: 0
                                      withMax: *currentGenomeLength-1];
      v1 = currentRuleGenome[j];
      do
      {
         k = [myUniformIntRand getIntegerWithMin: 0
                                         withMax: *currentGenomeLength-1];
      } while (k == j);
      v2 = currentRuleGenome[k];
      v1 = v1 + v2;
      v2 = v1 - v2;

      currentRuleGenome[j] = v1 - v2; 
      currentRuleGenome[k] = v2; 
   }
   return self;
}

//--------------------------------------------------------------------
- computeNumberOfParents
{
   numberOfParents = (int) numberOfRules * turnoverRate;
   numberOfParents = numberOfParents - numberOfParents % 2;
   if (numberOfParents < 2) numberOfParents = 2;
   numberOfSurvivers = numberOfRules - numberOfParents;
   return self;
}

//----------------------------------------------------------------
- prepare
{
   float       delta;
   int         i;

   currentRulePtr = rules;
   totalFitness = 0;
   delta = ((-1) * minFitness) +
           ((quasiMinFitness - minFitness) / 1000);
   for(i=0;i<numberOfRules;i++)
   {
      currentRule               = *currentRulePtr++;
      totalFitness              = totalFitness + currentRule->fitness + delta;
      currentRule->saveFitness  = currentRule->fitness + delta;
      currentRule->willGenerate = 'f';
      currentRule->willDie      = 't';
   }
   return self;
}

//----------------------------------------------------------------
- selectParents
{
   GolemRule*  selectedRule;

   float       totFitness,sumFitness,tresholdFitness;
   int         i,j;

   totFitness = totalFitness;
   for(i=0;i<numberOfParents;i++)
   {
      tresholdFitness = totFitness *
         [myUniformDblRand getDoubleWithMin: 0 withMax: 1];

      selectedRule   = (GolemRule*) nil;
      currentRulePtr = rules;
      sumFitness     = 0;
      j              = 0;
      do
      {
         currentRule    = *currentRulePtr++;
         if (currentRule->willGenerate == 'f')
         {
            selectedRule  = currentRule;
            sumFitness   += selectedRule->saveFitness;
         }
         j++;
      }
      while ((sumFitness <= tresholdFitness) &&
             (j < numberOfRules));
      if (selectedRule == (GolemRule*) nil) [self signalError: 15];
      selectedRule->willGenerate  = 't';
      totFitness                 -= selectedRule->saveFitness;
   }
   return self;
}

//----------------------------------------------------------------
- selectSurvivers
{
   GolemRule*  selectedRule;
   float       totFitness,sumFitness,tresholdFitness;
   int   i,j;

   totFitness = totalFitness;

   if (bestWillSurvive == 't')
   {
     bestRule->willDie = 'f';
     totFitness       -= bestRule->saveFitness;
   }

   for(i=0;i<numberOfSurvivers;i++)
   {
      tresholdFitness = totFitness *
         [myUniformDblRand getDoubleWithMin: 0 withMax: 1];
      selectedRule = (GolemRule*) nil;

      currentRulePtr = rules;
      sumFitness     = 0;
      j              = 0;
      do
      {
         currentRule = *currentRulePtr++;
         if (currentRule->willDie == 't')
         {
            selectedRule  = currentRule;
            sumFitness   += selectedRule->saveFitness;
         }
         j++;
      }
      while ((sumFitness <= tresholdFitness) &&
             (j < numberOfRules));
      if (selectedRule == (GolemRule*) nil) [self signalError: 16];
      selectedRule->willDie = 'f';
      totFitness -= selectedRule->saveFitness;
   }
   return self;
}

//--------------------------------------------------------------------
- reproduce
{
   int         i,j=0;

   currentRulePtr = rules;
   currentNewsPtr = news;  
    
   for(i=0;i<numberOfRules;i++)
   {
      currentRule = *currentRulePtr++;
      if (currentRule->willGenerate == 't')
      {
         if   (j == 0)
         {
            firstRuleBody = currentRule->body;
            firstNews     = *currentNewsPtr++; 
            firstNewsBody = firstNews->body;
         }
         else
         {
            secondRuleBody = currentRule->body;
            secondNews     = *currentNewsPtr++; 
            secondNewsBody = secondNews->body;
         }
         j++;
      }

      if (j == 2)
      {
         [self cross];
         j = 0;
         reproductions++;
      }
   }
   return self;
}
//--------------------------------------------------------------------
- replace
{
   int         i,j;

   currentRulePtr = rules;
   currentNewsPtr = news;  

   for(i=0;i<numberOfRules;i++)
   {
      currentRule = *currentRulePtr++;
      if (currentRule->willDie == 't')
      {
         currentNews     = *currentNewsPtr++;
         currentNewsBody = currentNews->body;
         currentRuleBody = currentRule->body;
         for(j=0;j<ruleLength;j++) *currentRuleBody++ = *currentNewsBody++;
         replaced++;
      }
   }
   return self;
}

//--------------------------------------------------------------------
- cross
{
   int i;

   currentGenomeLength    = genomeLengths;
   currentGenomeMinValue  = genomeMinValues;
   currentGenomeMaxValue  = genomeMaxValues;
   currentGenomeType      = genomeTypes;

   firstRuleCurrentGenome  = firstRuleBody;
   secondRuleCurrentGenome = secondRuleBody;
   firstNewsCurrentGenome  = firstNewsBody;
   secondNewsCurrentGenome = secondNewsBody;

   for(i=0;i<numberOfGenomes;i++)
   {
      if (*currentGenomeType == 'r')
      {
         [self doRandomCrossover];
         currentNewsGenome = firstNewsCurrentGenome;
         [self doRandomMutation];
         currentNewsGenome = secondNewsCurrentGenome;
         [self doRandomMutation];
      }
      if (*currentGenomeType == 'u')
      {
         [self doUnivocalCrossover];
         currentNewsGenome = firstNewsCurrentGenome;
         [self doUnivocalMutation];
         currentNewsGenome = secondNewsCurrentGenome;
         [self doUnivocalMutation];
      }
 
      firstRuleCurrentGenome  += *currentGenomeLength;
      firstNewsCurrentGenome  += *currentGenomeLength;
      secondRuleCurrentGenome += *currentGenomeLength;
      secondNewsCurrentGenome += *currentGenomeLength;

      currentGenomeLength++;
      currentGenomeMinValue++;
      currentGenomeMaxValue++;
      currentGenomeType++;
   }
   return self;
}

//--------------------------------------------------------------------
- doRandomCrossover 
{
   int    i,j,len,lastLen,cp=0;
   int*   child1;
   int*   child2;
   int*   parent1;
   int*   parent2;


   parent1  = firstRuleCurrentGenome;
   parent2  = secondRuleCurrentGenome;  
   child1   = firstNewsCurrentGenome;
   child2   = secondNewsCurrentGenome;
   len      = *currentGenomeLength / randomCrossPoints;
   lastLen  = len + *currentGenomeLength % randomCrossPoints;
   if ([myUniformDblRand getDoubleWithMin: 0 withMax: 1] < crossoverRate)
   {
      crossovers++;
      
      for(i=0;i<randomCrossPoints;i++)
      {
         if (i == (randomCrossPoints - 1)) len = lastLen; 
         cp = [myUniformIntRand getIntegerWithMin: 0 withMax: len-1];

         for(j=0;j<cp;j++)
         {
            *child1++ = *parent2++; 
            *child2++ = *parent1++;
         }

         for(j=cp;j<len;j++)
         {
            *child1++ = *parent1++; 
            *child2++ = *parent2++; 
         }
      }
   }
   else 
   {
      for(i=0;i<*currentGenomeLength;i++)
      {
         *child1++ = *parent1++;
         *child2++ = *parent2++;
      }
   }
   return self;
}

//--------------------------------------------------------------------
- doUnivocalCrossover 
{
   int* child1;
   int* child2;
   int* child1cp;
   int* child2cp;
   int* parent1;
   int* parent2;
   int  i,j,cp=0;

   parent1  = firstRuleCurrentGenome;
   parent2  = secondRuleCurrentGenome;  
   child1   = firstNewsCurrentGenome;
   child2   = secondNewsCurrentGenome;

   for(i=0;i<*currentGenomeLength;i++)
   {
      *child1++ = *parent1++;
      *child2++ = *parent2++;
   }

   if ([myUniformDblRand getDoubleWithMin: 0 withMax: 1] < crossoverRate)
   {
      crossovers++;
      for(i=0;i<univocalCrossPoints;i++)
      {
         cp = [myUniformIntRand getIntegerWithMin: 1
                                          withMax: *currentGenomeLength -2];
        
         for(j=0;j<cp;j++)
         {
            child1    = firstNewsCurrentGenome;
            child2    = secondNewsCurrentGenome;
            child1cp  = child1+j;       
            child2cp  = child2+j;

            do {} while (*child1++ != *child2cp);
            do {} while (*child2++ != *child1cp);

            child1--;   
            child2--;   

            *child1   = *child1 + *child2;
            *child2   = *child1 - *child2;
            *child1   = *child1 - *child2;

            *child1cp = *child1cp + *child2cp;
            *child2cp = *child1cp - *child2cp;
            *child1cp = *child1cp - *child2cp;
         }
      }
   }
   return self;
}
//--------------------------------------------------------------------
- doRandomMutation 
{
   int* child;
   int  i,v;

   child = currentNewsGenome;
   for(i=0;i<*currentGenomeLength;i++)
   {
      if ([myUniformDblRand getDoubleWithMin: 0 withMax: 1] < mutationRate)
      {
         do
         {
            v = [myUniformIntRand getIntegerWithMin: *currentGenomeMinValue
                                            withMax: *currentGenomeMaxValue]; 
         } while (*child == v);
         *child = v;
         child++;
         mutations++;
      }
   }
   return self;
} 

//--------------------------------------------------------------------
- doUnivocalMutation 
{
   int*  child;
   float univocalMutationRate;
   int   firstAllele,secondAllele,firstValue,secondValue,i;

   univocalMutationRate = mutationRate / 2;
   child = currentNewsGenome;
   for(i=0;i<*currentGenomeLength;i++)
   {
      if ([myUniformDblRand getDoubleWithMin: 0 withMax: 1] < 
                                         univocalMutationRate)
      {
         firstAllele = i; 
         firstValue  = child[firstAllele];
         do
         {
            secondAllele = [myUniformIntRand
                            getIntegerWithMin: 0
                                      withMax: *currentGenomeLength-1]; 
         } while (secondAllele == firstAllele);
         secondValue = child[secondAllele];
         firstValue  = firstValue + secondValue;
         secondValue = firstValue - secondValue;
         firstValue  = firstValue - secondValue;           
         
         child[firstAllele]  = firstValue;
         child[secondAllele] = secondValue;
         mutations++;
      }
   }
   return self;
} 

//--------------------------------------------------------------------
- signalError: (int) iV
{
if(iV == 1)  printf("E01 numberOfRules less than minimum allowed value\n");
if(iV == 2)  printf("E02 numberOfRules greater than maximum allowed value\n");
if(iV == 3)  printf("E03 numberOfGenomi less than minimum allowed value\n");
if(iV == 4)  printf("E04 numberOfGenomi greater than maximum allowed value\n");
if(iV == 5)  printf("E05 genomaLength less than minimum allowed value\n");
if(iV == 6)  printf("E06 genomaLength greater than maximum allowed value\n");
if(iV == 7)  printf("E07 ruleLength has passed the maximum allowed value\n");
if(iV == 8)  printf("E08 turnoverRate less than minimum allowed value\n");
if(iV == 9)  printf("E09 turnoverRate greater than maximum allowed value\n");
if(iV == 10) printf("E10 crossoverRate less than minimum allowed value\n");
if(iV == 11) printf("E11 crossoverRate greater than maximum allowed value\n");
if(iV == 12) printf("E12 mutationRate less than minimum allowed value\n");
if(iV == 13) printf("E13 mutationRate greater than maximum allowed value\n");
if(iV == 14) printf("E14 unexisting genoma\n");
if(iV == 15) printf("E15 double selection in selectParents\n");
if(iV == 16) printf("E16 double selection in selectSurvivers\n");
if(iV == 17) printf("E17 randomCrossPoints is less than minimum allowed\n");
if(iV == 18) printf("E18 randomCrossPoints is greater than maximum allowed\n");
if(iV == 19) printf("E19 univocalCrossPoints is less than minimum allowed\n");
if(iV == 20) printf("E20 univocalCrossPoints is greater than maximum allowed\n");
if(iV == 21) printf("E21 bestWillSurvive value out of range\n");

   exit(1);
   return self;
}

//--------------------------------------------------------------------
@end
