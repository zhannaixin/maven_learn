package com.spring.beans;

import com.spring.beans.Controller;
import com.spring.beans.xml.HelloWorld;
import com.spring.beans.xml.LookUpBean;
import com.spring.entity.Car;
import com.spring.entity.DataSourceConfig;
import com.spring.entity.Persion;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class SpringBeansTest {

    ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");

    @Test
    public void testHelloWorldSay() {
        HelloWorld hw = ctx.getBean("helloWorld01", HelloWorld.class);
        hw.say();
        hw = ctx.getBean("helloWorld02", HelloWorld.class);
        hw.say();
    }

    @Test
    public void testLookUpBean() throws InterruptedException {
        LookUpBean lookUpBean = ctx.getBean("lookUpBean", LookUpBean.class);
        System.out.println(lookUpBean.getCurrentTime());
        System.out.println(lookUpBean.createCurrentTime());

        Thread.sleep(2000);

        System.out.println(lookUpBean.getCurrentTime());
        System.out.println(lookUpBean.createCurrentTime());
    }

    @Test
    public void testReadPropertiesFile() {
        DataSourceConfig dataSourceConfig = ctx.getBean("dataSource01", DataSourceConfig.class);
        System.out.println(dataSourceConfig);

        dataSourceConfig = ctx.getBean("dataSource02", DataSourceConfig.class);
        System.out.println(dataSourceConfig);
    }

    @Test
    public void testCar() {
        Car car = ctx.getBean("car01", Car.class);
        System.out.println(car);

        car = ctx.getBean("car02", Car.class);
        System.out.println(car);

        car = ctx.getBean("car03", Car.class);
        System.out.println(car);

    }

    @Test
    public void testFactory() {
        Car car = ctx.getBean("car04", Car.class);
        System.out.println(car);

        car = ctx.getBean("car05", Car.class);
        System.out.println(car);

        car = ctx.getBean("car06", Car.class);
        System.out.println(car);

    }

    @Test
    public void testPersion() {
        Persion persion = ctx.getBean("persion01", Persion.class);
        System.out.println(persion);

        persion = ctx.getBean("persion02", Persion.class);
        System.out.println(persion);

        persion = ctx.getBean("persion03", Persion.class);
        System.out.println(persion);

        persion = ctx.getBean("persion04", Persion.class);
        System.out.println(persion);

    }


    @Test
    public void testAnnotion(){
        Controller controller = ctx.getBean("controller", Controller.class);
        System.out.println(controller);
        controller.execute();
    }
}
