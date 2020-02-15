package com.spring.beans.processor;

import com.spring.beans.xml.HelloWorld;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;

public class MyBeanPostProcessor implements BeanPostProcessor {
    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("postProcessBeforeInitialization：" + bean + "," + beanName);
        if("helloWorld02".equals(beanName)){
            ((HelloWorld)bean).setWho("Spring");
        }
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("postProcessAfterInitialization：" + bean + "," + beanName);
        return bean;
    }
}
