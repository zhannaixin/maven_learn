package com.spring.aop.annotition;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
@Aspect
public class LoggingAspect {

    @Pointcut("execution(* com.spring.aop.annotition.ArithmeticCalculatorImpl.*(..))")
    public void declareJoinPointExpression() {}

    @Before("declareJoinPointExpression()")
    public void beforeMethod(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        List<Object> args = Arrays.asList(joinPoint.getArgs());
        System.out.println("BeforeMethod: The method " + methodName + " begins with: " + args);
    }

    //即使方法发生异常也会被执行
    @After("declareJoinPointExpression()")
    public void afterMethod(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println("AfterMethod: The method " + methodName + " ends.");
    }

    @AfterReturning(value = "declareJoinPointExpression()", returning = "result")
    public void afterReturning(JoinPoint joinPoint, Object result) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println("AfterReturning: The method " + methodName + " ends with " + result);

    }

    //可以针对具体异常，其他异常不会执行
    @AfterThrowing(value = "declareJoinPointExpression()", throwing = "ex")
    public void afterThrowing(JoinPoint joinPoint, Exception ex) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println("AfterThrowing: The method " + methodName + " occurs exception " + ex);
    }

    @Around("declareJoinPointExpression()")
    public Object aroundMethod(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        Object result = null;
        String methodName = proceedingJoinPoint.getSignature().getName();
        try {
            System.out.println("Around: The method " + methodName + " begins with: " + Arrays.asList(proceedingJoinPoint.getArgs()));
            result = proceedingJoinPoint.proceed();
            System.out.println("Around: The method " + methodName + " ends with: " + result);
        } catch (Throwable t) {
            System.out.println("Around: The method " + methodName + " occurs exception " + t);
            throw t;
        } finally {
            System.out.println("Around: The method " + methodName + " ends.");
        }
        return result;
    }

}