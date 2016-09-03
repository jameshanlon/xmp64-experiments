package wrapper;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class Utilities {

	public static double log2(double value) { return Math.log10(value) / Math.log10(2); }

	public static int mod(int x, int y) {
		return x % y < 0 ? y + (x % y) : x % y;
	}
	
	public static boolean mkdir(String directory) {
        if(!(new File(directory)).exists())
            return (new File(directory)).mkdir();
        return true;
    }

    public static int exec(String cmd, String workingDir, boolean printOuput) {
        try {
            Process child = Runtime.getRuntime().exec(cmd, null, new File(workingDir));
            int exit = child.waitFor();
            
            if(exit > 0) {
            	System.err.println("Error: executing process, exit: "+exit+", command: "+cmd);
            }

            if(printOuput) {
            
            	//StdOut
            	System.out.print("\033[1;32m");
	            InputStream in = child.getInputStream();
	            int c;
	            while ((c = in.read()) != -1)
	                System.out.print((char)c);
	            in.close();
	            
	            // StdErr
	            System.out.print("\033[31m");
	            in = child.getErrorStream();
	            while ((c = in.read()) != -1)
	                System.out.print((char)c);
	            in.close();
	            
	            System.out.print("\033[0m");
            }
            
            return exit;
            
        } catch (IOException e) {
            System.err.println("Error: could execute command: "+cmd);
            e.printStackTrace();
        } catch (InterruptedException e) {
            System.err.println("Error: command interrupted: "+cmd);
            e.printStackTrace();
        }
        
        return -1;
    }

    public static void writeFile(String filename, String contents) {
       try {
            BufferedWriter out = new BufferedWriter(new FileWriter(filename));
            out.write(contents);
            out.close();
        } catch (IOException e) {
            System.err.println("Error: writing file "+filename);
        }
    }
    
    /*
	 * Convert a binary file of unsigned integers to an array of longs
	 */
	public static long[] readBinFile(String srcFile) {

		List<Long> data = new ArrayList<Long>();
		byte[] unsigned = new byte[4];
		
		try {
			DataInputStream in = new DataInputStream(
					new BufferedInputStream(new FileInputStream(srcFile)));
			
			while(in.available() != 0) {
				in.read(unsigned);
				
				long value = (long)unsigned[0] & 0xFF;
				value += ((long)unsigned[1] & 0xFF) << 8;
				value += ((long)unsigned[2] & 0xFF) << 16;
				value += ((long)unsigned[3] & 0xFF) << 24;
				
				data.add(value);

			}			
			in.close();
		} catch (IOException e) {
			System.err.println("Error: reading file");
			e.printStackTrace();
		}
		
		Long[] tmp = data.toArray(new Long[data.size()]);
		long[] values = new long[tmp.length];
		for(int i=0; i<tmp.length; i++)
			values[i] = tmp[i].longValue();
		
		System.out.println("Read file "+srcFile);
		return values;
	}

	public static long average(long[] values) {
		long total = 0;
		for(Long v : values)
			total += v;
		return total / values.length;
	}

	public static String binStr(int node, int numDimensions) {
		String s = Integer.toBinaryString(node);
		for(int i=s.length(); i<numDimensions; i++) {
			s = "0"+s;
		}
		return s;
	}
}
