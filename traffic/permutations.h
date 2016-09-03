#ifndef PERMUTATIONS_H_
#define PERMUTATIONS_H_

#include <xs1.h>
#include "../common/definitions.h"

#define SHUFFLE	0
#define TRANSPOSE	1
#define BITCOMP	2
#define BITREV	3
#define NEIGHBOUR	4
#define RANDOM	5
#define TRAFFIC_PATTERN	5

{unsigned int, unsigned int} 
initPerm(unsigned int node, unsigned int &seed, unsigned int perm[]);

#endif
