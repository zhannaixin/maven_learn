package xml;

import java.io.InputStream;
import java.util.Iterator;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class CTMXMLReader {

	@SuppressWarnings({ "rawtypes" })
	public static void main(String[] args) {
		String url = "Draft1.xml";
		Document doc = null;
		XMLReader reader = new XMLReader();
		SAXReader saxReader = new SAXReader();
		try {
			// int i = 1;
			ClassLoader loader = reader.getClass().getClassLoader();
			InputStream is = loader.getResourceAsStream(url);
			doc = saxReader.read(is);
			Element root = doc.getRootElement();// DEFTABLE
			
			Iterator iterator = root.elementIterator();
			while (iterator.hasNext()) {
				Element e = (Element) iterator.next();// Record
				printJob(e, "");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	
	public static void printJob(Element e, String prefix){
		String jobName = null;
		String cmdLine = null;
		String nodeId = null;
		String applicaation = null;
		if(e.getName().equals("SMART_TABLE")
				|| e.getName().equals("SUB_TABLE")){
			Iterator<?> iterator = e.elementIterator();
			String tmpStr = e.attributeValue("JOBNAME");
			String subPrefix = "".equals(prefix) ? 
					tmpStr : (prefix + "/" + tmpStr);
			while(iterator.hasNext()){
				printJob((Element)iterator.next(), subPrefix);
			}
		}else if(e.getName().equals("JOB")){
			jobName = /*prefix + "/" + */e.attributeValue("JOBNAME");
			cmdLine = e.attributeValue("CMDLINE");
			nodeId = e.attributeValue("NODEID");
			applicaation = e.attributeValue("APPLICATION");
			if(cmdLine == null){
				cmdLine = "";
			}else{
				cmdLine = cmdLine.replaceAll("/bin/sh ", "");
				if(cmdLine.indexOf("Monitor")>0){
					int start = cmdLine.indexOf(" ");
					start = (start<0) ? 0 : start+1;
					cmdLine = cmdLine.substring(start);
				}
			}
			nodeId = nodeId.replaceAll("[\\n|\\r]", "");
			cmdLine = cmdLine.replaceAll("[\\n|\\r]", "").trim();
			System.out.println(applicaation + "\t" + jobName + "\t" + nodeId + "\t" + cmdLine);
			System.out.println(applicaation + "\t" + jobName);
		}
		
	}

}
