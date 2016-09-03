#ifndef HCUBE_H_
#define HCUBE_H_

#include "definitions.h" 

#define NBR(node, d) (node ^ (0x1 << d))

unsigned int distributeValue(unsigned int node, unsigned int value, 
		chanend d1, chanend d2, chanend d3, 
        chanend d4, chanend d5, chanend d6);

// Same method as distribute value
unsigned int getStart(unsigned int node, unsigned int start, 
		chanend d1, chanend d2, chanend d3, 
        chanend d4, chanend d5, chanend d6);

unsigned getMin(unsigned int node, unsigned int init, 
        chanend d1, chanend d2, chanend d3, 
        chanend d4, chanend d5, chanend d6);

unsigned getMax(unsigned int node, unsigned int init, 
        chanend d1, chanend d2, chanend d3, 
        chanend d4, chanend d5, chanend d6);

#endif
