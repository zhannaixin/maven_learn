package com.spring.aop;

import com.spring.aop.dynamicproxy.ArithmeticCalculatorLoggingProxy;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class SpringAopTest {

    ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");

    @Test
    public void testDynamicProxy(){
        ArithmeticCalculator arithmeticCalculator = ctx.getBean("arithmeticCalculatorLoggingProxy", ArithmeticCalculatorLoggingProxy.class).getArithmeticCalculatorLoggingProxy();
        System.out.println("---->" + arithmeticCalculator.add(1, 2));
        System.out.println("---->" + arithmeticCalculator.mul(1, 2));
        System.out.println("---->" + arithmeticCalculator.div(12, 10));
        System.out.println(arithmeticCalculator.getClass().getName());
    }

    @Test
    public void testAnnotition(){
        ArithmeticCalculator arithmeticCalculator = ctx.getBean("arithmeticCalculator", ArithmeticCalculator.class);
        System.out.println("---->" + arithmeticCalculator.add(1, 2));
        System.out.println("---->" + arithmeticCalculator.mul(1, 2));
        System.out.println("---->" + arithmeticCalculator.div(12, 10));
        System.out.println(arithmeticCalculator.getClass().getName());
    }

    @Test
    public void testXml(){
        ArithmeticCalculator arithmeticCalculator = ctx.getBean("arithmeticCalculatorXml", ArithmeticCalculator.class);
        System.out.println("---->" + arithmeticCalculator.add(1, 2));
        System.out.println("---->" + arithmeticCalculator.mul(1, 2));
        System.out.println("---->" + arithmeticCalculator.div(12, 10));
        System.out.println(arithmeticCalculator.getClass().getName());
    }
}
