// GolemRule.m
//=========================================================================
#import "GolemRule.h"
@implementation GolemRule
//=========================================================================
//  Part 1 creation of the object
//=========================================================================
- createEnd
{
   return [super createEnd];
}

//=========================================================================
//  Part 2 methods to set values 
//=========================================================================
- setFitness: (float) fV;
{
   fitness = fV;
   return self;
}

//-------------------------------------------------------------------------
- setSaveFitness: (float) fV;
{
   saveFitness = fV;
   return self;
}

//-------------------------------------------------------------------------
- setCopies: (int) iV;
{
   copies = iV;
   return self;
}

//-------------------------------------------------------------------------
- setWillDie: (char)  cV;
{
   willDie = cV;
   return self;
}

//-------------------------------------------------------------------------
- setWillGenerate: (char)  cV;
{
   willGenerate = cV;
   return self;
}

//=========================================================================
//  Part 3 methods to get values 
//=========================================================================
- (int*) getBody;
{
   return body;
}

//-------------------------------------------------------------------------
- (float) getFitness;
{
   return fitness;
}

//-------------------------------------------------------------------------
- (float) getSaveFitness;
{
   return saveFitness;
}

//-------------------------------------------------------------------------
- (int)   getCopies;
{
   return copies;
}

//-------------------------------------------------------------------------
- (char)  getWillDie;
{
   return willDie;
}

//-------------------------------------------------------------------------
- (char)  getWillGenerate;
{
   return willGenerate;
}

//=========================================================================
//  Part 4 operative methods  
//=========================================================================
- printWithLength: (int) iV;
{
   int i;
   int* bodyPtr=body;

   printf
   ("\n%8X length: %4d copies %4d fitness %f %f willGenerate %c willDie %c\n",
    (int) self, iV, copies, fitness, saveFitness, willGenerate, willDie);

   printf("\n%4d ",*bodyPtr++);
   for(i=1;i<iV;i++)
   {
      if(i%16 == 0) printf("\n");
      printf("%4d ",*bodyPtr++);
   }
   printf("\n");
   return self;
}
//--------------------------------------------------------------------
@end
