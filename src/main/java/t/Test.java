package t;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * @author zhannaixin.zh
 * 
 */
public class Test {

	/**
	 * @param args
	 * @throws InterruptedException
	 */
	public static void main(String[] args) throws Exception {

		System.out.println(new BigDecimal("").divide(new BigDecimal("")));
	}

	public static void testArrayFill() {
		char[] space = new char[55];
		Arrays.fill(space, '_');
//		space[28] = '3';
//		System.out.println(String.valueOf(space));
//		space[28] = '_';
//		space[0] = '0';
//		space[1] = '0';
//		Arrays.fill(space, 7, 11, ' ');
//		Arrays.fill(space, 11, 15, '9');
//		System.out.println(String.valueOf(space));
		char[] fill = "1234".toCharArray();
		System.arraycopy(fill, 0, space, 50, 4);
		System.out.println(String.valueOf(space));
		System.out.println(String.format("%+05.2f", -111.23f));
	}

	public static void testDate() {
		Date date = new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("HHmmss");
		System.out.println(sdf.format(date));
	}

	public static void testSeparator() {
		String src = "123|456|789";
		String separator = "|";
		String[] arr = src.split(separator);

		for (int i = 0, l = arr.length; i < l;) {
			System.out.println(arr[i++]);
		}
	}

	public static void testRemove() {
		ArrayList<Integer> al = new ArrayList<Integer>(16);
		al.add(1);
		al.add(2);
		al.add(2);
		al.add(2);
		al.add(2);

		while (al.size() > 0) {
			System.out.println(al.remove(0));
		}
	}

	public static void testFormat2() {
		System.out
				.println(String
						.format(" 合计拒绝批数:    %1$09d  合计拒绝笔数:    %2$09d  合计拒绝金额:    %3$013.2f                                                   ",
								2, 2, 2.0));
		System.out
				.println(String
						.format("                             合计借记笔数:    %1$09d  合计借记金额:    %2$013.2f                                                   ",
								2, 2.0));
		System.out
				.println("                              ****报表结束****                              ");

		System.out
				.println(String
						.format(" 0PGM:       GCP75B08                            中国建设银行信用卡                    日期:       %1$8s  页码: %2$3d",
								2, 2));
		System.out
				.println("  顺序号  交易日期   交易代码  币种  批头总笔数  批头总金额      明细总笔数  明细总金额        入账情况");
		System.out
				.println(" ------- ---------  ---------  ----- ----------- -----------    -----------  -----------    ----------------       ");

		System.out.println(String
				.format("%s %10.5f %s", "02", 15.05, "公司卡约定购汇"));
	}

	public static void testTree() {
		ArrayList<TObject> t = new ArrayList<TObject>();
		t.add(new TObject(99, "TOM"));
		t.add(new TObject(1, "Tom"));
		t.add(new TObject(99, "KATE"));
		t.add(new TObject(8, "JIMM"));
		t.add(new TObject(99, "TIM"));
		t.add(new TObject(99, "TIM"));

		TObject[] arr = {};
		arr = t.toArray(arr);
		Arrays.sort(arr);

		for (int i = 0, l = arr.length; i < l; i++) {
			System.out.println(arr[i]);
		}
	}

	public static void testUnicode() throws UnsupportedEncodingException {
		String strUnicode = "中国123";
		for (int i = 0, l = strUnicode.length(); i < l; i++) {
			System.out.print(Integer.toHexString(strUnicode.charAt(i)));
		}
		System.out.println();

		String strGBK = new String(strUnicode.getBytes(), "utf-8");
		for (int i = 0, l = strGBK.length(); i < l; i++) {
			System.out.print(Integer.toHexString(strGBK.charAt(i)));
		}
		System.out.println();
		System.out.println(strGBK);
		System.out.println((char) 20013);
	}

	/**
	 * 
	 */
	public static void testFormat() {
		System.out.printf("%1$H\n", "中国");
		System.out.println("中国".hashCode());
		Calendar c = Calendar.getInstance();
		System.out.printf(Locale.getDefault(), "%1$tm %1$td %1$tY\n", c);
		System.out.printf(Locale.ENGLISH, "%1$tm %1$td %1$tY\n", c);
		System.out.println(Locale.CHINA);
		System.out.println(Integer.toHexString("中国".charAt(0)));
		System.out.printf("%013.2f\n", 9.99);
		System.out.printf("%1$-6s\n", "中");
	}

	/**
	 * 
	 */
	public static void testBigdecimal() {
		BigDecimal bd1 = BigDecimal.valueOf(4);
		BigDecimal bd2 = BigDecimal.valueOf(4.0000000000);
		System.out.println(bd1.scale());
		System.out.println(bd2.scale());
		System.out.println(bd1.equals(bd2));
		System.out.println(bd1.compareTo(bd2));
		System.out.println(bd1.toString());
		System.out.println(bd2.toString());
		// System.out.println(bd1.compareTo(null));
	}

	/**
	 * 
	 */
	public static void testmatch() {
		String s = "006200*                            THIS IS THE INTERNAL TC CODE FOR THE";
		System.out.println(s.matches("^\\d{6}\\*.*"));
	}

	/**
	 * 
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public static void testCollection() {
		HashMap hm = new HashMap();
		hm.put("1", "One");
		hm.put("one", "One");
		Collection c = hm.values();
		c.remove("One");
		System.out.println(hm.values());
		System.out.println(hm.keySet());

		Key k = new Key(10);
		hm = new HashMap();
		hm.put(k, 10);
		k.setKey(5);
		System.out.println(hm.get(new Key(10)));
		System.out.println(hm.get(new Key(5)));
		System.out.println(hm.get(k));
		System.out.println(hm.values());
		System.out.println(hm.keySet());

		Set s = hm.keySet();
		Iterator i = s.iterator();
		while (i.hasNext()) {
			System.out.println(hm.get(i.next()));
		}
	}

	/**
	 * @author zhannaixin.zh
	 * 
	 */
	static class Key {
		int key;

		public Key(int k) {
			key = k;
		}

		public void setKey(int k) {
			key = k;
		}

		public int hashCode() {
			return key % 10;
		}

		public boolean equals(Object o) {
			return hashCode() == o.hashCode();
		}

		public String toString() {
			return String.valueOf(key);
		}
	}

	public static void testString() {
		String tableName = "S21T2_ROOT_NODE_PDARAC_STAT", tableNameDelete = null;

		tableNameDelete = tableName.replaceAll("T1", "TD");
		tableNameDelete = tableNameDelete.replaceAll("T0", "TD");
		tableNameDelete = tableNameDelete.replaceAll("T2", "TD");
		System.out.println(tableNameDelete);

		tableNameDelete = tableName.replaceAll("T1", "TD")
				.replaceAll("T0", "TD").replaceAll("T2", "TD");
		System.out.println(tableNameDelete);
	}

	/**
	 * 
	 */
	public static void testRE() {
		System.out.println("c1222223344.12345.txt8/\\".matches(".+"));

		String pattern = "((^((1[8-9]\\d{2})|([2-9]\\d{3}))([-\\/\\._])"
				+ "(10|12|0?[13578])([-\\/\\._])(3[01]|[12][0-9]|" +

				"0?[1-9]))|(^((1[8-9]\\d{2})|([2-9]\\d{3}))([-\\/\\._])"
				+ "(11|0?[469])([-\\/\\._])(30|[12][0-9]|0?[1-9]))|" +

				"(^((1[8-9]\\d{2})|([2-9]\\d{3}))([-\\/\\._])"
				+ "(0?2)([-\\/\\._])(2[0-8]|1[0-9]|0?[1-9]))|" +

				"(^([2468][048]00)([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([3579][26]00)([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([1][89][0][48])([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([2-9][0-9][0][48])([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([1][89][2468][048])([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([2-9][0-9][2468][048])([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([1][89][13579][26])([-\\/\\._])(0?2)([-\\/\\._])(29))|" +

				"(^([2-9][0-9][13579][26])([-\\/\\._])(0?2)([-\\/\\._])(29) ))$";
		// System.out.println(pattern);

		Calendar c = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		for (int i = 0; i < 1; i++) {
			c.set(Calendar.MONTH, c.get(Calendar.MONTH) + i);
			c.set(Calendar.DAY_OF_MONTH, c.get(Calendar.DAY_OF_MONTH) + i * i);
			System.out.println(sdf.format(c.getTime()) + ":"
					+ sdf.format(c.getTime()).matches(pattern));
		}

		System.out.println("2000-02-29:" + "2000-02-31".matches(pattern));

		System.out.println("621010006210100062101000999 :"
				+ "621010006210100062101000999 ".matches(ACCT_NO_PATTERN));
		System.out.println("Jim 英格兰:" + "Jim 英格兰".matches(NAME_PATTERN));
		System.out.println("100.27:" + "100.38".matches(TRANS_AMOUNT_PATTERN));
		System.out.println("10027:" + "10038".matches("\\d{6}"));
		System.out.println("A067320140730174944418108:"
				+ "A067320140730174944418108".matches(TRANS_LOG_ID_PATTERN));

	}

	public static void testEncoding() throws InterruptedException {
		char[] ac = { 0xdbef, 0xdcef, '中', '国' };
		String us = new String(ac);// "\uddaa\udcee\uEfdd中国";
		for (int ii = 0, l = us.length(); ii < l; ii++) {
			System.out.println(us.codePointAt(ii) + "\t" + us.charAt(ii) + "\t"
					+ Character.isHighSurrogate(us.charAt(ii)) + "\t"
					+ Character.isLowSurrogate(us.charAt(ii)));
		}
		System.out.println(us);
		System.out.println(us.codePointCount(0, us.length()));
		System.out.println(us.length());
		System.out.println(new String(Character.toChars(0x123ff)));
		System.out.println(Character.isDefined(0x123ff));
		System.out.println(Character.toTitleCase(97));
		System.out.println(Character.digit(7, 8));
		System.out.println(Arrays.deepToString("1,2,3,4,5,6".split(",", 3)));
		System.out.println(-1.0 / 0);
		System.out.println(0.0 / 0);
		Runnable r = new Runnable() {

			@Override
			public void run() {
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssS");
				Date date = new Date(System.currentTimeMillis());
				String tms = sdf.format(date);
				System.out.println(tms);
			}
		};
		for (int i = 0, l = 10; i < l; i++) {
			Thread t = new Thread(r);
			Thread.sleep((int) (new Random().nextFloat() * 1000));
			t.start();

		}
	}

	public static void testMap() {
		HashMap<String, Object> hmap = new HashMap<String, Object>();
		hmap.put("1", 1);
		hmap.put("2", "two");
		hmap.put("3", "ccb");

		Iterator<String> iterator = hmap.keySet().iterator();
		while (iterator.hasNext()) {
			String key = iterator.next();
			if (key.equals("3"))
				iterator.remove();
		}
		Set<Map.Entry<String, Object>> s = hmap.entrySet();
		Iterator<Map.Entry<String, Object>> i = s.iterator();
		while (i.hasNext()) {
			Map.Entry<String, Object> e = i.next();
			if ("3".equals(e.getKey()))
				i.remove();
			// System.out.println(e.getKey() + ":" + e.getValue());
		}
		i = s.iterator();
		while (i.hasNext()) {
			Map.Entry<String, Object> e = i.next();
			System.out.println(e.getKey() + ":" + e.getValue());
		}
	}

	/*
	 * /((^((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(10|12|0?[13578])([-\/\._])(3[01
	 * ]
	 * |[12][0-9]|0?[1-9]))|(^((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(11|0?[469])
	 * (
	 * [-\/\._])(30|[12][0-9]|0?[1-9]))|(^((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])
	 * (
	 * 0?2)([-\/\._])(2[0-8]|1[0-9]|0?[1-9]))|(^([2468][048]00)([-\/\._])(0?2)([
	 * -
	 * \/\._])(29))|(^([3579][26]00)([-\/\._])(0?2)([-\/\._])(29))|(^([1][89][0]
	 * [
	 * 48])([-\/\._])(0?2)([-\/\._])(29))|(^([2-9][0-9][0][48])([-\/\._])(0?2)([
	 * -
	 * \/\._])(29))|(^([1][89][2468][048])([-\/\._])(0?2)([-\/\._])(29))|(^([2-9
	 * ]
	 * [0-9][2468][048])([-\/\._])(0?2)([-\/\._])(29))|(^([1][89][13579][26])([-
	 * \
	 * /\._])(0?2)([-\/\._])(29))|(^([2-9][0-9][13579][26])([-\/\._])(0?2)([-\/\
	 * ._])(29) ))\s((20|21|22|23|[0-1]?\d):[0-5]?\d:[0-5]?\d)$/;
	 */
	private final static String TRANS_LOG_ID_PATTERN = new StringBuffer(1024)
			.append("^(A0673)")
			.append("((((1[8-9]\\d{2})|([2-9]\\d{3}))(10|12|0[13578])(3[01]|[12][0-9]|0[1-9]))|")
			.append("(((1[8-9]\\d{2})|([2-9]\\d{3}))(11|0[469])(30|[12][0-9]|0[1-9]))|")
			.append("(((1[8-9]\\d{2})|([2-9]\\d{3}))(02)(2[0-8]|1[0-9]|0[1-9]))|")
			.append("(([2468][048]00)(02)(29))|")
			.append("(([3579][26]00)(02)(29))|")
			.append("(([1][89][0][48])(02)(29))|")
			.append("(([2-9][0-9][0][48])(02)(29))|")
			.append("(([1][89][2468][048])(02)(29))|")
			.append("(([2-9][0-9][2468][048])(02)(29))|")
			.append("(([1][89][13579][26])(02)(29))|")
			.append("(([2-9][0-9][13579][26])(02)(29)))")
			.append("((20|21|22|23|[0-1]\\d)[0-5]\\d[0-5]\\d)")
			.append("(\\d{6})$").toString();

	/**
	 * 匹配交易账号的正则表达式
	 */
	private final static String ACCT_NO_PATTERN = "^[\\w|\\d]{28}$";

	/**
	 * 匹配交易账户名称的正则表达式
	 */
	private final static String NAME_PATTERN = "^[\\w|\\s|[\\u4e00-\\u9fa5]]{1,100}$";

	/**
	 * 匹配交易金额的正则表达式
	 */
	private final static String TRANS_AMOUNT_PATTERN = "^\\d{1,18}\\.\\d{2}$";

	static class TObject implements Comparable<TObject> {

		int size;

		String name;

		Long dis;

		public TObject(int size, String name) {
			this.size = size;
			this.name = name;
			dis = new Random(System.currentTimeMillis()).nextLong();
		}

		/*
		 * (non-Javadoc)
		 * 
		 * @see java.lang.Comparable#compareTo(java.lang.Object)
		 */
		@Override
		public int compareTo(TObject o) {
			int ret = size - o.size;
			return ret;
		}

		public String toString() {
			return String.valueOf(size) + ":" + name;
		}
	}

}