.globl barrier.nstackwords
.globl barrier.maxtimers
.globl barrier.maxchanends
.globl barrier.maxthreads

.linkset barrier.nstackwords, 7
.linkset barrier.maxtimers, 0
.linkset barrier.maxchanends, 0
.linkset barrier.maxthreads, 0

.globl barrier
.cc_top barrier.func, barrier
.text

barrier:

    // Arguments:
    // r0 : timer
    // r1 : chanend d1
    // r2 : chanend d2
    // r3 : chanend d3
    // r4 : chanend d4
    // r5 : chanend d5
    // r6 : chanend d6
    
    // Variables:
    // r7 : begin
    // r8 : end
    // r9 : elapsed

    entsp  0x7
    stw    r4, sp[0x1]
    stw    r5, sp[0x2]
    stw    r6, sp[0x3]
    stw    r7, sp[0x4]
    stw    r8, sp[0x5]
    stw    r9, sp[0x6]
    
    ldw    r4, sp[0x8]
    ldw    r5, sp[0x9]
    ldw    r6, sp[0xA]
    
    in     r7, res[r0]  // timer :> begin

    outct  res[r1], 0x1
    chkct  res[r1], 0x1
    
    outct  res[r2], 0x1
    chkct  res[r2], 0x1
    
    outct  res[r3], 0x1
    chkct  res[r3], 0x1
    
    outct  res[r4], 0x1
    chkct  res[r4], 0x1
    
    outct  res[r5], 0x1
    chkct  res[r5], 0x1
    
    outct  res[r6], 0x1
    chkct  res[r6], 0x1
    
    in     r8, res[r0]  // timer :> end
    sub    r9, r8, r7   // elapsed = end - begin
    mov    r0, r9
    
    // returns elapsed

    ldw    r4, sp[0x1]
    ldw    r5, sp[0x2]
    ldw    r6, sp[0x3]
    ldw    r7, sp[0x4]
    ldw    r8, sp[0x5]
    ldw    r9, sp[0x6]
    retsp  0x7

.cc_bottom barrier.func
