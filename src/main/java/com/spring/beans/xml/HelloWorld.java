package com.spring.beans.xml;

public class HelloWorld {

    private String who;

    public HelloWorld() {
    }

    public HelloWorld(String who) {
        this.who = who;
    }

    public String getWho() {
        return who;
    }

    public void setWho(String who) {
        this.who = who;
    }

    public void say() {
        System.out.println("Hello " + who + "!");
    }

    @Override
    public String toString() {
        return "HelloWorld{" +
                "who='" + who + '\'' +
                '}';
    }

    public void init(){
        System.out.println("Initing ...!");

    }

    public void destroy(){
        System.out.println("Destorying ...!");

    }
}
