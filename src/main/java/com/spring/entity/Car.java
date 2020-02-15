package com.spring.entity;

public class Car {

    private String brand;
    private String corp;
    private double price;
    private int maxSpeed;
    private double tyrePerimeter;

//    public Car(){}

    public Car(String brand, String corp, double price) {
        super();
        this.brand = brand;
        this.corp = corp;
        this.price = price;

        System.out.println("Car's Constructor02!");
    }

    public Car(String brand, String corp, int maxSpeed) {
        super();
        this.brand = brand;
        this.corp = corp;
        this.maxSpeed = maxSpeed;
        System.out.println("Car's Constructor03!");

    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getCorp() {
        return corp;
    }

    public void setCorp(String corp) {
        this.corp = corp;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getMaxSpeed() {
        return maxSpeed;
    }

    public void setMaxSpeed(int maxSpeed) {
        this.maxSpeed = maxSpeed;
    }

    public double getTyrePerimeter() {
        return tyrePerimeter;
    }

    public void setTyrePerimeter(double tyrePerimeter) {
        this.tyrePerimeter = tyrePerimeter;
    }

    @Override
    public String toString() {
        return "Car{" +
                "brand='" + brand + '\'' +
                ", corp='" + corp + '\'' +
                ", price=" + price +
                ", maxSpeed=" + maxSpeed +
                ", tyrePerimeter=" + tyrePerimeter +
                '}';
    }
}
