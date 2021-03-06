// author: Catalin-Stefan Tiseanu

import java.io.*;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.util.WrappedIOException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

public class computeMetrics extends EvalFunc<Tuple> {
    TupleFactory mTupleFactory = TupleFactory.getInstance();
    static int NumberOfCheckstyleMetrics;
    static int NumberOfMetrics = 1;
    static boolean HasBeenInitialized = false;
  
    static int NumberOfFilesProcessed = 0;
    static String [] checkstyleMetrics;
    int [] countCheckstyleMetrics;
  
    public void initialize() throws Exception {
      try {
        // TODO: initialize code goes here
        NumberOfCheckstyleMetrics = 11;
        
        checkstyleMetrics = new String[NumberOfCheckstyleMetrics];
        countCheckstyleMetrics = new int[NumberOfCheckstyleMetrics];
        
        checkstyleMetrics[0] = "FileLength";
        checkstyleMetrics[1] = "RegexpSingleline";
        checkstyleMetrics[2] = "LineLength";
        checkstyleMetrics[3] = "MethodLength";
        checkstyleMetrics[4] = "TodoComment";
        checkstyleMetrics[5] = "BooleanExpressionComplexity";
        checkstyleMetrics[6] = "ClassDataAbstractionCoupling";
        checkstyleMetrics[7] = "ClassFanOutComplexity";
        checkstyleMetrics[8] = "CyclomaticComplexity";
        checkstyleMetrics[9] = "NPathComplexity";
        checkstyleMetrics[10] = "JavaNCSS";

        NumberOfMetrics += NumberOfCheckstyleMetrics;
      } catch (Exception e) {
        throw null;
      }
      HasBeenInitialized = true;
    }
  
    public Integer getNumberOfLines(String [] lines) throws Exception {
      try {
        return lines.length;
      } catch (Exception e) {
        return null;
      }
    }
  
    public Tuple runCheckstyle(String fileContent, Tuple outputSoFar)
      throws Exception {
        Tuple resultTuple = outputSoFar;

        for (int i = 0; i < countCheckstyleMetrics.length; i++)
            countCheckstyleMetrics[i] = 0;
 
        try {
          String tmpFileName = "_udf_tmp_" + NumberOfFilesProcessed + ".java";
       
          System.out.println("Write to file " + tmpFileName); 
          // we are going to write the lines to disk
          File tmpFile = new File(tmpFileName);
          FileWriter Fw = new FileWriter(tmpFile);
          Fw.write(fileContent);
          Fw.close();
       
          String udf_str;
          Process udf_proc = Runtime.getRuntime().exec("java -jar " +
          "lib/checkstyle-5.6-all.jar -c lib/pigbugs_checks.xml -f xml " +tmpFileName);
          
          BufferedReader udf_in =
          new BufferedReader(new InputStreamReader(udf_proc.getInputStream()));
          //DataInputStream udf_in = new DataInputStream();
          
          try {
            while ((udf_str = udf_in.readLine()) != null) {
              //System.out.println(udf_str);
              for (int i = 0; i < countCheckstyleMetrics.length; i++) {
                if (udf_str.contains(checkstyleMetrics[i])) {
                  countCheckstyleMetrics[i]++;
                  System.out.println("Found : " + checkstyleMetrics[i]);
                }
              }
              
            }
          } catch (IOException e) {
            System.exit(0);
          }
          
          tmpFile.delete();
        } catch (Exception e) {
          return null;
        }
        
        // range assigned to checkstyle: 1 .... NumberOfCheckstyleMetrics + 1
        
        for (int i = 0; i < NumberOfCheckstyleMetrics; ++i)
          resultTuple.set(i + 1, countCheckstyleMetrics[i]);
        
        return resultTuple;
    }

    public Tuple exec(Tuple input) throws IOException {
        if (!HasBeenInitialized) {
          try {
            initialize();
          } catch (Exception e) {
            return null;
          }
        }
    
        if (input == null || input.size() == 0)
          return null;
        try{
          NumberOfFilesProcessed = NumberOfFilesProcessed + 1;
        
          Tuple output = mTupleFactory.getInstance().newTuple(NumberOfMetrics);
        
          String str = (String)input.get(0);
          String [] lines = str.split("\n");
          
          output.set(0, getNumberOfLines(lines));
          output = runCheckstyle(str, output);
          
          return output;
        }catch(Exception e){
            //throw WrappedIOException.wrap("Caught exception processing input row " , e);
            System.out.println("Empty row found, continuing");
	    return null;
	}
    }
}
