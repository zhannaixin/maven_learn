package xml;

import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class XMLReader {

	/**
	 * @param args 
	 */
	@SuppressWarnings({ "rawtypes" })
	public static void main(String[] args) {
		String url = "s20proposer_lk_02.xml";
		Document doc = null;
		XMLReader reader = new XMLReader();
		SAXReader saxReader = new SAXReader();
		try {
			// int i = 1;
			ClassLoader loader = reader.getClass().getClassLoader();
			InputStream is = loader.getResourceAsStream(url);
			doc = saxReader.read(is);
			Element root = doc.getRootElement();// DSExport
			Iterator iterator = root.elementIterator();
			root = (Element) iterator.next();// Header
			root = (Element) iterator.next();// TableDefinitions

			iterator = root.elementIterator();
			while (iterator.hasNext()) {

				Element root2 = (Element) iterator.next();// Record
				Iterator iterator2 = root2.elementIterator();
				while (!"Collection".equals(root2.getName()))
					root2 = (Element) iterator2.next();

				for (Iterator it = root2.elementIterator(); it.hasNext();) {
					Element SubRecord = (Element) it.next();// SubRecord

					for (Iterator it1 = SubRecord.elementIterator(); it1
							.hasNext();) {
						Element sjx = (Element) it1.next();
						String name = sjx.attributeValue("Name");
						if (namesSet.contains(name)) {
							// System.out.print(i++ + ":\t");
//							System.out.print(sjx.attributeValue("Name") + ":");
							if ("SqlType".equalsIgnoreCase(name)) {
								System.out.print(decodeSqlType(sjx.getData().toString()) + "\t");
							} else if("Scale".equalsIgnoreCase(name) 
									&&"0".equals(sjx.getData().toString())){
								continue;
							}else{
								System.out.print(sjx.getData() + "\t");
							}
							
						}
						// break;
					}
					System.out.println();
				}

				System.out.println("\n\n\n\n\n\n\n");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static String decodeSqlType(String sqlType) {
		String ret = sqlTypeMap.get(sqlType);
		if (ret != null)
			return ret;

		return sqlType;
	}

	private static HashMap<String, String> sqlTypeMap = new HashMap<String, String>();
	private static HashSet<String> namesSet = new HashSet<String>(16);
//	private static HashSet<String> scaleSet = new HashSet<String>(16);
	static {
		sqlTypeMap.put("1", "char");
		sqlTypeMap.put("2", "Numeric");
		sqlTypeMap.put("3", "Decimal");
		sqlTypeMap.put("4", "Integer");
		sqlTypeMap.put("9", "Date");
		sqlTypeMap.put("12", "varchar");

		namesSet.add("Name");
		namesSet.add("SqlType");
		namesSet.add("Precision");
		namesSet.add("Scale");
		namesSet.add("Length");
	}

}
