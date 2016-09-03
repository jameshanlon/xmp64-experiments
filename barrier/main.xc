#include <xs1.h>
#include <print.h>
#include <platform.h>
#include "../common/pipe.h"
#include "../common/hcube.h"
#include "../common/sync.h"
#include "../common/definitions.h"

#define FLASH_PERIOD       80000000
#define NUM_CHANS          384 // calculated for 64 nodes
#define DELAY              10000
#define RUNS               10
                          
#define SIGNAL_ON          100000
#define SIGNAL_OFF         100000
#define TEST_NODE          43

#define MIN(x,y)           (x < y ? x : y)
#define CHAN_INDEX(s,t,d)  CHAN_INDEX_(MIN(s, t), d)
#define CHAN_INDEX_(s,d)   ((s * NUM_DIMENSIONS) + d)

on stdcore[0]  : out port led0 = XS1_PORT_1E;
on stdcore[0]  : out port p0   = XS1_PORT_4B;
on stdcore[43] : out port p1   = XS1_PORT_4B;

extern unsigned barrier(timer tmr, 
    chanend d1, chanend d2, chanend d3, 
    chanend d4, chanend d5, chanend d6);

void masterNode(out port led, out port pin, int node, 
    chanend d1, chanend d2, chanend d3, 
    chanend d4, chanend d5, chanend d6, chanend pipein) {

	timer tmr;
    int offset;
	unsigned start;
	unsigned elapsed;
    unsigned results[NUM_NODES];
    unsigned int total;
	//unsigned begin;
	//unsigned end;
	//unsigned t;
	
	led <: 1;
	printstr("Starting...\n");
	
	// Exchange offsets with other nodes
    offset = getOffset(tmr, node, d1, d2, d3, d4, d5, d6);
	
	// Distribute a start time
	tmr :> start;
	start += DELAY;
	getStart(node, start, d1, d2, d3, d4, d5, d6);
	//pipeSinkU(start, pipein);
	
	// Wait to start
	tmr when timerafter(start) :> void;
	
	// Enter timed barrier
	elapsed = barrier(tmr, d1, d2, d3, d4, d5, d6);
	pipeSinkU(elapsed, pipein, results);

    // Calculate the average time through the barrier
    total = 0;
    for(int i=0; i<NUM_NODES; i++)
        total += results[i];

    printuint((total/NUM_NODES) * 10);
    printstr("ns\n");
}

void slaveNode(int node, 
    chanend d1, chanend d2, chanend d3, 
    chanend d4, chanend d5, chanend d6, 
    chanend pipein, chanend pipeout) {
		
	timer tmr;
	int offset;
	unsigned start;
	unsigned elapsed;
	//unsigned begin;
	//unsigned end;
	//unsigned t;
	
	// Learn clock offset with master node 0
	offset = getOffset(tmr, node, d1, d2, d3, d4, d5, d6);
	
	// Get the start time
	start = getStart(node, 0, d1, d2, d3, d4, d5, d6);
	//pipeSegmU(node, start-offset, pipein, pipeout);
	
	tmr when timerafter(start + offset) :> void;
	
	// Enter barrier
	elapsed = barrier(tmr, d1, d2, d3, d4, d5, d6);
	pipeSegmU(node, elapsed, pipein, pipeout);
}

int main() {
	
	chan channels[NUM_CHANS];
	chan pipe[NUM_NODES];
	
	par {
		on stdcore[0] : masterNode(led0, p0, 0, 
			channels[CHAN_INDEX(0, NBR(0, 0), 0)], 
			channels[CHAN_INDEX(0, NBR(0, 1), 1)], 
			channels[CHAN_INDEX(0, NBR(0, 2), 2)], 
			channels[CHAN_INDEX(0, NBR(0, 3), 3)], 
			channels[CHAN_INDEX(0, NBR(0, 4), 4)], 
			channels[CHAN_INDEX(0, NBR(0, 5), 5)],
			pipe[0]);
		
		par(int i=1; i<NUM_NODES; i++) {
			on stdcore[i] : slaveNode(i,
				channels[CHAN_INDEX(i, NBR(i, 0), 0)], 
				channels[CHAN_INDEX(i, NBR(i, 1), 1)], 
				channels[CHAN_INDEX(i, NBR(i, 2), 2)], 
				channels[CHAN_INDEX(i, NBR(i, 3), 3)], 
				channels[CHAN_INDEX(i, NBR(i, 4), 4)], 
				channels[CHAN_INDEX(i, NBR(i, 5), 5)],
				pipe[i], pipe[i-1]);
		}
	}
	
	return(0);
}
