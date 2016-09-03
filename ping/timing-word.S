#define OPEN_CHANNEL

.cc_top masterX.func, masterX

.globl masterX
.globl masterX.nstackwords
.globl masterX.maxtimers
.globl masterX.maxchanends
.globl masterX.maxthreads
.linkset masterX.maxthreads, 0
.linkset masterX.nstackwords, 4
.linkset masterX.maxtimers, 0
.linkset masterX.maxchanends, 0

masterX:

    entsp 4
    stw r4, sp[1]
    stw r5, sp[2]
    stw r6, sp[3]

    // r0 : chanend otherSide
    // r1 : timer
    // r2 : offset
    
    outct  res[r0], 0x1
    chkct  res[r0], 0x1

    // Open channel
    // It doesn't matter when we receive y so perform out after in as it will
    // take time to setup the route and the slave can wait. The other way
    // round, the master waits and y is delayed. 
#ifdef OPEN_CHANNEL
    in     r3, res[r0]  // yes, i'm ready...
    out    res[r0], r3  // send slave ready?
#endif

    in     r3, res[r0]  // receive y (r3)
    in     r4, res[r1]  // measure time x (r4)
   
    out    res[r0], r4  // ping slave
    in     r5, res[r0]  // receive z (r5)
    
    outct  res[r0], 0x1
    chkct  res[r0], 0x1
    
    add    r0, r4, 0
    add    r1, r3, 0
    add    r2, r5, 0

    // returns {x, y, z}

    ldw r4, sp[1]
    ldw r5, sp[2]
    ldw r6, sp[3]
    retsp 4

.cc_bottom masterX.func

.cc_top slaveY.func, slaveY

.globl slaveY
.globl slaveY.nstackwords
.globl slaveY.maxtimers
.globl slaveY.maxchanends
.globl slaveY.maxthreads
.linkset slaveY.maxthreads, 0
.linkset slaveY.nstackwords, 0
.linkset slaveY.maxtimers, 0
.linkset slaveY.maxchanends, 0

slaveY:

    // r0 : chanend otherSide
    // r1 : timer
    // r2 : offset

    chkct  res[r0], 0x1
    outct  res[r0], 0x1

    // Open channel
#ifdef OPEN_CHANNEL
    out    res[r0], r3  // send slave ready?
    in     r3, res[r0]  // yes, i'm ready...
#endif
    
    in     r3, res[r1]  // measure time (y)
    out    res[r0], r3  // send time y
    
    in     r3, res[r0]  // wait for ping
    in     r3, res[r1]  // measure time (z)
    out    res[r0], r3  // send z
   
    chkct  res[r0], 0x1
    outct  res[r0], 0x1

retsp 0
.cc_bottom slaveY.func
