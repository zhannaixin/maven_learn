package com.spring.beans.factory;

import com.spring.entity.Car;

import java.util.HashMap;

public class StaticCarFactory {
    private static HashMap<String, Car> cars = new HashMap<>();

    static {
        cars.put("audi", new Car("Beijing", "audi", 260));
        cars.put("ford", new Car("Shanghai", "Ford", 300000.0));
        cars.put("bmw", new Car("Tianjin", "BMW", 500000.0));
    }

    public static Car getCar(String name){
        return cars.get(name);
    }

}
