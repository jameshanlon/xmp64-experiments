#include "permutations.h"

/*
 * Use CRC to produce random numbers
 */
unsigned int random(unsigned int seed) {
    crc32(seed, 0, 0xEB31D82E);
    return seed;
}

/*
 * Perform a random shuffle on the perm array, with a seed value
 */
void rshuffle(unsigned perm[], unsigned int &seed) {
    
	unsigned int k;
	unsigned int tmp;
	unsigned int n = NUM_NODES;
	
    while(n > 1) {
        n--;
        seed = random(seed);
        k =  seed % (n + 1);
        tmp = perm[k];
        perm[k] = perm[n];
        perm[n] = tmp;
    }
}

/*
 * Roatate source bits by shift
 */
unsigned int rotr_(unsigned int source, unsigned int len, unsigned int shift) {
	
	unsigned int maskLo = (1 << (len - shift)) - 1;
	unsigned int maskHi = ((1 << len) - 1) ^ maskLo;
    
    return ((source >> shift) & maskLo) | ((source << (len - shift)) & maskHi);
}

/*
 * Rotate only the top four bits of the n-bit identifier (length depends on number threads 64-512, powers of 2)
 * B/c: these represent 4 dimensions of hypercube
 */
unsigned int rotr(unsigned int source, unsigned int shift) {
	
	unsigned int nBottomBits = NUM_DIMENSIONS - OUTER_DIMENSIONS;
	unsigned int nTopBits = OUTER_DIMENSIONS;
	
	unsigned int maskLo = (1 << nBottomBits) - 1;
	unsigned int maskHi = ((1 << NUM_DIMENSIONS) - 1) ^ maskLo;
	
	unsigned int rotated = rotr_(((source >> nBottomBits) & (maskHi >> nBottomBits)), nTopBits, shift);
	
	return ((rotated << nBottomBits) & maskHi) | (source & maskLo);
}

/*
 * Reverse the bits of value
 */
unsigned int reverse(unsigned int value, unsigned int bits) {
		
	unsigned int r = value; // r will be reversed bits of v; first get LSB of v
	unsigned int s = bits - 1; // extra shift needed at end

	for (value >>= 1; value > 0; value >>= 1) {
	    r <<= 1;
	    r |= value & 1;
	    s--;
	}
	r <<= s; // shift when v's highest bits are zero
	
	return r & ((0x1 << bits) - 1);
}

/*
 * Reverse only the outer-dimension bits
 */
unsigned int bitrev_(unsigned int source) {
	
	unsigned int shift = NUM_DIMENSIONS - OUTER_DIMENSIONS;
	unsigned int mask = (0x1 << NUM_DIMENSIONS) - 1;
	unsigned int highBits = (source >> shift) & mask;
	unsigned int reversed = reverse(highBits, OUTER_DIMENSIONS);
	
	return (reversed << shift) | (source & ((0x1 << shift) -1));
}

void transpose(unsigned int perm[]) {
	for(unsigned int i=0; i<NUM_NODES; i++)
		perm[i] = rotr(i, 2);
}

void shuffle(unsigned int perm[]) {
	for(unsigned int i=0; i<NUM_NODES; i++)
		perm[i] = rotr(i, 1);
}

void bitcomp(unsigned int perm[]) {
	for(unsigned int i=0; i<NUM_NODES; i++)
		perm[i] = (~i) & (NUM_NODES - 1);
}

void bitrev(unsigned int perm[]) {
	for(unsigned int i=0; i<NUM_NODES; i++)
		perm[i] = bitrev_(i);
}

void neighbour(unsigned int perm[]) {
	for(unsigned int i=0; i<NUM_NODES; i++)
		perm[i] = (i + 1) % NUM_NODES;
}

/*
 * Return {source, destination} nodes for a permutation
 */
{unsigned int, unsigned int} initPerm(unsigned int node, unsigned int &seed, unsigned int perm[]) {

	unsigned int source;
	
	switch(TRAFFIC_PATTERN) {
	case SHUFFLE:   shuffle(perm);        break;
	case TRANSPOSE: transpose(perm);      break;
	case BITCOMP:   bitcomp(perm);        break;
	case BITREV:    bitrev(perm);         break;
	case RANDOM:    rshuffle(perm, seed); break;
	case NEIGHBOUR: neighbour(perm);      break;
	}
	
	for(source=0; source<NUM_NODES; source++)
		if(perm[source] == node) break;
	
	return {source, perm[node]};
}
