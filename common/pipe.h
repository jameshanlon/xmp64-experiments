#ifndef PIPE_H_
#define PIPE_H_

#include <print.h>
#include "definitions.h"

/*
 * Pass values along a pipe, to a sink node
 */
void pipeSinkS(int value, chanend pipein, int values[]);
void pipeSegmS(int node, int value, chanend pipein, chanend pipeout);

void pipeSinkU(unsigned int value, chanend pipein, unsigned int values[]);
void pipeSegmU(unsigned int node, unsigned int value, 
        chanend pipein, chanend pipeout);

/*
 * Pass values around a ring to share values from specific targets
 */
void ringSegm(unsigned int node, unsigned int value, 
        unsigned int values[], chanend ringin, chanend ringout);

#endif
