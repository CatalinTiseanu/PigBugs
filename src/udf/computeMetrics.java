
import java.io.IOException;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.util.WrappedIOException;

public class computeMetrics extends EvalFunc<Tuple> {
    TupleFactory mTupleFactory = TupleFactory.getInstance();
    static final int numberOfMetrics = 2;
  
    public Integer getNumberOfLines(String [] lines) throws IOException {
      try {
        return lines.length;
      } catch (Exception e) {
        throw null;
      }
    }

    public Tuple exec(Tuple input) throws IOException {
        if (input == null || input.size() == 0)
          return null;
        try{
          Tuple output = mTupleFactory.getInstance().newTuple(numberOfMetrics);
        
          String str = (String)input.get(0);
          String [] lines = str.split("\n");
          
          output.set(0, getNumberOfLines(lines));
          output.set(1, -1);
          
          return output;
        }catch(Exception e){
            throw WrappedIOException.wrap("Caught exception processing input row ", e);
        }
    }
}
