package com.spring.aop.xml;

import org.aspectj.lang.JoinPoint;

import java.util.Arrays;

public class ValidationAspect {

    public void validateArgs(JoinPoint joinPoint){
        Object[] args = joinPoint.getArgs();
        System.out.println("validate:" + Arrays.asList(args));

    }
}
