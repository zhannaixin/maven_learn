package com.spring.aop.annotition;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Order(1)
@Aspect
@Component
public class ValidationAspect {

    @Before("LoggingAspect.declareJoinPointExpression()")
    public void validateArgs(JoinPoint joinPoint){
        Object[] args = joinPoint.getArgs();
        System.out.println("validate:" + Arrays.asList(args));

    }
}