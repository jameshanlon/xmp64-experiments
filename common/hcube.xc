#include "hcube.h"

unsigned int distributeDimValue(unsigned int node, unsigned int neighbour, chanend d, unsigned int value) {
	
	unsigned int recv;
	
	if(node > neighbour) {
		d :> recv;
		return recv;
	} else {
		d <: value;
		return value;
	}
}

unsigned int distributeValue(unsigned int node, unsigned int value, 
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {
	
	unsigned int v = value;

	v = distributeDimValue(node, NBR(node, 0), d1, v);
	v = distributeDimValue(node, NBR(node, 1), d2, v);
	v = distributeDimValue(node, NBR(node, 2), d3, v);
	v = distributeDimValue(node, NBR(node, 3), d4, v);
	v = distributeDimValue(node, NBR(node, 4), d5, v);
	v = distributeDimValue(node, NBR(node, 5), d6, v);
	
	return v;
}

unsigned int getDimStart(unsigned int node, unsigned int neighbour, chanend d, unsigned int time) {
	
	unsigned int recvTime;
	
	if(node > neighbour) {
		d :> recvTime;
		return recvTime;
	} else {
		d <: time;
		return time;
	}
}

unsigned int getStart(unsigned int node, unsigned int start, 
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {
	
	unsigned int time = start;

	time = getDimStart(node, NBR(node, 0), d1, time);
	time = getDimStart(node, NBR(node, 1), d2, time);
	time = getDimStart(node, NBR(node, 2), d3, time);
	time = getDimStart(node, NBR(node, 3), d4, time);
	time = getDimStart(node, NBR(node, 4), d5, time);
	time = getDimStart(node, NBR(node, 5), d6, time);
	
    return time;
}

unsigned int getDimMin(unsigned int node, unsigned int dimension, chanend d, unsigned int min) {
	
	unsigned int recv;
	unsigned int neighbour = NBR(node, dimension);
	
	if(node > neighbour) {
		d :> recv;
		d <: min;
	} else {
		d <: min;
		d :> recv;
	}
	
	return recv < min ? recv : min;
}

unsigned int getDimMax(unsigned int node, unsigned int dimension, chanend d, unsigned int max) {
	
	unsigned int recv;
	unsigned int neighbour = NBR(node, dimension);
	
	if(node > neighbour) {
		d :> recv;
		d <: max;
	} else {
		d <: max;
		d :> recv;
	}
	
	return recv > max ? recv : max;
}

unsigned int getMin(unsigned int node, unsigned int init, 
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {
	
	unsigned int min = init;

	min = getDimMin(node, 0, d1, min);
	min = getDimMin(node, 1, d2, min);
	min = getDimMin(node, 2, d3, min);
	min = getDimMin(node, 3, d4, min);
	min = getDimMin(node, 4, d5, min);
	min = getDimMin(node, 5, d6, min);
	
    return min;
}

unsigned int getMax(unsigned int node, unsigned int init, 
		chanend d1, chanend d2, chanend d3, chanend d4, chanend d5, chanend d6) {
	
	unsigned int max = init;

	max = getDimMax(node, 0, d1, max);
	max = getDimMax(node, 1, d2, max);
	max = getDimMax(node, 2, d3, max);
	max = getDimMax(node, 3, d4, max);
	max = getDimMax(node, 4, d5, max);
	max = getDimMax(node, 5, d6, max);
	
	return max;
}
