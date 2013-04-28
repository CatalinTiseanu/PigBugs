
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

public class computeAggregate extends EvalFunc<Tuple> {
  TupleFactory mTupleFactory = TupleFactory.getInstance();
  
  static int NumberOfMetrics = 0;
  static boolean HasBeenInitialized = false;
  static int NumberOfTuplesProcessed = 0;
  
  public Tuple exec(Tuple input) throws IOException {
    if (input == null || input.size() == 0)
      return null;
    try{
      Tuple result = mTupleFactory.getInstance().newTuple(0);
      DataBag bag = (DataBag) input.get(0);
      
      Iterator it = bag.iterator();
      
      while (it.hasNext()) {
        Tuple t = (Tuple)it.next();
        Tuple inside_t = (Tuple)t.get(0);
        
        if (!HasBeenInitialized) {
          NumberOfMetrics = inside_t.size();
          result = mTupleFactory.getInstance().newTuple(NumberOfMetrics);
          for (int i = 0; i < NumberOfMetrics; ++i)
            result.set(i, 0);
          HasBeenInitialized = true;
        } else if (NumberOfMetrics != inside_t.size()) {
          System.out.println("Got " + inside_t.size() + " tuples, expected " +
                             NumberOfMetrics);
        }
        
        for (int i = 0; i < inside_t.size(); ++i) {
          result.set(i, Integer.parseInt(""+result.get(i)) +
                        Integer.parseInt(""+inside_t.get(i)));
        }
        
        NumberOfTuplesProcessed++;
      }
    
      return result;
    }catch(Exception e){
      throw WrappedIOException.wrap("Caught exception processing input row " , e);
    }
  }
}
