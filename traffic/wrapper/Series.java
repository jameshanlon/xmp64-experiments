package wrapper;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class Series {
	
	String  m_name;
	String  m_filename;
	int[]   m_x;
	long[]  m_y;
	
	public Series(String name, int numSamples) {
		m_name = name;
		m_x = new int[numSamples];
		m_y = new long[numSamples];
		//System.out.println("New Series");
	}
	
	public void addSample(int sample, int x, long y) {
		m_x[sample] = x;
		m_y[sample] = y;
		//System.out.println(m_y[sample]);
	}
	
	public void writeData(String directory) {
        
		m_filename = directory+"/"+m_name+".dat";
        
        try {
            BufferedWriter out = new BufferedWriter(new FileWriter(m_filename));
            
            for(int i=0; i<m_x.length; i++) {
                out.write(m_x[i]+"\t"+m_y[i]+"\n");
            }
            
            out.close();
        } catch (IOException e) {
            System.err.println("Error: writing data file: "+m_filename);
            e.printStackTrace();
        } 
    }
	
	public int[] calcFrequencies(int bins, long min, long max) {
		
		int[] frequencies = new int[bins];
		long step = (max - min) / bins;
		
		for(int i=0; i<bins; i++) {
			long start = min + i * step;
			frequencies[i] = count(start, start+step);
		}
	
		/*System.out.println("Frequencies for "+m_name+":");
		for(int i=0; i<frequencies.length; i++)
			System.out.println(frequencies[i]);*/
		
		return frequencies;
	}
	
	private int count(long start, long end) {
		int count = 0;
		for(int i=0; i<m_y.length; i++) {
			if(m_y[i] >= start && m_y[i] < end)
				count++;
		}
		return count;
	}

	public long getMinValue() {
		long min = Long.MAX_VALUE;
		for(int i=0; i<m_y.length; i++) {
			if(m_y[i] < min)
				min = m_y[i];
		}
		return min;
	}

	public long getMaxValue() {
		long max = 0;
		for(int i=0; i<m_y.length; i++) {
			if(m_y[i] > max)
				max = m_y[i];
		}
		return max;
	}
	
	public String name()           { return m_name; }
    public String filename()       { return m_filename; }
	public long sample(int sample) { return m_y[sample]; }
}
