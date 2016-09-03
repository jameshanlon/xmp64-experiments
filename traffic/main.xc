#include <platform.h>
#include "traffic.h"
#include "../common/definitions.h"

#define FIRST(src, dim) (src < NBR(src, dim) ? src : NBR(src, dim))
#define CHAN(src, dim)  (FIRST(src, dim) * NUM_DIMENSIONS + dim)

out port leds[] = {
    on stdcore[0] : XS1_PORT_1E,
    on stdcore[4] : XS1_PORT_1E,
    on stdcore[8] : XS1_PORT_1E,
    on stdcore[12]: XS1_PORT_1E,
    on stdcore[16]: XS1_PORT_1E,
    on stdcore[20]: XS1_PORT_1E,
    on stdcore[24]: XS1_PORT_1E,
    on stdcore[28]: XS1_PORT_1E,
    on stdcore[32]: XS1_PORT_1E,
    on stdcore[36]: XS1_PORT_1E,
    on stdcore[40]: XS1_PORT_1E,
    on stdcore[44]: XS1_PORT_1E,
    on stdcore[48]: XS1_PORT_1E,
    on stdcore[52]: XS1_PORT_1E,
    on stdcore[56]: XS1_PORT_1E,
    on stdcore[60]: XS1_PORT_1E
};

int main() {

	chan hcube[NUM_NODES * NUM_DIMENSIONS];
	chan pipe[NUM_NODES];
	chan traffic[NUM_NODES];
	chan pairs[NUM_NODES];

    par {

        // Receivers
        par (int i=0; i<NUM_NODES; i+=NUM_CORES) {

            on stdcore[i] : receiver(leds[i/4], i, pairs[i], 
                hcube[CHAN(i, 0)], hcube[CHAN(i, 1)], hcube[CHAN(i, 2)], 
                hcube[CHAN(i, 3)], hcube[CHAN(i, 4)], hcube[CHAN(i, 5)], 
                pipe[i], pipe[(i-1)%NUM_NODES], 
                traffic[i]);

            par (int j=1; j<NUM_CORES; j++) {
                on stdcore[i+j] : receiver_(i+j, pairs[i+j],
                    hcube[CHAN(i+j, 0)], hcube[CHAN(i+j, 1)], hcube[CHAN(i+j, 2)], 
                    hcube[CHAN(i+j, 3)], hcube[CHAN(i+j, 4)], hcube[CHAN(i+j, 5)], 
                    pipe[i+j], pipe[(i+j-1)%NUM_NODES], 
                    traffic[i+j]);
            }
        }

        // Senders
        par (int i=0; i<NUM_NODES; i++) {
            on stdcore[i] : sender(pairs[i], traffic[i^1]);
        }
    }

    return 0;
}
