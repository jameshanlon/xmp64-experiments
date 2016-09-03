.cc_top send.func, send

.globl send
.globl send.nstackwords
.globl send.maxtimers
.globl send.maxchanends
.globl send.maxthreads
.linkset send.maxthreads, 0
.linkset send.nstackwords, 4
.linkset send.maxtimers, 0
.linkset send.maxchanends, 0

send:

    entsp 0x4
    stw r4, sp[0x1]
    stw r5, sp[0x2]
    stw r6, sp[0x3]

    // r0 : timer tmr
    // r1 : int offset
    // r2 : int msgLen
    // r3 : chanend out
    
    ldc    r5, 0x0      // i=0
    
    in     r4, res[r0]  // measure time x (r4)
    sub    r4, r4, r1   // adjust time offset
   
sendloop:
    out    res[r3], r4  // send timestamp message to destination
    add    r5, r5, 0x1  // i++
    lss    r6, r5, r2
    bt     r6, sendloop // for(i=0; i<msglen; i++)
    
    outct  res[r3], 0x1

    ldw r4, sp[0x1]
    ldw r5, sp[0x2]
    ldw r6, sp[0x3]
    retsp 0x4

.cc_bottom send.func



.cc_top recv.func, recv

.globl recv
.globl recv.nstackwords
.globl recv.maxtimers
.globl recv.maxchanends
.globl recv.maxthreads
.linkset recv.maxthreads, 0
.linkset recv.nstackwords, 4
.linkset recv.maxtimers, 0
.linkset recv.maxchanends, 0

recv:

    entsp 0x4
    stw r4, sp[0x1]
    stw r5, sp[0x2]
    stw r6, sp[0x3]

    // r0 : timer tmr
    // r1 : int offset
    // r2 : int msgLen
    // r3 : chanend in
    
    ldc    r5, 0x0      // i=0
    
recvloop:
    in     r4, res[r3]  // receive message (r4)
	add    r5, r5, 0x1  // i++
    lss    r6, r5, r2
    bt     r6, recvloop // for(i=0; i<msglen; i++)

	chkct  res[r3], 0x1

    in     r6, res[r0]  // measure time received
    sub    r6, r6, r1   // adjust time offset
    
    sub    r5, r6, r4   // calculate fly time
    add    r0, r5, 0    // return message fly time

    ldw r4, sp[0x1]
    ldw r5, sp[0x2]
    ldw r6, sp[0x3]
    retsp 0x4

.cc_bottom recv.func


/*
 * Send some data, but with a specified target
 */
.cc_top send_.func, send_

.globl send_
.globl send_.nstackwords
.globl send_.maxtimers
.globl send_.maxchanends
.globl send_.maxthreads
.linkset send_.maxthreads, 0
.linkset send_.nstackwords, 5
.linkset send_.maxtimers, 0
.linkset send_.maxchanends, 0

send_:

    entsp 0x5
    stw r4, sp[0x1]
    stw r5, sp[0x2]
    stw r6, sp[0x3]
    stw r7, sp[0x4]
    
    ldw r4, sp[0x6]

    // r0 : timer tmr
    // r1 : int offset
    // r2 : int msgLen
    // r3 : unsigned destination
    // r4 : chanend out
    
    setd   res[r4], r3
    ldc    r6, 0x0      // i=0
    
    in     r5, res[r0]  // measure time x (r5)
    sub    r5, r5, r1   // adjust time offset
   
send_loop:
    out    res[r4], r5  // send_ timestamp message to destination
    add    r6, r6, 0x1  // i++
    lss    r7, r6, r2
    bt     r7, send_loop // for(i=0; i<msglen; i++)
    
    outct  res[r4], 0x1

    ldw r4, sp[0x1]
    ldw r5, sp[0x2]
    ldw r6, sp[0x3]
    ldw r7, sp[0x4]
    retsp 0x5

.cc_bottom send_.func


/*
 * Receive some data, but with a specified source
 */
.cc_top recv_.func, recv_

.globl recv_
.globl recv_.nstackwords
.globl recv_.maxtimers
.globl recv_.maxchanends
.globl recv_.maxthreads
.linkset recv_.maxthreads, 0
.linkset recv_.nstackwords, 5
.linkset recv_.maxtimers, 0
.linkset recv_.maxchanends, 0

recv_:

    entsp 0x5
    stw r4, sp[0x1]
    stw r5, sp[0x2]
    stw r6, sp[0x3]
    stw r7, sp[0x4]
    
    ldw r4, sp[0x6]

    // r0 : timer tmr
    // r1 : int offset
    // r2 : int msgLen
    // r3 : unsigned destination
    // r4 : chanend in
    
    setd   res[r4], r3
    ldc    r6, 0x0      // i=0
    
recv_loop:
    in     r5, res[r4]  // receive message (r5)
	add    r6, r6, 0x1  // i++
    lss    r7, r6, r2
    bt     r7, recv_loop // for(i=0; i<msglen; i++)

	chkct  res[r4], 0x1

    in     r6, res[r0]  // measure time received
    sub    r6, r6, r1   // adjust time offset
    
    sub    r6, r6, r5   // calculate fly time
    
    add    r0, r6, 0    // return message fly time
    
    ldw r4, sp[0x1]
    ldw r5, sp[0x2]
    ldw r6, sp[0x3]
    ldw r7, sp[0x4]
    retsp 0x5

.cc_bottom recv_.func

/*
 * Return a chanend id as an int
 */
.cc_top chanendInt.func, chanendInt

.globl chanendInt
.globl chanendInt.nstackwords
.globl chanendInt.maxtimers
.globl chanendInt.maxchanends
.globl chanendInt.maxthreads
.linkset chanendInt.maxthreads, 0
.linkset chanendInt.nstackwords, 0
.linkset chanendInt.maxtimers, 0
.linkset chanendInt.maxchanends, 0

chanendInt:

    entsp 0
    
    retsp 0

.cc_bottom chanendInt.func

