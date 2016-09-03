#include <print.h>
#include <syscall.h>

#include "output.h"

int readConfig() {
}

int writeResults(unsigned avg[], unsigned bins[BINS][NUM_NODES], unsigned max) {
	
	int fd = 0;
	unsigned numBytesWritten;
	
	// Open
	fd = _open("data.out", O_WRONLY | O_CREAT | O_TRUNC, S_IREAD | S_IWRITE);
  
	if (fd == -1) {
		printstrln("Error: open (write) failed");
		return 0;
	}

	// Write
	numBytesWritten = 0;
	numBytesWritten += _write(fd, (avg, char[]),  NUM_NODES*4);
	numBytesWritten += _write(fd, (bins, char[]), BINS*NUM_NODES*4);
	numBytesWritten += _write(fd, (max, char[]),  4);
	
	if (numBytesWritten != (NUM_NODES*4 + BINS*NUM_NODES*4 + 4)) {
		printstrln("Error: Written incorrect number of bytes to the file.\n");
		return 0;
	}

	// Close
	if (_close(fd) != 0) {
		printstrln("Error: close (write) failed.");
		return 0;
	}
	
	printstr("Wrote file: data.out. Num bytes: ");
	printintln(numBytesWritten);
	
	return 1;
}

/*int writePerms(unsigned int perms[NUM_NODES][NUM_NODES], int iteration) {
	
	int fd = 0;
	unsigned int numBytesWritten;
	unsigned int size = NUM_NODES*NUM_NODES*4;
	
	// Open
	fd = _open(file[iteration], O_WRONLY | O_CREAT | O_TRUNC, S_IREAD | S_IWRITE);
  
	if (fd == -1) {
		printstrln("Error: open (write) failed");
		return 0;
	}

	// Write
	numBytesWritten = _write(fd, (perms, char[]), size);
	
	if (numBytesWritten != size) {
		printstrln("Error: Written incorrect number of bytes to the file.\n");
		return 0;
	}

	// Close
	if (_close(fd) != 0) {
		printstrln("Error: close (write) failed.");
		return 0;
	}
	
	printstr("Wrote file: ");
	printstr(file[iteration]);
	printstr("Num bytes: ");
	printintln(numBytesWritten);
	
	return 1;
}*/
