#include <xs1.h>
#include <print.h>
#include <platform.h>
//#include "../common/hcube.h"
//#include "../common/sync.h"

#define NUM_DIMENSIONS 6
#define NODE           5

void printResult(unsigned result) {
	printstr("Time: ");
	printuint(result);
	printstr("ns\n\n");
}

{int,int,int} masterX(chanend otherSide, timer t, int offset);
extern void slaveY(chanend otherSide, timer t, int offset);

{int, int} pingReceiver(timer tmr, chanend channel) {
	
	unsigned x, y, z;
	int rtt;
	int delta;
	int part;
	
	{x, y, z} = masterX(channel, tmr, 0);
	part = 2*x - y - z;
	delta = part / 2;
	rtt = x - y - delta;

  //asm("chkct res[%0], 0x1" :: "r"(channel)); 
  //asm("in %0,  res[%1]" :"=r"(value): "r"(channels[i])); 

	return {delta, rtt};

}

void sender(chanend channels[]) {
	
	timer tmr;
	int delta[NUM_DIMENSIONS+1];
	int hoptime[NUM_DIMENSIONS+1];
  unsigned begin, end, value;

    printstrln("Starting...");

	for(int i=0; i<NUM_DIMENSIONS+1; i++) {
		{delta[i], hoptime[i]} = pingReceiver(tmr, channels[i]);
    
    /*tmr :>begin;
    asm("outct res[%0], 0x1" :: "r"(channels[i])); 
    tmr :>end;
		printuintln((end-begin) * 10);
    tmr :>begin;
    asm("out   res[%0], %1" :: "r"(channel), "r"(0)); 
    tmr :>end;
		printuintln((end-begin) * 10);*/
		printuintln(hoptime[i] * 10);
	}

	/*for(int i=0; i<NUM_DIMENSIONS; i++) {
		printuintln(hoptime[i] * 10);
	}*/
}

void receiver(chanend channel) {
	
	timer tmr;	
	slaveY(channel, tmr, 0);
}

int main() {
	
	chan channels[NUM_DIMENSIONS+1];
	
	par {
		on stdcore[NODE] : sender(channels);
		
		//par(int i=0; i<NUM_DIMENSIONS; i++) {
		//	on stdcore[NBR(NODE, i)] : receiver(channels[i]);
		//}
		on stdcore[NODE] : receiver(channels[0]);
		on stdcore[NODE^(0x1)] : receiver(channels[1]);
		on stdcore[NODE^(0x3)] : receiver(channels[2]);
		on stdcore[NODE^(0x7)] : receiver(channels[3]);
		on stdcore[NODE^(0xF)] : receiver(channels[4]);
		on stdcore[NODE^(0x1F)] : receiver(channels[5]);
		on stdcore[NODE^(0x3F)] : receiver(channels[6]);

	}
	
	return 0;
}
