package spring.main;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import spring.bean.HelloWorld;

/**
 * @author zhannaixin.zh
 * 
 */
public class RunBean {

	/** 建议一直使用ApplicationContext */
	private static ApplicationContext ctx;

	static {
		ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
	}

	/**
	 * @param args 输入参数，空的
	 */
	public static void main(String[] args) {
		runHello();

	}

	/**可以使用id，也可以使用类型获取对象，后一种要求类型唯一*/
	private static void runHello() {
		// ctx.getBean(HelloWorld.class)
		HelloWorld helloWorld = (HelloWorld) ctx.getBean("helloWorld1");
		helloWorld.say();
		System.out.println(helloWorld);

		helloWorld = (HelloWorld)ctx.getBean("helloWorld2");
		helloWorld.say();
		System.out.println(helloWorld);
	}

}
