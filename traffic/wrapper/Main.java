package wrapper;

import java.util.Arrays;

public class Main {	
    
    private static final int NUM_NODES = 64;
    private static final int BINS = 100;

	private static int compile(boolean printOutput) {
		
		long begin, end;
		
		System.out.print("\tCompiling...");
		begin = System.currentTimeMillis();
	    int exit = Utilities.exec("make traffic.xe", ".", printOutput);
	    end = System.currentTimeMillis();
	    System.out.println("Done ("+((end-begin)/1000)+"s)");
	    
	    return exit;
	}
	
	private static int run(boolean printOutput) {
		
		long begin, end;
		System.out.println("\tRunning...");
	    begin = System.currentTimeMillis();
	    int exit = Utilities.exec("xrun --io traffic.xe", ".", printOutput);
	    end = System.currentTimeMillis();
	    System.out.println("Done ("+((end-begin)/1000)+"s)");
	    return exit;
	}
	
	private static long getAvgLatency(long[] values) {
		
		long[] averages = new long[NUM_NODES];
	    
		for(int k=0; k<NUM_NODES; k++)
	    	averages[k] = values[k];
		
		return Utilities.average(averages);
	}
	
	private static long[] getLatencyDist(long[] values) {
	
	    long[][] bins = new long[BINS][NUM_NODES];
	    long[] count = new long[BINS];
	    long total = 0;
	    
	    //System.out.println("\nLatency distributions:");
	    
	    for(int k=0; k<BINS; k++) {
	    	count[k] = 0;
	    	for(int l=0; l<NUM_NODES; l++) {
	    		int index = k*NUM_NODES + l;
	    		bins[k][l] = values[index];
	    		count[k] += bins[k][l];
	    		total += count[k];
	    		//System.out.print(bins[k][l]+(l+1!=BuildPar.numNodes()?"\t":"\n"));
	    	}
	    	//System.out.println(count[k]);
	    }

	    System.out.println("TOTAL SAMPLES: "+total);
	    
	    return count;
	}
	
	/*
	 * Experiment 1
	 */
	public static void experiment1() {
		
		int iterations = 4;
		int initMsgLen = 4;
		String resultsDir = "results";
		
		Results results = new Results(resultsDir);
		
        int msgLen = initMsgLen;
        
        // For each message size...
        for(int j=0; j<iterations; j++) {
            
            System.out.println("[Message size = "+msgLen+" bytes]");
            
            if(run(true) != 0) return;
            
            System.out.println("\tCollecting data...");
            long[] values = Utilities.readBinFile("data.out");
           
            long avgLatency = getAvgLatency(Arrays.copyOfRange(values, 0, NUM_NODES));
            System.out.println("\nOverall average latency: "+avgLatency);
            
            msgLen *= 2;
        }
        
        /*series.writeData(resultsDir);
		results.createLatencyGraph(resultsDir, "Message Size vs. Average Latency", 
				"Message size (bytes)", "Average Latency (ns)", -1, -1, -1, -1,
                false);*/
	}
	
	/*
	 * Experiment 2
	 */
	public static void experiment2() {
		
		int numThreads = 1;
		int msgLen = 32;
		
		String resultsDir = "results";
		Results results = new Results(resultsDir);
		
        System.out.println("[Message size = "+msgLen+" bytes]");
        
        if(run(true) != 0) return;
        
        System.out.println("\tCollecting data...");
        long[] values = Utilities.readBinFile("data.out");
        long[] latencyDist = getLatencyDist(
                Arrays.copyOfRange(values, NUM_NODES, (BINS+1)*NUM_NODES));
        long binMax = values[values.length-1];
        
        for(int j=0; j<latencyDist.length; j++)
            System.out.println(j+"\t"+latencyDist[j]);
        
        /*results.createHistogram(new Series[]{series}, series.m_name, BINS, (int) binMax, resultsDir, 
                "Histogram_"+series.m_name, "Distribution of Message Latencies ("+series.m_name+")", 
                "Message latency (ns)", "Count", -1, -1, -1, -1, false);*/
		
		System.out.println("Done.");
	}
	
	public static void test() {
		run(true);
	    System.out.println("\tCollecting data...");
        long[] values = Utilities.readBinFile("data.out");
	}
	
    public static void main(String[] args) {
    	experiment1();
    	//experiment2();    	
    	//test();
    }
}
