#ifndef OUTPUT_H_
#define OUTPUT_H_

#include "../common/hcube.h"
#include "../common/definitions.h"
#include "definitions.h"

int writeResults(unsigned avg[], unsigned bins[BINS][NUM_NODES], unsigned max);
//int writePerms(unsigned int perms[NUM_NODES][NUM_NODES], int iteration);

#endif
