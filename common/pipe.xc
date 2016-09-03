#include "pipe.h"

void pipeSinkS(int value, chanend pipein, int values[]) {

	int recv;
	
	values[0] = value;
	
	for(int i=1; i<NUM_NODES; i++) {
		pipein :> recv;
		values[i] = recv;
	}
}

void pipeSegmS(int node, int value, chanend pipein, chanend pipeout) {
	
	int numRecv = NUM_NODES - node -1;
	int forward;
	
	pipeout <: value;
	if(node != NUM_NODES-1) {
		for(int i=0; i<numRecv; i++) {
			pipein :> forward;
			pipeout <: forward;
		}
	}
}

void pipeSinkU(unsigned int value, chanend pipein, unsigned int values[]) {

	unsigned recv;
	
	values[0] = value;
	
	for(int i=1; i<NUM_NODES; i++) {
		pipein :> recv;
		values[i] = recv;
	}
}

void pipeSegmU(unsigned int node, unsigned int value, chanend pipein, chanend pipeout) {
	
	int numRecv = NUM_NODES - node -1;
	unsigned forward;
	
	pipeout <: value;
	if(node != NUM_NODES-1) {
		for(int i=0; i<numRecv; i++) {
			pipein :> forward;
			pipeout <: forward;
		}
	}
}

/*
 * Ring segment
 * 
 * For node a of n, output value then receive {a-1,...,0,n,...,a+1}. Where n must be even
 *
 * NOTE: this doesn't work
 */
void ringSegm(unsigned int node, unsigned int value, unsigned int values[], chanend ringin, chanend ringout) {

	unsigned int forward;
	unsigned int forward_;
	unsigned int currentNode;
	
	values[node] = value;
	
	if(node % 2 == 0) {
		ringout <: value;
		ringin :> forward;
	} else {
		ringin :> forward;
		ringout <: value;
	}
	
	// Circulate values and pick out the target value
	for(int i=1; i<NUM_NODES; i++) {
		
		currentNode = (node - i) % NUM_NODES;
		values[currentNode] = forward;
		
		if(node % 2 == 0) {
			 ringout <: forward;
			 ringin :> forward;
		} else {
			 ringin :> forward_;
			 ringout <: forward;
			 forward = forward_;
		}
		
	}
	
	if(node == 3) {
		for(int i=0; i<NUM_NODES; i++) {
			printuintln(values[i]);
		}
		printstrln("----------");
	}
}

