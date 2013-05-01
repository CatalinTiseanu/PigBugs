//package metrics;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

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
	public final static String result_file_name ="result.dat"; 
	
	public Tuple exec(Tuple input) throws IOException {
		if (input == null || input.size() == 0)
			return null;
		try {
			String str = (String) input.get(0);					
			return proc_jar(str);
		} catch (Exception e) {
			throw new IOException("Caught exception processing input row ", e);
			return null;
		}
	}
	
	public Tuple proc_jar(String data){
		File tmp = new File(tmp_file_name);
		save_file_to_disk(data,tmp);
		execute_jar();
		Tuple result = parse_XML();
		tmp.delete();
		return result;
	}
	
	public void save_file_to_disk(String data,File tmp){		 
         FileWriter Fw = new FileWriter(tmp);
         Fw.write(data);
         Fw.close();		
	}

	public void execute_jar(){
		Process udf_proc = Runtime.getRuntime().exec("java -jar " +
		          "-all -out "+result_file_name+ "-xml "+tmp_file_name);
	}
	
	public static Tuple parse_XML() throws ParserConfigurationException, SAXException, IOException, XPathExpressionException   {

		//loading the XML document from a file
		DocumentBuilderFactory builderfactory = DocumentBuilderFactory.newInstance();
		builderfactory.setNamespaceAware(true);
		 
		DocumentBuilder builder = builderfactory.newDocumentBuilder();
		Document xmlDocument = builder.parse(new File(result_file_name));
		 
		XPathFactory factory = javax.xml.xpath.XPathFactory.newInstance();
		XPath xPath = factory.newXPath();
		 
		Tuple result = mTupleFactory.getInstance().newTuple(XPATHLOCATIONS.length);;
		for (int i =0;i<XPATHLOCATIONS.length;i++){
			XPathExpression xPathExpression = xPath.compile(XPATHLOCATIONS[i]);
			String metric = xPathExpression.evaluate(xmlDocument,XPathConstants.STRING).toString();
			result.set(i+1,metric);
			System.out.println(VARIABLES[i] +"  " + metric);
		}
		return result;
		}
	
}