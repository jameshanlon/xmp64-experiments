#ifndef TRAFFIC_H_
#define TRAFFIC_H_

#include <xs1.h>
#include <print.h>
#include <stdlib.h>

#include "../common/sync.h"
#include "../common/hcube.h"
#include "../common/pipe.h"
#include "output.h"
#include "permutations.h"
#include "definitions.h"

#define START_DELAY        10000
#define LED_DELAY          10000000 // 1 second
#define NUM_FLASHES        30
#define MASTER(n)          (n == 0)

// Max bin range
#define BIN_MAX(value)     (value - (value % BINS) + BINS)

#define TOTAL_RUNS         (2 * RUNS)
#define INIT_BINS(i)       (i < RUNS)
#define LAST_INIT_RUN(i)   (i+1 == RUNS)

extern void         send(timer tmr, int offset, unsigned int msgLen, chanend out_);
extern unsigned int recv(timer tmr, int offset, unsigned int msgLen, chanend in_);

extern void         send_(timer tmr, int offset, unsigned int msgLen, unsigned int resourceId, chanend out_);
extern unsigned int recv_(timer tmr, int offset, unsigned int msgLen, unsigned int resourceId, chanend in_);

extern unsigned int chanendInt(chanend c);

void sender(chanend receiver, chanend out_);

void receiver(
		out port led, unsigned int node, chanend sender,
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6,	
		chanend pipein, chanend pipeout, 
		chanend in_);

void receiver_(
		unsigned int node, chanend sender,
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6,	
		chanend pipein, chanend pipeout, 
		chanend in_);

#endif
