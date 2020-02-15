package com.spring.aop.xml;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;

import java.util.Arrays;
import java.util.List;

public class LoggingAspect {
    public void beforeMethod(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        List<Object> args = Arrays.asList(joinPoint.getArgs());
        System.out.println("The method " + methodName + " begins with: " + args);
    }

    //即使方法发生异常也会被执行
    public void afterMethod(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println("The method " + methodName + " ends.");
    }

    public void afterReturning(JoinPoint joinPoint, Object result) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println("The method " + methodName + " ends with " + result);

    }

    //可以针对具体异常，其他异常不会执行
    public void afterThrowing(JoinPoint joinPoint, Exception ex) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println("The method " + methodName + " occurs exception " + ex);
    }

    public Object aroundMethod(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        Object result = null;
        String methodName = proceedingJoinPoint.getSignature().getName();
        try {
            System.out.println("The method " + methodName + " begins with: " + Arrays.asList(proceedingJoinPoint.getArgs()));
            result = proceedingJoinPoint.proceed();
            System.out.println("The method " + methodName + " ends with: " + result);
        } catch (Throwable t) {
            System.out.println("The method " + methodName + " occurs exception " + t);
            throw t;
        } finally {
            System.out.println("The method " + methodName + " ends.");
        }
        return result;
    }

}