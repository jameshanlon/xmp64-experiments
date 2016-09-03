package wrapper;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Results {

	private List<Series> m_series;
	
	public Results(String resultsDir) {
		m_series = new ArrayList<Series>();
		Utilities.mkdir(resultsDir);
	}
	
	public Series newSeries(String name, int numSamples) {
		Series s = new Series(name, numSamples);
		m_series.add(s);
		return s;
	}
	
	public void createLatencyGraph(
            String directory, String title,  String xLabel, String yLabel, 
            int xMin, int xMax, int yMin, int yMax,  boolean errorBars) {

        String title_ = title.replace(' ', '-');
        String outFilename = directory+"/"+title_+".ps";

        //for(Series s : m_series)
        //    s.writeData(directory, title_);

        String cfg =
        "set terminal postscript eps enhanced color \"Helvetica\" 12\n"+
        "set output \""+outFilename+"\"\n"+
        "set size 0.5,0.5\n"+
        "set key left top\n"+ 
        "set logscale xy\n"+
        "set xlabel \""+xLabel+"\"\n"+
        "set ylabel \""+yLabel+"\"\n";
        if(xMin != -1 && xMax != -1)
            cfg += "set xrange ["+xMin+":"+xMax+"]\n";
        if(yMin != -1 && yMax != -1)
            cfg += "set yrange ["+yMin+":"+yMax+"]\n";
        cfg += "plot \\n";

        int i=0;
        for(Series s : m_series) { 
            cfg += "\t\""+s.filename()+"\" title \""+s.name()+"\" "+
            (errorBars ? "with yerrorlines" : "with linespoints");
            cfg += ++i!=m_series.size() ? ",\\\n" : "\\\n";
        }

        String inputFile = directory+"/config_"+title_+".gp";
        Utilities.writeFile(inputFile, cfg);

        Utilities.exec("gnuplot "+inputFile, ".", true);
        //Utilities.exec("rm "+directory+"/"+inputFile);
        //for(ResultData rd : m_results)
        //  Utilities.exec("rm "+directory+"/"+rd.name());
        System.out.println("Created graph "+title+" ("+outFilename+")");
    }
	
	public void createHistogram(
            Series[] series, String id, int bins, int binMax, String directory, 
            String filename, String title, String xLabel, String yLabel,
            int xMin, int xMax, int yMin, int yMax, boolean errorBars) {
		
		int step = binMax/bins;
		String dataFile = directory+"/histData_"+id+".dat";
		String outFile = directory+"/"+filename+".ps";
		String cfgFile = directory+"/config_"+id+".gp";
		
		writeHistData(dataFile, bins, 0, binMax, series);
		
		String cfg = 
			"set terminal postscript eps enhanced color \"Helvetica\" 12\n"+
			"set output \""+outFile+"\"\n"+
			"set boxwidth 0.75 absolute\n"+
			"set style data histograms\n"+
			"set style histogram cluster gap 1\n"+
			"set style fill solid border -1\n"+
			//"set logscale y\n"+
	        "set xlabel \""+xLabel+"\"\n"+
	        "set ylabel \""+yLabel+"\"\n"+
	        //"set xtic rotate by -90 scale 0\n"+
	        "set xtics (";
		// Add in 10 ticks
		for(int i=0; i<bins; i+=10)
			cfg += "\""+(i*step)+"\" "+i+(i+10!=bins ? ", " : "");
		cfg += ")\n"+
		 	"plot \\\n";

	    for(int i=0; i<series.length; i++) {
	    	cfg += (i==0 ? "'"+dataFile+"'" : "''")+" using "+(i+1)+(i+1==series.length ? "" : "")+
	    		" t \""+series[i].m_name+"\" "+(i+1 != series.length ? ",\\\n" : "");
	    }
		
		Utilities.writeFile(cfgFile, cfg);
        Utilities.exec("gnuplot "+cfgFile, ".", true);
        
        System.out.println("Created graph "+title+" ("+outFile+")");
	}

	/*
	 * Write each series as a column, with the first column containing String ranges
	 */
	private void writeHistData(String filename, int bins, long min, long max, 
            Series[] series) {

		try {
            BufferedWriter out = new BufferedWriter(new FileWriter(filename));
            
            for(int j=0; j<bins; j++) {
            	
            	for(int i=0; i<series.length; i++) {
            		
            		//System.out.print(series[i].sample(j)+(i+1!=series.length ? "\t" : "\n"));
            		out.write(series[i].sample(j)+(i+1!=series.length ? "\t" : "\n"));	
            	}
            }
            
            out.close();
        } catch (IOException e) {
            System.err.println("Error: writing data file: "+filename);
            e.printStackTrace();
        }
	}	
}
