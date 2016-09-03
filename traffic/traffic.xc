#include "traffic.h"

void flash(out port led) {
	
	timer tmr;
	unsigned int t;
	unsigned int value = 1;
	
	for(int i=0; i<NUM_FLASHES; i++) {
		led <: value;
		tmr :> t;
		tmr when timerafter(t + LED_DELAY) :> void;
		value = !value;
	}
}

unsigned int chanendDest(chanend c) {
	return (chanendInt(c) >> 24) & 0xFF;	
}

/*
 * ResourceId node (n), core (c), chan (h): [000nnnn,0000cccc,000hhhhh,000000010]
 */
unsigned int getChanResId(unsigned int node, unsigned int chanendId) {
	
	unsigned int node_ = node / NUM_CORES;
	unsigned int core_ = node % NUM_CORES;
	 
	unsigned int mask3 = 0xF << 24;
	unsigned int mask2 = 0x3 << 16;
	unsigned int mask1 = 0x1F << 8;
	
	return ((node_ << 24) & mask3) | ((core_ << 16) & mask2) | ((chanendId << 8) & mask1) | (0x2 & 0xFF);
}

/*
 * Receiver node footer: syphon data back to master node
 */
void gatherResults(unsigned int node, unsigned int max, unsigned int step, 
		unsigned int avg, unsigned int bins[], chanend pipein, chanend pipeout) {
	
	unsigned int collectedAvgs[NUM_NODES];
	unsigned int collectedBins[BINS][NUM_NODES];
	                       
	if(MASTER(node)) {
		
		/*printstrln("----");
		printuintln(max);
		printuintln(step);
		printstrln("----");*/
		
		// Receive data from all slave nodes.
		for(int i=0; i<BINS; i++)
			pipeSinkU(bins[i], pipein, collectedBins[i]);
		
		pipeSinkU(avg, pipein, collectedAvgs);
		
		writeResults(collectedAvgs, collectedBins, max);
		
	} else {
	
		// Send all data back to master
		for(int i=0; i<BINS; i++)
			pipeSegmU(node, bins[i], pipein, pipeout);
		
		pipeSegmU(node, avg, pipein, pipeout);
	}
}

void verifySharedValues(unsigned int node, unsigned int values[], chanend pipein, chanend pipeout) {
	
	unsigned int verify[NUM_NODES][NUM_NODES];
	
	if(MASTER(node)) {
		
		for(int i=0; i<NUM_NODES; i++)
			pipeSinkU(values[i], pipein, verify[i]);
		
		for(int i=0; i<NUM_NODES; i++) {
			for(int j=0; j<NUM_NODES; j++) {
				if(verify[i][j] != verify[i][0]) {
					printstrln("*");
				}
			}
			//printuintln(verify[i][0]);
		}
		//printstrln("----------");
		
	} else {
		
		for(int i=0; i<NUM_NODES; i++)
			pipeSegmU(node, values[i], pipein, pipeout);
	}
	
}

void gatherValues(unsigned int node, unsigned int value, chanend pipein, chanend pipeout) {
	
	unsigned int data[NUM_NODES];
	
	if(MASTER(node)) {
		
		pipeSinkU(value, pipein, data);
		
		printstrln("Values:");
		for(int i=0; i<NUM_NODES; i++)
			printuintln(data[i]);
		printstrln("----");
		
	} else {
		
		pipeSegmU(node, value, pipein, pipeout);
	}
	
}

void shareValues(unsigned int node, unsigned int value, unsigned int values[NUM_NODES], 
		chanend pipein, chanend pipeout, chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {
	
	if(MASTER(node)) {
		
		pipeSinkU(value, pipein, values);
		
		for(int i=0; i<NUM_NODES; i++)
			distributeValue(node, values[i], d1, d2, d3, d4, d5, d6);
		
	} else {
		
		pipeSegmU(node, value, pipein, pipeout);
		
		for(int i=0; i<NUM_NODES; i++)
			values[i] = distributeValue(node, 0, d1, d2, d3, d4, d5, d6);
		
		/*if(node == 3) {
			for(int i=0; i<NUM_NODES; i++) {
				printuintln(values[i]);
			}
			printstrln("----------");
		}*/
	}
}

unsigned int checkReset(unsigned int node, unsigned int reset, 
		chanend pipein, chanend pipeout, chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {
	
	unsigned int resets[NUM_NODES];
	unsigned int masterReset = 0;
	
	if(MASTER(node)) {
			
		pipeSinkU(reset, pipein, resets);
		
		for(int i=0; i<NUM_NODES; i++) {
			if(resets[i] == 1)
				masterReset = 1;
		}
			
		return distributeValue(node, masterReset, d1, d2, d3, d4, d5, d6);
		
	} else {
		
		pipeSegmU(node, reset, pipein, pipeout);
		
		return distributeValue(node, 0, d1, d2, d3, d4, d5, d6);
	}
}

/*
 * (slave) Sender thread
 */
void sender(chanend receiver, chanend out_) {
		
	timer tmr;
	int offset;
	unsigned int start;
	unsigned int dstChanend;
	
	// Make exchanges with (master) receiver threads
	receiver <: chanendInt(out_);
	
	if(TRAFFIC_PATTERN != RANDOM)
		receiver :> dstChanend;
	
	receiver :> offset;
	
	for(int i=0; i<TOTAL_RUNS; i++) {
		
		if(TRAFFIC_PATTERN == RANDOM)
			receiver :> dstChanend;
		
		// After master delay, start sending
		receiver :> start;
		tmr when timerafter(start + offset) :> void;
		
		send_(tmr, offset, MSG_LEN, dstChanend, out_);
	}
}

/*
 * (master) Receiver, with LED
 */
void receiver(
		out port led, unsigned int node, chanend sender,
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6,	
		chanend pipein, chanend pipeout, 
		chanend in_) {
	
	led <: 1;
	if(MASTER(node))
		printstrln("Starting...");
	receiver_(node, sender, d1, d2, d3, d4, d5, d6, pipein, pipeout, in_);
	led <: 0;
	flash(led);
}

/*
 * (master) Receiver, without LED
 */
void receiver_(
		unsigned int node, chanend sender,
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6,
		chanend pipein, chanend pipeout, 
		chanend in_) {

	timer tmr;
	int offset;
	unsigned int start;
	unsigned int tripTime;
	
	unsigned int max;
	unsigned int bins[BINS];
	unsigned int total;
	unsigned int step;
	unsigned int perm[NUM_NODES];
	unsigned int seed;
	
	unsigned int sendChanend;
	unsigned int recvChanend;
	unsigned int srcChanend[NUM_NODES];
	unsigned int dstChanend[NUM_NODES];
	unsigned int src;
	unsigned int dst;
	
	unsigned int reset;
	
	// Initialise
	total = 0;
	offset = 0;
	seed = SEED;
	max = 0;
	reset = 0;
	for(int i=0; i<BINS; i++) bins[i] = 0;
	for(int i=0; i<NUM_NODES; i++) perm[i] = i;
	
	// Collate all of the chanend identifiers
	sender :> sendChanend;
	recvChanend = chanendInt(in_);
	shareValues(node, sendChanend, srcChanend, pipein, pipeout, d1, d2, d3, d4, d5, d6);
	shareValues(node, recvChanend, dstChanend, pipein, pipeout, d1, d2, d3, d4, d5, d6);
	
	// Initialise static traffic patterns
	if(TRAFFIC_PATTERN != RANDOM) {
		{src, dst} = initPerm(node, seed, perm);
		sender <: dstChanend[dst];
	}
		
	//verifySharedValues(node, perm, pipein, pipeout);
	//verifySharedValues(node, srcChanend, pipein, pipeout);
	//verifySharedValues(node, dstChanend, pipein, pipeout);
	
	// Exchange offsets with other nodes
	offset = getOffset(tmr, node, d1, d2, d3, d4, d5, d6);
	sender <: offset;
	
	for(int i=0; i<TOTAL_RUNS; i++) {
		
		/*if(MASTER(node) && i%10 == 0)
			printuintln(i);*/
		
		// Generate a random perm and setup channel end
		if(TRAFFIC_PATTERN == RANDOM)  {
			{src, dst} = initPerm(node, seed, perm);
			sender <: dstChanend[dst];
		}
		
		// Distribute a start time
		if(MASTER(node)) {
			tmr :> start;
			start += START_DELAY;
		} else {
			start = 0;
		}

		start = getStart(node, start, d1, d2, d3, d4, d5, d6);
		sender <: start;
		
		// Wait to start
		tmr when timerafter(start + offset) :> void;
		
		// Receive message
		tripTime = recv_(tmr, offset, MSG_LEN, srcChanend[src], in_);
		//tripTime = recv(tmr, offset, MSG_LEN, in_);
		
		total += tripTime;
		
		// Initialise bins or record data
		/*if(INIT_BINS(i)) {
			if(tripTime > max)
				max = tripTime;
			max = getMax(node, max, d1, d2, d3, d4, d5, d6);
			if(LAST_INIT_RUN(i)) {
				max = BIN_MAX(max);
				step = max / BINS;
			}
		} else {
			if(tripTime/step > BINS) {
				printstrln("#");
				reset = 1;
			} else {
				bins[tripTime / step]++;
				total += tripTime;
			}
			
			// Bit of a hack...
			if(checkReset(node, reset, pipein, pipeout, d1, d2, d3, d4, d5, d6)) {
				
				if(MASTER(node)) {
					printstr("*");
				}
				
				// Get new max
				max = getMax(node, tripTime, d1, d2, d3, d4, d5, d6);
				max = BIN_MAX(max);
				step = max / BINS;
				
				// Initialise
				i = 0;
				for(int j=0; j<BINS; j++)
					bins[j] = 0;
				total = 0;
				reset = 0;
				
				if(MASTER(node)) {
					printuintln(max);
				}
			}
		}*/
	}
		
	gatherResults(node, max, step, total/RUNS, bins, pipein, pipeout);
}

