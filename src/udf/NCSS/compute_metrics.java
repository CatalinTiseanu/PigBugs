
import java.io.DataInputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.xml.sax.InputSource;

import org.apache.pig.data.TupleFactory;

public class compute_metrics extends EvalFunc<Tuple> {
    
    public static TupleFactory mTupleFactory = TupleFactory.getInstance();
    public final static String[] VARIABLES = {"num_classes","num_functions","ncss","num_single_comment_lines","num_multi_comment_lines"};
    public final static String[] XPATHLOCATIONS = {
	"/javancss/packages[1]/total[1]/classes[1]",
	"/javancss/packages[1]/total[1]/functions[1]",
	"/javancss/packages[1]/total[1]/ncss[1]",
	"/javancss/packages[1]/total[1]/single_comment_lines[1]",
	"/javancss/packages[1]/total[1]/multi_comment_lines[1]"};
    public final static String tmp_file_name = "tmp.dat";
    
    public Tuple exec(Tuple input) throws IOException {
	if (input == null || input.size() == 0)
	    return null;
	try {
	    String str = (String) input.get(0);
	    return proc_jar(str);
	} catch (Exception e) {
	    throw new IOException("Caught exception processing input row ", e);
	         
	}
    }
    
    public Tuple proc_jar(String data)throws IOException{
	File tmp = new File(tmp_file_name);
	try{
	    save_file_to_disk(data,tmp);
	    Tuple result = parse_XML(execute_jar());
	    tmp.delete();
	    return result;
	}
	catch(Exception e){
	    try{tmp.delete();}
	    catch(Exception e2){return null;}
	    return null;}
    }
    
    public void save_file_to_disk(String data,File tmp)throws IOException{ 
	FileWriter Fw = new FileWriter(tmp);
	Fw.write(data);
	Fw.close();
    }
    
    public static String get_console(DataInputStream data){
	String udf_str;
	String all="";
        try {
	    while ((udf_str = data.readLine()) != null) {     
		all+=udf_str+"\n";
	    }
        } catch (IOException e) {
	    System.exit(0);
        }
	//        System.out.println(all);
	
        return all;
	
    }

    public String execute_jar() throws IOException{
	String tmp = "";
	Process udf_proc = Runtime.getRuntime().exec("java -cp jhbasic.jar:ccl.jar:javancss.jar javancss.Main -all -xml " +tmp_file_name);
	DataInputStream udf_in = new DataInputStream(udf_proc.getInputStream());
	tmp = get_console(udf_in);
	udf_in.close();
	udf_proc.destroy();
        return tmp;
    }
    
    public static Tuple parse_XML(String data) throws ParserConfigurationException, SAXException, IOException, XPathExpressionException   {

	Tuple result =mTupleFactory.getInstance().newTuple(XPATHLOCATIONS.length);
	try{
	    //loading the XML document from a file
	    DocumentBuilderFactory builderfactory = DocumentBuilderFactory.newInstance();
	    builderfactory.setNamespaceAware(true);
	     
	    DocumentBuilder builder = builderfactory.newDocumentBuilder();
	    Document xmlDocument = builder.parse(new InputSource(new StringReader(data)));;
	     
	    XPathFactory factory = javax.xml.xpath.XPathFactory.newInstance();
	    XPath xPath = factory.newXPath();
	     

	    for (int i =0;i<XPATHLOCATIONS.length;i++){
		XPathExpression xPathExpression = xPath.compile(XPATHLOCATIONS[i]);
		String metric = xPathExpression.evaluate(xmlDocument,XPathConstants.STRING).toString();
		result.set(i,metric);
		//System.out.println(VARIABLES[i] +"  " + metric);
		//System.out.println(result.get(i));
	    }
	}
	catch(Exception e){System.out.println(e);}
	return result;
    }
    
    
}