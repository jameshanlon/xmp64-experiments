#ifndef SYNC_H_
#define SYNC_H_

#include "hcube.h"
#include "definitions.h"

{int,int,int} masterX(chanend otherSide, timer t, int offset);
extern void   slaveY(chanend otherSide, timer t, int offset);

/*unsigned getStart(unsigned int node, unsigned int start, 
        chanend d1, chanend d2, chanend d3, 
        chanend d4, chanend d5, chanend d6);*/

int getOffset(timer tmr, unsigned int node, 
        chanend d1, chanend d2, chanend d3, 
        chanend d4, chanend d5, chanend d6);

#endif
