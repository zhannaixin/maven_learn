package com.spring.aop.dynamicproxy;


import com.spring.aop.ArithmeticCalculator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.Arrays;

/**
 * 使用动态代理实现日志输出
 */
@Component
public class ArithmeticCalculatorLoggingProxy {

    @Autowired
    ArithmeticCalculator arithmeticCalculator;

    public ArithmeticCalculatorLoggingProxy(){}

    public ArithmeticCalculatorLoggingProxy(ArithmeticCalculator arithmeticCalculator){
        this.arithmeticCalculator = arithmeticCalculator;
    }

    public ArithmeticCalculator getArithmeticCalculatorLoggingProxy(){

        ClassLoader cl = arithmeticCalculator.getClass().getClassLoader();
        Class<Object>[] interfaces = new Class[]{ArithmeticCalculator.class};
        InvocationHandler handler = (proxy, method, args) -> {
            System.out.println("DynamicProxy: The method " + method.getName() + " starts with: " + Arrays.asList(args));
            Object o = method.invoke(arithmeticCalculator, args);
            System.out.println("DynamicProxy: The method " + method.getName() + " ends with " + o);
            return o;
        };

        return (ArithmeticCalculator) Proxy.newProxyInstance(cl, interfaces, handler);
    }
}