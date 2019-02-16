package spring.bean;

/**
 * @author zhannaixin.zh
 * 
 */
public class HelloWorld {

	/** 打印信息 */
	private String msg;

	/**
	 * @param msg
	 *            the msg to set
	 */
	public void setMsg(String msg) {
		this.msg = msg;
	}

	/**
	 * 必须有无参构造方法，反射用
	 */
	public HelloWorld() {

	}
	
	public HelloWorld(String msg) {
		this.msg = msg;
	}

	/** 打印信息 */
	public void say() {
		System.out.println(msg);
	}

}
