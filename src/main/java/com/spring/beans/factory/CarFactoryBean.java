package com.spring.beans.factory;

import com.spring.entity.Car;
import org.springframework.beans.factory.FactoryBean;

public class CarFactoryBean implements FactoryBean<Car> {
    @Override
    public Car getObject() {
        return new Car("Haikou", "Haima", 100000.0);
    }

    @Override
    public Class<?> getObjectType() {
        return Car.class;
    }

    @Override
    public boolean isSingleton() {
        return true;
    }
}
