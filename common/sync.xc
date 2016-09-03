#include "sync.h"

int getDimOffset(timer tmr, int node, int neighbour, chanend d, int offset) {
	
	unsigned x, y, z;
	int hopTime;
	int delta;
	int part;
	
	if(node > neighbour) {
		{x, y, z} = masterX(d, tmr, offset);
		part = 2*x - y - z;
		delta = part / 2;
		hopTime = x - y - delta;
		d <: hopTime;
	} else {
		slaveY(d, tmr, offset);
		d :> hopTime;
		delta = 0;
	}

	//return {delta, hopTime};
	return delta;
}

int getAvgDimOffset(int dimOffset, chanend d, int node, unsigned int neighbour) {
	
	int recvDimOffset;
		
	if(node > neighbour) {
		d <: dimOffset;
		d :> recvDimOffset;
	} else {
		d :> recvDimOffset;
		d <: dimOffset;
	}
	
	return recvDimOffset;
}

int getAvgOffset2D(int dimOffset, unsigned int node, unsigned int dimension, chanend d1) {
	
	int total = dimOffset;
	
	switch(dimension) {
	case 0:
		break;
	case 1:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		break;
	}

	return total / (0x1 << dimension);
}

int getAvgOffset4D(int dimOffset, int node, int dimension, chanend d1, chanend d2, chanend d3) {
	
	int total = dimOffset;
	
	switch(dimension) {
	case 0:
		break;
	case 1:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		break;
	case 2:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		total += getAvgDimOffset(total, d2, node, NBR(node, 1));
		break;
	case 3:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		total += getAvgDimOffset(total, d2, node, NBR(node, 1));
		total += getAvgDimOffset(total, d3, node, NBR(node, 2));
		break;
	}
	
	return total / (0x1 << dimension);
}

int getAvgOffset6D(int dimOffset, unsigned int node, unsigned int dimension, 
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5) {
	
	int total = dimOffset;
	
	switch(dimension) {
	case 0:
		break;
	case 1:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		break;
	case 2:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		total += getAvgDimOffset(total, d2, node, NBR(node, 1));
		break;
	case 3:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		total += getAvgDimOffset(total, d2, node, NBR(node, 1));
		total += getAvgDimOffset(total, d3, node, NBR(node, 2));
		break;
	case 4:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		total += getAvgDimOffset(total, d2, node, NBR(node, 1));
		total += getAvgDimOffset(total, d3, node, NBR(node, 2));
		total += getAvgDimOffset(total, d4, node, NBR(node, 3));
		break;
	case 5:
		total += getAvgDimOffset(total, d1, node, NBR(node, 0));
		total += getAvgDimOffset(total, d2, node, NBR(node, 1));
		total += getAvgDimOffset(total, d3, node, NBR(node, 2));
		total += getAvgDimOffset(total, d4, node, NBR(node, 3));
		total += getAvgDimOffset(total, d5, node, NBR(node, 4));
		break;
	}
	
	return total / (0x1 << dimension);
}

/*
 * Get the clock offset to the master node 0
 */
int getOffset(timer tmr, unsigned int node, chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {

	int offset = 0;
	int dimOffset;
	
	dimOffset = getDimOffset(tmr, node, NBR(node, 0), d1, offset);
	offset += getAvgOffset6D(dimOffset, node, 0, d1, d2, d3, d4, d5);
	
	dimOffset = getDimOffset(tmr, node, NBR(node, 1), d2, offset);
	offset += getAvgOffset6D(dimOffset, node, 1, d1, d2, d3, d4, d5);
	
	dimOffset = getDimOffset(tmr, node, NBR(node, 2), d3, offset);
	offset += getAvgOffset6D(dimOffset, node, 2, d1, d2, d3, d4, d5);
	
	dimOffset = getDimOffset(tmr, node, NBR(node, 3), d4, offset);
	offset += getAvgOffset6D(dimOffset, node, 3, d1, d2, d3, d4, d5);
	
	dimOffset = getDimOffset(tmr, node, NBR(node, 4), d5, offset);
	offset += getAvgOffset6D(dimOffset, node, 4, d1, d2, d3, d4, d5);
	
	dimOffset = getDimOffset(tmr, node, NBR(node, 5), d6, offset);
	offset += getAvgOffset6D(dimOffset, node, 5, d1, d2, d3, d4, d5);
	
	return offset;
}
